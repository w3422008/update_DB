<?php
// シンプルなルーティング処理
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../app/Models/AppCore.php';
$routes = require __DIR__ . '/../routes/web.php';
session_start();

// AppCoreクラス取得
$app = new AppCore(false);

// ベースパスを定義（config.php の BASE_PATH を使用）
$basePath = BASE_PATH;

// URLを取得し、ベースパスを除去
$request = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$request = urldecode(rtrim($request));

// ベースパスを除去
if (strpos($request, $basePath) === 0) {
    $request = substr($request, strlen($basePath));
}

// router.phpへの直接アクセスを除去
$request = str_replace('/router.php', '', $request);

// ルートの正規化
$request = rtrim($request, '/');
if ($request === '') {
    $request = '/';
}

// ルートに対応するコントローラーとメソッドを取得
// $routes:web.php の対応するエントリ
// $request:現在のリクエストパス
// 例：$request = '/'
// 　　→ $routes[$request] = ['controller' => 'LoginController', 'method' => 'login', 'title' => 'ログイン']

$route = $routes[$request] ?? null;

if ($route) {
    $controllerName = $route['controller'];
    $method = $route['method'];
    require_once __DIR__ . '/../app/Controllers/' . $controllerName . '.php';
    $controller = new $controllerName($route['method']);
    $controller->$method();
} else {
    http_response_code(404);
    echo "404 Not Found";
}
