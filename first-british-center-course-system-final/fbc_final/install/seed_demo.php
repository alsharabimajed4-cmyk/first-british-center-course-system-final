<?php
require_once __DIR__.'/../config/bootstrap.php';
$pdo=db();
$pdo->beginTransaction();
try{
foreach([['English A1','EN-A1','A1',1],['English A2','EN-A2','A2',2],['English B1','EN-B1','B1',3],['English B2','EN-B2','B2',4],['English C1','EN-C1','C1',5]] as $c){$pdo->prepare('INSERT IGNORE INTO courses(name,code,category,level_name,level_order,max_students,default_start,default_end,sessions_per_week,session_minutes,status) VALUES(?,?,?,?,?,?,?,?,?,?,\'active\')')->execute([$c[0],$c[1],'English',$c[2],$c[3],25,'18:00:00','20:00:00',3,120]);}
foreach([['Demo Trainer One','demo1@example.com'],['Demo Trainer Two','demo2@example.com'],['Demo Trainer Three','demo3@example.com']] as $t){$pdo->prepare("INSERT INTO trainers(full_name,email,min_level_order,max_level_order,status) VALUES(?,?,?,?, 'active')")->execute([$t[0],$t[1],1,6]);$id=$pdo->lastInsertId();for($i=1;$i<=7;$i++)if($i!==5)$pdo->prepare('INSERT INTO trainer_availability(trainer_id,weekday,start_time,end_time) VALUES(?,?,?,?)')->execute([$id,$i,'16:00:00','22:00:00']);}
$pdo->commit();echo "Demo catalog created.\n";
}catch(Throwable $e){$pdo->rollBack();fwrite(STDERR,$e->getMessage()."\n");exit(1);}
