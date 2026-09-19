<?php
declare(strict_types=1);

$root = dirname(__DIR__);
$envFile = $root.'/.env';
if (is_file($envFile)) {
    foreach (file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        $line = trim($line); if ($line === '' || $line[0] === '#') continue;
        [$k,$v] = array_pad(explode('=', $line, 2), 2, '');
        $v = trim($v); if ((str_starts_with($v,'"') && str_ends_with($v,'"')) || (str_starts_with($v,"'") && str_ends_with($v,"'"))) $v=substr($v,1,-1);
        if (!isset($_ENV[$k])) $_ENV[$k]=$v;
    }
}
function envv(string $key, ?string $default=null): ?string { return $_ENV[$key] ?? getenv($key) ?: $default; }

date_default_timezone_set(envv('APP_TIMEZONE','Asia/Aden'));
$secure = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') || envv('FORCE_SECURE_COOKIES','1') === '1';
session_name('fbc_sid');
session_set_cookie_params(['lifetime'=>0,'path'=>'/','secure'=>$secure,'httponly'=>true,'samesite'=>'Lax']);
if (session_status() !== PHP_SESSION_ACTIVE) session_start();

header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: SAMEORIGIN');
header('Referrer-Policy: strict-origin-when-cross-origin');
header('Permissions-Policy: camera=(self), microphone=(self), geolocation=()');

