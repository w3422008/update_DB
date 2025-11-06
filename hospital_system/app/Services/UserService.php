<?php
require_once __DIR__ . '/../Models/User.php';

class UserService {
    public function getUserData($id) {
        $user = new User();
        $user->id = $id;
        $user->name = "山田 太郎";
        $user->email = "taro@example.com";
        return $user;
    }
}
