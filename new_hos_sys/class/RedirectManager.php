<?php
/**
* リンク管理用クラスファイル
*/
class RedirectManager {
    /**
     * 指定したURLにリダイレクトします。
     * @param string $url
     */
    public $PUBLIC_LINK = "/revision/new_hos_sys/public/";
    
    // ログインページへのリダイレクト
    // index.phpにて使用
    public function redirectToLogin() {
        header("Location: {$this->PUBLIC_LINK}view/login/login.php");
        exit;
    }

    // ログアウト処理後のリダイレクト
    // public/
    public function redirectToLogout(): void {
        header("Location: {$this->PUBLIC_LINK}view/login/login.php");
        exit;
    }

    public function redirect(string $url): void {
        header("Location: {$this->PUBLIC_LINK}$url");
        exit;
    }

}
