<?php
// public/router.php へ遷移
session_start();
$_SESSION['initial_uri'] = '';
header("Location: public/router.php");
exit;
