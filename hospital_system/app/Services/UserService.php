<?php
require_once __DIR__ . '/../Models/UserManager.php';

class UserService
{

    private $UserManager;

    public function __construct()
    {
        $this->UserManager = new UserManager();
    }

    public function getUserData()
    {
        // ユーザー情報を取得
        $user_data = $this->UserManager->getUserData();

        return $user_data;
    }
}
