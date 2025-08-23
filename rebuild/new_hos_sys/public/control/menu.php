<?php

require_once __DIR__ . '/../../class/AppCore.php';
$app = new AppCore();
// ログインしていない場合はログイン画面へ
if (empty($_SESSION['user_id'])) {
	header('Location: ../view/login.php');
	exit;
}

// ユーザー情報取得
$user_data = $app->loadUserInfo($_SESSION['user_id']) ?? $_SESSION['user_id'];
require_once __DIR__ . '/../view/menu_view.php';