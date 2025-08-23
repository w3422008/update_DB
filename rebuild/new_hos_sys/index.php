<?php
// 自動的にpublic/view/login.phpにリダイレクトさせる
require_once __DIR__ . '/class/RedirectManager.php';
$redirect = new RedirectManager();
$redirect->redirectToLogin();
// ↑ ＝ header("Location: public/view/login.php");が実行される