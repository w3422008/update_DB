<?php
require_once __DIR__ . '/../Services/UserService.php';

class UserController
{
    private $method;

    // UserServiceのインスタンスを保持するプロパティ
    private $userService;

    // コンストラクタでメソッド名を受け取る
    public function __construct($method)
    {
        $this->method = $method;
        $this->userService = new UserService();
    }

    public function users()
    {
        $user_id = $_SESSION['user_id'] ?? null;
        if (!$user_id) {
            header('Location: ' . route('/'));
            exit;
        }
        $user_data = $this->userService->getUserData();
        include __DIR__ . '/../Views/user/profile_view.php';
    }
}
