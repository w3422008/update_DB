<?php
require_once __DIR__ . '/../Models/AppCore.php';
class HomeController
{
    private $method;

    // コンストラクタでメソッド名を受け取る
    public function __construct($method)
    {
        $this->method = $method;
    }

    // ビューの呼び出し
    public function home()
    {
        $app = new AppCore(false); // セッション初期化なしでインスタンス化
        include __DIR__ . '/../Views/home/home_view.php';
    }
}