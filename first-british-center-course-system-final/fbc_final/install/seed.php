<?php
require_once __DIR__.'/../config/bootstrap.php';
$pdo=db();
$user=trim((string)envv('ADMIN_USERNAME','admin'));$email=trim((string)envv('ADMIN_EMAIL','admin@example.com'));$name=trim((string)envv('ADMIN_FULL_NAME','System Administrator'));$pass=(string)envv('ADMIN_PASSWORD','');
if(strlen($pass)<16)die("ADMIN_PASSWORD must be at least 16 characters in .env\n");
$q=$pdo->prepare('SELECT id FROM users WHERE username=? OR email=? LIMIT 1');$q->execute([$user,$email]);$existing=$q->fetchColumn();
if($existing){$pdo->prepare("UPDATE users SET email=?,full_name=?,role='super_admin',status='active',password_hash=?,profile_complete=1 WHERE id=?")->execute([$email,$name,password_hash($pass,PASSWORD_DEFAULT),$existing]);$id=$existing;}else{$q=$pdo->prepare("INSERT INTO users(username,email,password_hash,full_name,role,status,profile_complete) VALUES(?,?,?,?, 'super_admin','active',1)");$q->execute([$user,$email,password_hash($pass,PASSWORD_DEFAULT),$name]);$id=$pdo->lastInsertId();}
echo "Admin ready: {$user}\n";
