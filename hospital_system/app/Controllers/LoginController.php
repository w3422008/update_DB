<?php
require_once __DIR__ . '/../Services/UserService.php';

class LoginController {
    public function login() {
        include __DIR__ . '/../Views/login/login_view.php';
    }
}