function db(): PDO {
    static $pdo;
    if ($pdo instanceof PDO) return $pdo;
    $host=envv('DB_HOST','127.0.0.1'); $port=envv('DB_PORT','3306'); $name=envv('DB_NAME'); $user=envv('DB_USER'); $pass=envv('DB_PASSWORD','');
    if (!$name || !$user) throw new RuntimeException('Database is not configured. Copy .env.example to .env and set DB_* values.');
    $dsn="mysql:host={$host};port={$port};dbname={$name};charset=utf8mb4";
    $pdo=new PDO($dsn,$user,$pass,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC,PDO::ATTR_EMULATE_PREPARES=>false]);
    return $pdo;
}
function json_out(array $data,int $status=200): never { http_response_code($status); header('Content-Type: application/json; charset=utf-8'); echo json_encode($data,JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES); exit; }
function body(): array { $raw=file_get_contents('php://input'); $d=json_decode($raw ?: '{}',true); return is_array($d)?$d:[]; }
function request_id(): string { static $id; return $id ??= bin2hex(random_bytes(16)); }
function csrf(): string { return $_SESSION['csrf'] ??= bin2hex(random_bytes(32)); }
function require_csrf(): void { $token=$_SERVER['HTTP_X_CSRF_TOKEN'] ?? body()['_csrf'] ?? ''; if (!hash_equals(csrf(),(string)$token)) json_out(['error'=>'Invalid CSRF token'],419); }
function ip(): string { return substr($_SERVER['REMOTE_ADDR'] ?? '',0,64); }
function ua(): string { return substr($_SERVER['HTTP_USER_AGENT'] ?? '',0,500); }
function current_user(): ?array {
    if (empty($_SESSION['user_id'])) return null;
    $s=db()->prepare('SELECT id,username,email,full_name,role,status,profile_complete,last_login_at,created_at FROM users WHERE id=? LIMIT 1'); $s->execute([(int)$_SESSION['user_id']]); $u=$s->fetch();
    if (!$u || $u['status']!=='active') return null; return $u;
}
function require_auth(array $roles=[]): array { $u=current_user(); if (!$u) json_out(['error'=>'Authentication required'],401); if ($roles && !in_array($u['role'],$roles,true)) json_out(['error'=>'Insufficient permissions'],403); return $u; }
function audit(string $action,string $entity,?int $entityId=null,$old=null,$new=null,?string $reason=null): void {
    try { $s=db()->prepare('INSERT INTO audit_logs(user_id,action,entity,entity_id,old_value,new_value,reason,ip_address,user_agent,request_id) VALUES(?,?,?,?,?,?,?,?,?,?)'); $s->execute([$_SESSION['user_id']??null,$action,$entity,$entityId,$old===null?null:json_encode($old,JSON_UNESCAPED_UNICODE),$new===null?null:json_encode($new,JSON_UNESCAPED_UNICODE),$reason,ip(),ua(),request_id()]); } catch(Throwable $e) { error_log('audit: '.$e->getMessage()); }
}
function login_log(?int $userId,string $result,string $method): void { try{$s=db()->prepare('INSERT INTO login_logs(user_id,result,method,ip_address,user_agent) VALUES(?,?,?,?,?)');$s->execute([$userId,$result,$method,ip(),ua()]);}catch(Throwable $e){} }
function setting(string $key,string $default=''): string { $s=db()->prepare('SELECT setting_value FROM settings WHERE setting_key=?');$s->execute([$key]);$v=$s->fetchColumn();return $v===false?$default:(string)$v; }
function weekdays_between(string $start,string $end,bool $excludeFriday=true): array { $dates=[];$d=new DateTimeImmutable($start);$endD=new DateTimeImmutable($end);while($d<=$endD){$n=(int)$d->format('N');if(!($excludeFriday && $n===5))$dates[]=$d->format('Y-m-d');$d=$d->modify('+1 day');}return $dates; }
function calculate_term_end(string $start,int $days,bool $excludeFriday=true): string { $hol=[];$s=db()->query("SELECT holiday_date FROM holidays WHERE active=1");foreach($s as $r)$hol[$r['holiday_date']]=1;$count=0;$d=new DateTimeImmutable($start);while($count<$days){$key=$d->format('Y-m-d');$n=(int)$d->format('N');if(!($excludeFriday&&$n===5)&&!isset($hol[$key]))$count++;if($count<$days)$d=$d->modify('+1 day');}return $d->format('Y-m-d'); }
function normalize_time(string $t): string { return date('H:i:s',strtotime($t)); }
function trainer_eligible(PDO $pdo,int $trainerId,int $levelOrder): bool { $s=$pdo->prepare("SELECT COUNT(*) FROM trainers WHERE id=? AND status='active' AND min_level_order<=? AND max_level_order>=?");$s->execute([$trainerId,$levelOrder,$levelOrder]);return (int)$s->fetchColumn()>0; }
function trainer_available(PDO $pdo,int $trainerId,int $weekday,string $start,string $end): bool { $s=$pdo->prepare('SELECT COUNT(*) FROM trainer_availability WHERE trainer_id=? AND weekday=? AND start_time<=? AND end_time>=? AND active=1');$s->execute([$trainerId,$weekday,$start,$end]);return (int)$s->fetchColumn()>0; }
function trainer_conflict(PDO $pdo,int $trainerId,int $termId,string $date,string $start,string $end): bool { $s=$pdo->prepare("SELECT COUNT(*) FROM schedule_entries WHERE trainer_id=? AND term_id=? AND session_date=? AND status<>'cancelled' AND start_time < ? AND end_time > ?");$s->execute([$trainerId,$termId,$date,$end,$start]);return (int)$s->fetchColumn()>0; }
function course_history_blocked(PDO $pdo,int $trainerId,int $courseId,int $currentTermId,int $minGap=2): bool {
    $cur=$pdo->prepare('SELECT start_date FROM terms WHERE id=?');$cur->execute([$currentTermId]);$curDate=$cur->fetchColumn();if(!$curDate)return false;
    $s=$pdo->prepare("SELECT MAX(t.start_date) FROM schedule_entries se JOIN term_courses tc ON tc.id=se.term_course_id JOIN terms t ON t.id=tc.term_id WHERE se.trainer_id=? AND tc.course_id=? AND se.status IN ('approved','published') AND t.start_date < ?");
    $s->execute([$trainerId,$courseId,$curDate]);$last=$s->fetchColumn();if(!$last)return false;
    $between=$pdo->prepare('SELECT COUNT(*) FROM terms WHERE start_date>? AND start_date<?');$between->execute([$last,$curDate]);$intervening=(int)$between->fetchColumn();
    return $intervening < ($minGap-1);
}
function schedule_dates(PDO $pdo,int $termId): array {
    $s=$pdo->prepare('SELECT * FROM terms WHERE id=?');$s->execute([$termId]);$term=$s->fetch();if(!$term)throw new RuntimeException('Term not found');
    $hol=[];$h=$pdo->query("SELECT holiday_date FROM holidays WHERE active=1");foreach($h as $r)$hol[$r['holiday_date']]=1;
    $out=[];$d=new DateTimeImmutable($term['start_date']);$limit=new DateTimeImmutable($term['end_date'] ?: calculate_term_end($term['start_date'],(int)$term['required_teaching_days'],(bool)$term['exclude_friday']));
    while($d<=$limit && count($out)<(int)$term['required_teaching_days']){$key=$d->format('Y-m-d');$n=(int)$d->format('N');if(!($term['exclude_friday']&&$n===5)&&!isset($hol[$key]))$out[]=$key;$d=$d->modify('+1 day');}return $out;
}
