<?php
/**
 * config.php
 * アプリケーション設定（定数のみ）
 * 関数や DB接続情報は他のファイルで管理
 */

// システム基本パス
define('SYSTEM_PATH', '/revision/hospital_system/');
// define('SYSTEM_PATH', '/software_dev/rebuild/hospital_system/');

// BASE_PATH：router.phpにてルーティングするための基準パス
define('BASE_PATH', SYSTEM_PATH . 'public/router.php');

// ASSETS_PATH：CSSやJS、画像などのアセットファイルの基準パス
define('ASSETS_PATH', SYSTEM_PATH . 'public/');