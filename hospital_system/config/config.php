<?php
// BASE_PATH：router.phpにてルーティングするための基準パス
define('BASE_PATH', '/software_dev/rebuild/hospital_system/public/router.php');
// ASSETS_PATH：CSSやJS、画像などのアセットファイルの基準パス
define( 'ASSETS_PATH', '/software_dev/rebuild/hospital_system/public/' );

// ルーティング用のヘルパー関数
function route($path) {
    return BASE_PATH . $path;
}

// CSSやJS、画像などのアセットファイルのヘルパー関数
function asset($path) {
    return ASSETS_PATH . $path;
}


return [
    'db' => [
        'host' => 'localhost',
        'port' => '3306',
        'user' => 'root',
        'password' => '',
        'database' => 'newhptldb'
    ]
];
