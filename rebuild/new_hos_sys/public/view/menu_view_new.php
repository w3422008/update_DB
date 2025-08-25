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
    <?php include_once "header.php"; ?>
    
    <div class="uk-container uk-container-large uk-margin-top">
        <div class="menu-grid uk-grid-match" uk-grid>
            <!-- Dashboard -->
            <div class="uk-width-1-3@m uk-width-1-2@s">
                <div class="menu-card" uk-tooltip="title: View summary of key metrics; pos: bottom">
                    <a href="#dashboard" class="menu-card-link">
                        <div class="menu-card-icon">
                            <span uk-icon="icon: grid; ratio: 2.5"></span>
                        </div>
                        <h3 class="menu-card-title">Dashboard</h3>
                        <p class="menu-card-description">View summary of key metrics</p>
                    </a>
                </div>
            </div>
            
            <!-- Messages -->
            <div class="uk-width-1-3@m uk-width-1-2@s">
                <div class="menu-card" uk-tooltip="title: Check your messages; pos: bottom">
                    <a href="#messages" class="menu-card-link">
                        <div class="menu-card-icon">
                            <span uk-icon="icon: comments; ratio: 2.5"></span>
                        </div>
                        <h3 class="menu-card-title">Messages</h3>
                        <p class="menu-card-description">Check your messages</p>
                    </a>
                </div>
            </div>
            
            <!-- Users -->
            <div class="uk-width-1-3@m uk-width-1-2@s">
                <div class="menu-card" uk-tooltip="title: Manage user accounts; pos: bottom">
                    <a href="#users" class="menu-card-link">
                        <div class="menu-card-icon">
                            <span uk-icon="icon: users; ratio: 2.5"></span>
                        </div>
                        <h3 class="menu-card-title">Users</h3>
                        <p class="menu-card-description">Manage user accounts</p>
                    </a>
                </div>
            </div>
            
            <!-- Reports -->
            <div class="uk-width-1-3@m uk-width-1-2@s">
                <div class="menu-card" uk-tooltip="title: View reports and analytics; pos: bottom">
                    <a href="#reports" class="menu-card-link">
                        <div class="menu-card-icon">
                            <span uk-icon="icon: database; ratio: 2.5"></span>
                        </div>
                        <h3 class="menu-card-title">Reports</h3>
                        <p class="menu-card-description">View reports and analytics</p>
                    </a>
                </div>
            </div>
            
            <!-- Settings -->
            <div class="uk-width-1-3@m uk-width-1-2@s">
                <div class="menu-card" uk-tooltip="title: Adjust your preferences; pos: bottom">
                    <a href="#settings" class="menu-card-link">
                        <div class="menu-card-icon">
                            <span uk-icon="icon: cog; ratio: 2.5"></span>
                        </div>
                        <h3 class="menu-card-title">Settings</h3>
                        <p class="menu-card-description">Adjust your preferences</p>
                    </a>
                </div>
            </div>
            
            <!-- Support -->
            <div class="uk-width-1-3@m uk-width-1-2@s">
                <div class="menu-card" uk-tooltip="title: Get help and support; pos: bottom">
                    <a href="#support" class="menu-card-link">
                        <div class="menu-card-icon">
                            <span uk-icon="icon: question; ratio: 2.5"></span>
                        </div>
                        <h3 class="menu-card-title">Support</h3>
                        <p class="menu-card-description">Get help and support</p>
                    </a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
