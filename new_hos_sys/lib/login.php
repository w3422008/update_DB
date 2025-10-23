<?php
/**
 * lib/login.php
 * JSから呼び出されるログイン認証APIエンドポイント
 *
 * - POSTでユーザーID・パスワードを受け取り、認証・レートリミット・セッション管理を行い、JSONで結果を返す
 * - 実装はAppCoreクラスに委譲
 */
header('Content-Type: application/json; charset=UTF-8');
require_once __DIR__ . '/../class/AppCore.php';
require_once __DIR__ . '/../class/LoginManager.php';
$app = new AppCore();
$loginManager = new LoginManager($app->pdo);
$loginManager->handle($app);
