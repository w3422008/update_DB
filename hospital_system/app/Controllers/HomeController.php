<?php
require_once __DIR__ . '/../Models/AppCore.php';
class HomeController {
    public function home() {
        $app = new AppCore(false); // セッション初期化なしでインスタンス化
        include __DIR__ . '/../Views/home/home_view.php';
    }
}