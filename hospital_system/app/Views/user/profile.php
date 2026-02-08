<!DOCTYPE html>
<html>

<head>
    <title>プロフィール</title>
    <link rel="icon" type="image/x-icon" href="<?php echo asset('images/favicon/favicon.ico'); ?>">
    <link rel="stylesheet" href="<?php echo asset('css/AppCore.css'); ?>">
    <link rel="stylesheet" href="<?php echo asset('css/profile.css'); ?>">
</head>

<body>
    <h1>ユーザープロフィール</h1>
    <p><?php echo $_SESSION['user_id']; ?></p>
    <p><?= htmlspecialchars($user->name) ?></p>
    <p>メール: <?= htmlspecialchars($user->email) ?></p>
    <p>
        <a href="<?php echo route('/home'); ?>" class="default-button home-button">ホームへ戻る</a>
        <a href="<?php echo route('/'); ?>" class="default-button logout-button">ログインページへ</a>
    </p>
</body>

</html>