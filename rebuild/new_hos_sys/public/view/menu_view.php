<?php
/**
 * dashboard.php
 * ログイン後のユーザー専用ダッシュボード画面
 *
 * - ログインしていない場合はログイン画面へリダイレクト
 * - ログインユーザー名を表示
 * - ログアウトリンクを表示
 */


?><!doctype html><html lang="ja"><head><meta charset="utf-8"><title>ダッシュボード</title></head>
<body>
	<?php include_once "header.php"; ?>
	<p>ここは保護エリアです。</p>
	<p><a href="../control/logout.php">ログアウト</a></p>
</body></html>