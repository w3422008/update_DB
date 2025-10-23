<?php
/**
 * menu_view.php
 * メニュー画面
 *
 * - ログイン後のユーザー専用メニュー画面
 * - 各機能へのナビゲーションカードを表示
 */

?><!doctype html>
<html lang="ja">
<head>
    <meta charset="utf-8">
    <title>メニュー - 医療機関情報システム</title>
    <link rel="icon" type="image/png" href="../../favicon.ico">
    <!-- UIkit CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/uikit@3.16.14/dist/css/uikit.min.css" />
    <!-- UIkit JS -->
    <script src="https://cdn.jsdelivr.net/npm/uikit@3.16.14/dist/js/uikit.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/uikit@3.16.14/dist/js/uikit-icons.min.js"></script>
    <!-- カスタムCSS -->
    <link rel="stylesheet" href="../../CSS/AppCore.css">
    <link rel="stylesheet" href="../../CSS/menu.css">
</head>
<body>
    <?php include_once "../view/templates/header.php"; ?>
    
    <div class="uk-container uk-container-large uk-margin-top">
        <div class="menu-grid">
            <div class="uk-flex uk-flex-center">
                <div class="uk-width-5-6@l uk-width-1-1@m">
                    <div class="uk-grid uk-child-width-1-3@l uk-child-width-1-2@m uk-child-width-1-1@s uk-grid-match uk-grid-medium" uk-grid>
                        <div>
                            <div class="menu-card" uk-tooltip="title: 医療機関が検索できます; pos: bottom">
                                <a href="#dashboard" class="menu-card-link">
                                    <div class="menu-card-icon">
                                        <span uk-icon="icon: search; ratio: 2"></span>
                                    </div>
                                    <h3 class="menu-card-title">医療機関 検索</h3>
                                </a>
                            </div>
                        </div>
                        <div>
                            <div class="menu-card" uk-tooltip="title: 医療機関の新規登録・削除に加え<br>医療機関を出力できます; pos: bottom">
                                <a href="#messages" class="menu-card-link">
                                    <div class="menu-card-icon">
                                        <span uk-icon="icon: database; ratio: 2"></span>
                                    </div>
                                    <h3 class="menu-card-title">医療機関 管理/出力
                                    </h3>
                                </a>
                            </div>
                        </div>
<?php
                        if ($user_data['role'] === 'admin' || $user_data['role'] === 'system_admin'):
?>
                        <div>
                            <div class="menu-card" uk-tooltip="title: Manage user accounts; pos: bottom">
                                <a href="#users" class="menu-card-link">
                                    <div class="menu-card-icon">
                                        <span uk-icon="icon: pull; ratio: 2"></span>
                                    </div>
                                    <h3 class="menu-card-title">データインポート</h3>
                                </a>
                            </div>
                        </div>
                        <div>
                            <div class="menu-card" uk-tooltip="title: ユーザーの管理ができます; pos: bottom">
                                <a href="#reports" class="menu-card-link">
                                    <div class="menu-card-icon">
                                        <span uk-icon="icon: users; ratio: 2"></span>
                                    </div>
                                    <h3 class="menu-card-title">ユーザ－管理</h3>
                                </a>
                            </div>
                        </div>
<?php
                        endif;
?>
                        <div>
                            <div class="menu-card" uk-tooltip="title: システムに関する<br>問い合わせができます; pos: bottom">
                                <a href="#settings" class="menu-card-link">
                                    <div class="menu-card-icon">
                                        <span uk-icon="icon: mail; ratio: 2"></span>
                                    </div>
                                    <h3 class="menu-card-title">お問い合わせ</h3>
                                </a>
                            </div>
                        </div>
<?php
                        if ($user_data['role'] === 'system_admin'):
?>
                        <div>
                            <div class="menu-card" uk-tooltip="title: システムに関する情報を<br>管理します。; pos: bottom">
                                <a href="#management" class="menu-card-link">
                                    <div class="menu-card-icon">
                                        <span uk-icon="icon: settings; ratio: 2"></span>
                                    </div>
                                    <h3 class="menu-card-title">システム管理</h3>
                                </a>
                            </div>
                        </div>
<?php
                        endif;
?>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>