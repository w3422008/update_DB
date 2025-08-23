<link rel="stylesheet" href="../CSS/AppCore.css">
<div class="uk-position-medium uk-position-top-right uk-position-z-index">
    <!-- Offcanvas -->
    <a class="uk-navbar-toggle uk-navbar-toggle-animate" href="#" uk-navbar-toggle-icon style="margin:0 0 0 auto;"></a>
</div>

<div class="uk-navbar-dropdown uk-width-auto" uk-dropdown="mode: click">
    <ul class="uk-nav uk-navbar-dropdown-nav" uk-margin>
        <li class="uk-nav-header">
            <span uk-icon="icon: user"></span>
        </li>
        <li id=""><span>ID：<?php echo $app->escape($user_data['user_id']) ?></span></li>
        <li><span>ユーザー名：<?php echo $app->escape($user_data['user_name']) ?></span></li>
        <li><span>権限：<?php echo $app->getRoleLabel($user_data['role']) ?></span> でログイン中</li>
        <li class="uk-nav-divider"></li>
        <li><a href="#"><span class="uk-margin-small-right" uk-icon="icon: cog"></span> パスワード変更</a></li>
        <li><a href="#"><span class="uk-margin-small-right" uk-icon="icon: sign-out"></span> ログアウト</a></li>
    </ul>
</div>
