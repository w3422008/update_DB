<?php
// シンプルなルーティング処理
require_once __DIR__ . '/../config/config.php';
$routes = require __DIR__ . '/../routes/web.php';
session_start();

// ベースパスを定義（config.php の BASE_PATH を使用）
$basePath = BASE_PATH;

// URIを取得し、ベースパスを除去
$request = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$request = urldecode(rtrim($request));

// ベースパスを除去
if (strpos($request, $basePath) === 0) {
    $request = substr($request, strlen($basePath));
}

// router.phpへの直接アクセスを除去
$request = str_replace('/router.php', '', $request);

$request = rtrim($request, '/');
if ($request === '') {
    $request = '/';
}

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
