<?php
define('BASE_PATH', '/加藤/revision/hospital_system/public/router.php');

function route($path) {
    return BASE_PATH . $path;
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
