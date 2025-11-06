<?php
require_once __DIR__ . '/../Services/UserService.php';

class HomeController {
    public function index() {
        $message = "ようこそ、ミニMVCフレームワークへ！";
        include __DIR__ . '/../Views/home/home_view.php';
    }
}
