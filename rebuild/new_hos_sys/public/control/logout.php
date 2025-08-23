
<?php
/**
 * logout.php
 * ログアウト処理
 *
 * - セッション情報を全て削除
 * - セッションクッキーも削除
 * - ログイン画面へリダイレクト
 *
 */
// システム初期化
require_once __DIR__ . '/../../class/LogOutManager.php';
/**
 * セッション完全削除処理
 */
$Logout = new LogOutManager();

$Logout->destroySession();

// 出力バッファをクリア（万が一の出力漏れ防止）
if (ob_get_level()) {
	ob_end_clean();
}

// ログイン画面へリダイレクト
header('Location: ../view/login.php');
exit;