<!-- UIkit CSS -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/uikit@3.16.14/dist/css/uikit.min.css" />
<!-- UIkit JS -->
<script src="https://cdn.jsdelivr.net/npm/uikit@3.16.14/dist/js/uikit.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/uikit@3.16.14/dist/js/uikit-icons.min.js"></script>
<!-- カスタムCSS -->
<link rel="stylesheet" href="../../CSS/AppCore.css">

<!-- ナビゲーションバー -->
<nav class="uk-navbar-container bg-navbar1" uk-navbar>
    <div class="uk-navbar-left">
        <a class="uk-navbar-item uk-logo" href="../control/menu.php">医療機関情報システム</a>
    </div>
    
    <div class="uk-navbar-right">
        <!-- ユーザーメニューボタン -->
        <a class="uk-navbar-toggle" uk-icon="user" uk-toggle="target: #user-menu"></a>
        
        <!-- ドロップダウンメニュー -->
        <div id="user-menu" uk-dropdown="mode: click; pos: bottom-right" class="bg-navbar2">
            <ul class="uk-nav uk-dropdown-nav">
                <li class="user-role-badge">
                    <span class="role-badge"><?php echo $app->getRoleLabel($user_data['role']) ?></span>
                </li>
                <li class="user-info-section">
                    <div class="user-info-lines">
                        <div class="user-info-line">
                            <span class="user-id"><?php echo $app->escape($user_data['user_id']) ?></span>
                        </div>
                        <div class="user-info-line">
                            <span class="user-name"><?php echo $app->escape($user_data['user_name']) ?></span>
                        </div>
                    </div>
                </li>
                <li class="uk-nav-divider"></li>
                <li><a href="#" class="menu-item"><span uk-icon="cog" class="menu-icon"></span>パスワード変更</a></li>
                <li><a href="../control/logout.php" class="menu-item"><span uk-icon="sign-out" class="menu-icon"></span>ログアウト</a></li>
            </ul>
        </div>
    </div>
</nav>
