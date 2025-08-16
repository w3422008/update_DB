<?php
declare(strict_types=1);
require_once __DIR__ . '/bootstrap.php';
function check_credentials(string $userId,string $password): bool {
  global $pdo;
  $st=$pdo->prepare('SELECT pwd_hash,is_active FROM users WHERE user_id=?');
  $st->execute([$userId]); $row=$st->fetch();
  if(!$row || !(int)$row['is_active']) return false;
  return password_verify($password,$row['pwd_hash']);
}
function after_login(string $userId): void {
  global $pdo; $st=$pdo->prepare('UPDATE users SET last_login_at=NOW() WHERE user_id=?'); $st->execute([$userId]);
}
function load_display_name(string $userId): ?string {
  global $pdo; $st=$pdo->prepare('SELECT user_id FROM users WHERE user_id=?'); $st->execute([$userId]);
  $row=$st->fetch(); return $row ? ($row['user_id'] ?? null) : null;
}