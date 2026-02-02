<!DOCTYPE html>
<html>

<head>
    <title>プロフィール</title>
    <link rel="icon" type="image/x-icon" href="<?php echo asset('images/favicon/favicon.ico'); ?>">
</head>

<body>
    <h1>ユーザープロフィール</h1>
    <p>名前: <?= htmlspecialchars($user->name) ?></p>
    <p>メール: <?= htmlspecialchars($user->email) ?></p>
    <p><a href="<?php echo route('/'); ?>">ホームへ戻る</a></p>
</body>

</html>