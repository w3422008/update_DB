<?php
/**
 * dashboard.php
 * ログイン後のユーザー専用ダッシュボード画面
 *
 * - ログインしていない場合はログイン画面へリダイレクト
 * - ログインユーザー名を表示
 * - ログアウトリンクを表示
 */
require_once __DIR__ . '/../class/AppCore.php';
$app = new AppCore();
// ログインしていない場合はログイン画面へ
if (empty($_SESSION['user_id'])) {
	header('Location: ./login.php?err=login_required');
	exit;
}
// ユーザー表示名取得
$display = $app->loadDisplayName($_SESSION['user_id']) ?? $_SESSION['user_id'];
?><!doctype html><html lang="ja"><head><meta charset="utf-8"><title>ダッシュボード</title></head>
<body>
	<h2>ログイン中: <?php $app->h($display) ?></h2>
	<p>ここは保護エリアです。</p>
	<p><a href="./control/logout.php">ログアウト</a></p>
</body></html>