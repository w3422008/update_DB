<!DOCTYPE html>
<html>
<head>
    <title>ホーム</title>
    <link rel="icon" type="image/x-icon" href="./images/favicon/favicon.ico">
</head>
<body>
<h1><?= htmlspecialchars($message) ?></h1>
<p><a href="<?php echo route('/user'); ?>">ユーザープロフィールへ</a></p>
</body>
</html>
