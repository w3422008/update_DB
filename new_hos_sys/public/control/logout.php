
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
require_once __DIR__ . '/../../class/RedirectManager.php';

/**
 * セッション完全削除処理
 */
$Logout = new LogOutManager();
// RedirectManagerのインスタンスを作成
$redirect = new RedirectManager();

$Logout->destroySession();

// 出力バッファをクリア（万が一の出力漏れ防止）
if (ob_get_level()) {
	ob_end_clean();
}

// ログイン画面へリダイレクト
$redirect->redirectToLogout();