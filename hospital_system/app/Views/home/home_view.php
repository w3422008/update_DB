<!DOCTYPE html>
<html>

<head>
    <title>ホーム</title>
    <link rel="icon" type="image/x-icon" href="<?php echo asset('images/favicon/favicon.ico'); ?>">
</head>

<body><?php var_dump($this->method); ?>
    <h1></h1>
    <h2>ホームページへようこそ</h2>
    <p><a href="<?php echo route('/'); ?>">ログインページへ</a></p>
    <p><a href="<?php echo route('/user'); ?>">ユーザープロフィールへ</a></p>
</body>

</html>