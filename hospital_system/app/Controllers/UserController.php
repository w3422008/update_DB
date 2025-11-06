<?php
require_once __DIR__ . '/../Services/UserService.php';

class UserController {
    public function profile() {
        $service = new UserService();
        $user = $service->getUserData(1);
        include __DIR__ . '/../Views/user/profile.php';
    }
}
