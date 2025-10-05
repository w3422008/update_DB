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
    // index.phpにて使用
    public function redirectToLogin() {
        header("Location: /software_dev/rebuild/new_hos_sys/public/view/login/login.php");
        exit;
    }

    // ログアウト処理後のリダイレクト
    // public/
    public function redirectToLogout(): void {
        header("Location: /software_dev/rebuild/new_hos_sys/public/view/login/login.php");
        exit;
    }

    public function redirect(string $url): void {
        header("Location: $url");
        exit;
    }

}
