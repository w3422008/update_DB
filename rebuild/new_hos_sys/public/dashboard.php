<?php
require __DIR__ . '/../lib/bootstrap.php';
require __DIR__ . '/../lib/auth_adapter.php';
if (empty($_SESSION['user_id'])) { header('Location: ./login.php?err=login_required'); exit; }
$display = load_display_name($_SESSION['user_id']) ?? $_SESSION['user_id'];
?><!doctype html><html lang="ja"><head><meta charset="utf-8"><title>ダッシュボード</title></head>
<body>
<h2>ログイン中: <?=h($display)?></h2>
<p>ここは保護エリアです。</p>
<p><a href="./logout.php">ログアウト</a></p>
</body></html>