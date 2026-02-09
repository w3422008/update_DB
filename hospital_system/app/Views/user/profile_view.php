<!DOCTYPE html>
<html>

<head>
    <title>プロフィール</title>
    <link rel="icon" type="image/x-icon" href="<?php echo asset('images/favicon/favicon.ico'); ?>">
    <link rel="stylesheet" href="<?php echo asset('css/AppCore.css'); ?>">
    <link rel="stylesheet" href="<?php echo asset('css/profile.css'); ?>">
</head>

<body>
    <h1>ユーザー</h1>

    <hr>
    <?php
    foreach ($user_data as $user) {
        ?>
        <p>ユーザーID: <?php echo htmlspecialchars($user['user_id'], ENT_QUOTES, 'UTF-8'); ?></p>
        <p>名前: <?php echo htmlspecialchars($user['user_name'], ENT_QUOTES, 'UTF-8'); ?></p>
        <p>部署名: <?php echo htmlspecialchars($user['department_id'], ENT_QUOTES, 'UTF-8'); ?></p>
        <hr>
            <?php
    }
    ?>

    <p>
        <a href="<?php echo route('/home'); ?>" class="default-button home-button">ホーム</a>
        <a href="<?php echo route('/'); ?>" class="default-button logout-button">ログアウト</a>
    </p>
</body>

</html>