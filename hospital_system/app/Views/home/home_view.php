<!DOCTYPE html>
<html>

<head>
    <title>ホーム</title>
    <link rel="icon" type="image/x-icon" href="<?php echo asset('images/favicon/favicon.ico'); ?>">
    <link rel="stylesheet" href="<?php echo asset('css/AppCore.css'); ?>">
    <link rel="stylesheet" href="<?php echo asset('css/home.css'); ?>">
</head>

<body>
    <h1>ホームページへようこそ</h1>
    <p>
        <a href="<?php echo route('/user'); ?>" class="default-button profile-button">プロフィール</a>
        <a href="<?php echo route('/'); ?>" class="default-button logout-button">ログアウト</a>
    </p>
</body>

</html>