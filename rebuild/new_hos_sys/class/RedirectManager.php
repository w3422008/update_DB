<?php
/**
* リンク管理用クラスファイル
*/

class RedirectManager {
    /**
     * 指定したURLにリダイレクトします。
     * @param string $url
     */

    // ログインページへのリダイレクト
    public function redirectToLogin() {
        header("Location: public/login.php");
        exit;
    }

    public function redirect(string $url): void {
        header("Location: $url");
        exit;
    }

}
