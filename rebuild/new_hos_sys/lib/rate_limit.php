<?php
declare(strict_types=1);
function rl_record(PDO $pdo,string $key): void { $st=$pdo->prepare("INSERT INTO login_attempts (key_name) VALUES (?)"); $st->execute([$key]); }
function rl_too_many(PDO $pdo,string $key,int $limit,string $intervalSql): bool {
  $st=$pdo->prepare("SELECT COUNT(*) FROM login_attempts WHERE key_name=? AND attempted > (NOW()-INTERVAL $intervalSql)");
  $st->execute([$key]); return ((int)$st->fetchColumn()) >= $limit;
}