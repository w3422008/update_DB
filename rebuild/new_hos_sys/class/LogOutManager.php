<?php

class LogOutManager{
    // ログアウト処理
    public function destroySession() {
        // セッション変数を全て空に
        $_SESSION = [];
        // セッションクッキー削除
        if (ini_get('session.use_cookies')) {
            $params = session_get_cookie_params();
            setcookie(session_name(), '', time() - 42000, $params['path'], $params['domain'] ?? '', $params['secure'], $params['httponly']);
        }
        // セッション破棄
        session_destroy();
    }
}