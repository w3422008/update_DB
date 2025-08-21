<?php
// 自動的にpublic/login.phpにリダイレクトさせる
require_once __DIR__ . '/class/RedirectManager.php';
$redirect = new RedirectManager();
$redirect->redirectToLogin();
// ↑ ＝ header("Location: public/login.php");が実行される