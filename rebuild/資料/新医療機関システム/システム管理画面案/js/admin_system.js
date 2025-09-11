// Admin System JavaScript
class AdminSystem {
    constructor() {
        this.currentSection = 'notifications';
        this.notifications = [];
        this.logs = [];
        this.databaseData = {};
        this.currentTable = 'users';
        
        this.init();
    }

    init() {
        this.setupNavigation();
        this.setupEventListeners();
        this.loadInitialData();
        this.setupModal();
    }

    // ナビゲーション設定
    setupNavigation() {
        const navItems = document.querySelectorAll('.ant-menu-item');
        
        navItems.forEach(item => {
            item.addEventListener('click', (e) => {
                e.preventDefault();
                const section = item.dataset.section;
                this.switchSection(section);
                
                // アクティブ状態の更新
                navItems.forEach(nav => nav.classList.remove('ant-menu-item-selected'));
                item.classList.add('ant-menu-item-selected');
            });
        });
    }

    // セクション切り替え
    switchSection(sectionName) {
        // 現在のセクションを非表示
        document.querySelectorAll('.content-section').forEach(section => {
            section.classList.remove('active');
        });
        
        // 新しいセクションを表示
        const newSection = document.getElementById(`${sectionName}-section`);
        if (newSection) {
            newSection.classList.add('active');
            this.currentSection = sectionName;
            
            // セクション固有の初期化
            this.initSection(sectionName);
        }
    }

    // セクション固有の初期化
    initSection(sectionName) {
        switch(sectionName) {
            case 'notifications':
                this.loadNotifications();
                break;
            case 'logs':
                this.loadLogs();
                break;
            case 'database':
                this.loadDatabaseData();
                break;
            case 'maintenance':
                this.loadMaintenanceSettings();
                break;
        }
    }

    // イベントリスナー設定
    setupEventListeners() {
        // 通知関連
        this.setupNotificationEvents();
        
        // ログ関連
        this.setupLogEvents();
        
        // メンテナンス関連
        this.setupMaintenanceEvents();
        
        // データベース関連
        this.setupDatabaseEvents();
        
        // FABボタン
        this.setupFabEvents();
        
        // アプリバー
        this.setupAppBarEvents();
    }

    // 通知関連イベント
    setupNotificationEvents() {
        // 通知フィルター
        const filterTags = document.querySelectorAll('.notification-filters .ant-tag');
        filterTags.forEach(tag => {
            tag.addEventListener('click', () => {
                filterTags.forEach(t => t.classList.remove('ant-tag-checkable-checked'));
                tag.classList.add('ant-tag-checkable-checked');
                this.filterNotifications(tag.dataset.filter);
            });
        });

        // 通知作成フォーム
        const notificationForm = document.getElementById('notificationForm');
        if (notificationForm) {
            notificationForm.addEventListener('submit', (e) => {
                e.preventDefault();
                this.createNotification();
            });
        }

        // プレビューボタン
        const previewBtn = document.getElementById('previewBtn');
        if (previewBtn) {
            previewBtn.addEventListener('click', () => {
                this.previewNotification();
            });
        }
    }

    // ログ関連イベント
    setupLogEvents() {
        const filterLogsBtn = document.getElementById('filterLogs');
        if (filterLogsBtn) {
            filterLogsBtn.addEventListener('click', () => {
                this.filterLogs();
            });
        }

        const exportLogsBtn = document.getElementById('exportLogs');
        if (exportLogsBtn) {
            exportLogsBtn.addEventListener('click', () => {
                this.exportLogs();
            });
        }
    }

    // メンテナンス関連イベント
    setupMaintenanceEvents() {
        // システム設定スイッチ
        const maintenanceMode = document.getElementById('maintenanceMode');
        const newRegistration = document.getElementById('newRegistration');
        const loginRestriction = document.getElementById('loginRestriction');

        [maintenanceMode, newRegistration, loginRestriction].forEach(toggle => {
            if (toggle) {
                toggle.addEventListener('change', (e) => {
                    this.updateSystemSetting(e.target.id, e.target.checked);
                });
            }
        });

        // キャッシュ管理
        const clearCacheBtn = document.getElementById('clearCache');
        const refreshConfigBtn = document.getElementById('refreshConfig');
        
        if (clearCacheBtn) {
            clearCacheBtn.addEventListener('click', () => {
                this.showConfirmDialog('キャッシュクリア', 'すべてのキャッシュをクリアしますか？', () => {
                    this.clearCache();
                });
            });
        }

        if (refreshConfigBtn) {
            refreshConfigBtn.addEventListener('click', () => {
                this.refreshConfig();
            });
        }

        // バックアップ
        const createBackupBtn = document.getElementById('createBackup');
        const restoreBackupBtn = document.getElementById('restoreBackup');
        
        if (createBackupBtn) {
            createBackupBtn.addEventListener('click', () => {
                this.createBackup();
            });
        }

        if (restoreBackupBtn) {
            restoreBackupBtn.addEventListener('click', () => {
                this.restoreBackup();
            });
        }
    }

    // データベース関連イベント
    setupDatabaseEvents() {
        // テーブルタブ
        const tabButtons = document.querySelectorAll('.ant-tabs-tab');
        tabButtons.forEach(tab => {
            tab.addEventListener('click', () => {
                tabButtons.forEach(t => t.classList.remove('ant-tabs-tab-active'));
                tab.classList.add('ant-tabs-tab-active');
                this.currentTable = tab.dataset.table;
                this.loadTableData(this.currentTable);
            });
        });

        // 検索
        const dbSearch = document.getElementById('dbSearch');
        if (dbSearch) {
            dbSearch.addEventListener('input', () => {
                this.searchDatabase(dbSearch.value);
            });
        }

        // 新規追加
        const addRecordBtn = document.getElementById('addRecord');
        if (addRecordBtn) {
            addRecordBtn.addEventListener('click', () => {
                this.addDatabaseRecord();
            });
        }
    }

    // FABイベント
    setupFabEvents() {
        const refreshNotifications = document.getElementById('refreshNotifications');
        const refreshDatabase = document.getElementById('refreshDatabase');

        if (refreshNotifications) {
            refreshNotifications.addEventListener('click', () => {
                this.loadNotifications();
            });
        }

        if (refreshDatabase) {
            refreshDatabase.addEventListener('click', () => {
                this.loadDatabaseData();
            });
        }
    }

    // アプリバーイベント
    setupAppBarEvents() {
        const settingsBtn = document.getElementById('settingsBtn');
        const logoutBtn = document.getElementById('logoutBtn');

        if (settingsBtn) {
            settingsBtn.addEventListener('click', () => {
                this.openSettings();
            });
        }

        if (logoutBtn) {
            logoutBtn.addEventListener('click', () => {
                this.logout();
            });
        }
    }

    // 初期データ読み込み
    loadInitialData() {
        this.loadNotifications();
        this.generateSampleData();
    }

    // 通知読み込み
    loadNotifications() {
        // サンプル通知データ
        this.notifications = [
            {
                id: 1,
                title: 'システムメンテナンス予定',
                content: '2025年9月15日 2:00-4:00にシステムメンテナンスを実施します。',
                priority: 'urgent',
                timestamp: new Date('2025-09-10 14:30'),
                read: false
            },
            {
                id: 2,
                title: '新機能リリース',
                content: 'データエクスポート機能が追加されました。',
                priority: 'normal',
                timestamp: new Date('2025-09-09 10:15'),
                read: true
            },
            {
                id: 3,
                title: 'セキュリティアップデート',
                content: 'セキュリティアップデートが適用されました。',
                priority: 'high',
                timestamp: new Date('2025-09-08 16:45'),
                read: true
            }
        ];
        
        this.renderNotifications();
    }

    // 通知表示
    renderNotifications() {
        const notificationList = document.getElementById('notificationList');
        if (!notificationList) return;

        notificationList.innerHTML = '';
        
        this.notifications.forEach(notification => {
            const notificationItem = document.createElement('div');
            notificationItem.className = `ant-list-item ${!notification.read ? 'unread' : ''}`;
            
            notificationItem.innerHTML = `
                <div class="notification-header">
                    <h4 class="notification-title">${notification.title}</h4>
                    <span class="notification-time">${this.formatDateTime(notification.timestamp)}</span>
                </div>
                <div class="notification-content">${notification.content}</div>
                <div class="notification-priority ${notification.priority}">${this.getPriorityText(notification.priority)}</div>
            `;
            
            notificationList.appendChild(notificationItem);
        });
    }

    // 通知フィルター
    filterNotifications(filter) {
        let filteredNotifications = this.notifications;
        
        switch(filter) {
            case 'unread':
                filteredNotifications = this.notifications.filter(n => !n.read);
                break;
            case 'urgent':
                filteredNotifications = this.notifications.filter(n => n.priority === 'urgent');
                break;
            case 'system':
                filteredNotifications = this.notifications.filter(n => n.title.includes('システム'));
                break;
        }
        
        this.renderFilteredNotifications(filteredNotifications);
    }

    renderFilteredNotifications(notifications) {
        const notificationList = document.getElementById('notificationList');
        if (!notificationList) return;

        notificationList.innerHTML = '';
        
        notifications.forEach(notification => {
            const notificationItem = document.createElement('div');
            notificationItem.className = `ant-list-item ${!notification.read ? 'unread' : ''}`;
            
            notificationItem.innerHTML = `
                <div class="notification-header">
                    <h4 class="notification-title">${notification.title}</h4>
                    <span class="notification-time">${this.formatDateTime(notification.timestamp)}</span>
                </div>
                <div class="notification-content">${notification.content}</div>
                <div class="notification-priority ${notification.priority}">${this.getPriorityText(notification.priority)}</div>
            `;
            
            notificationList.appendChild(notificationItem);
        });
    }

    // 通知作成
    createNotification() {
        const title = document.getElementById('notificationTitle').value;
        const content = document.getElementById('notificationContent').value;
        const priority = document.getElementById('notificationPriority').value;
        
        if (!title || !content) {
            alert('タイトルと内容を入力してください。');
            return;
        }

        const newNotification = {
            id: this.notifications.length + 1,
            title: title,
            content: content,
            priority: priority,
            timestamp: new Date(),
            read: false
        };
        
        this.notifications.unshift(newNotification);
        this.renderNotifications();
        
        // フォームクリア
        document.getElementById('notificationForm').reset();
        
        this.showToast('通知が作成されました。');
    }

    // 通知プレビュー
    previewNotification() {
        const title = document.getElementById('notificationTitle').value;
        const content = document.getElementById('notificationContent').value;
        const priority = document.getElementById('notificationPriority').value;
        
        if (!title || !content) {
            alert('タイトルと内容を入力してください。');
            return;
        }

        const previewContent = `
            <div class="ant-list-item">
                <div class="notification-header">
                    <h4 class="notification-title">${title}</h4>
                    <span class="notification-time">今</span>
                </div>
                <div class="notification-content">${content}</div>
                <div class="notification-priority ${priority}">${this.getPriorityText(priority)}</div>
            </div>
        `;
        
        this.showDialog('通知プレビュー', previewContent);
    }

    // ログ読み込み
    loadLogs() {
        // サンプルログデータ
        this.logs = [
            {
                timestamp: new Date('2025-09-11 14:30:15'),
                level: 'info',
                user: 'admin',
                action: 'ログイン',
                details: 'システム管理者としてログインしました'
            },
            {
                timestamp: new Date('2025-09-11 14:25:10'),
                level: 'warning',
                user: 'user001',
                action: 'パスワード変更失敗',
                details: '古いパスワードが一致しません'
            },
            {
                timestamp: new Date('2025-09-11 14:20:05'),
                level: 'error',
                user: 'system',
                action: 'データベース接続エラー',
                details: 'Connection timeout after 30 seconds'
            }
        ];
        
        this.renderLogs();
    }

    // ログ表示
    renderLogs() {
        const logTableBody = document.getElementById('logTableBody');
        if (!logTableBody) return;

        logTableBody.innerHTML = '';
        
        this.logs.forEach(log => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td class="ant-table-cell">${this.formatDateTime(log.timestamp)}</td>
                <td class="ant-table-cell"><span class="log-level ${log.level}">${log.level.toUpperCase()}</span></td>
                <td class="ant-table-cell">${log.user}</td>
                <td class="ant-table-cell">${log.action}</td>
                <td class="ant-table-cell">${log.details}</td>
            `;
            logTableBody.appendChild(row);
        });
    }

    // ログフィルター
    filterLogs() {
        const level = document.getElementById('logLevel').value;
        const startDate = document.getElementById('logStartDate').value;
        const endDate = document.getElementById('logEndDate').value;
        
        let filteredLogs = this.logs;
        
        if (level !== 'all') {
            filteredLogs = filteredLogs.filter(log => log.level === level);
        }
        
        if (startDate) {
            const start = new Date(startDate);
            filteredLogs = filteredLogs.filter(log => log.timestamp >= start);
        }
        
        if (endDate) {
            const end = new Date(endDate);
            filteredLogs = filteredLogs.filter(log => log.timestamp <= end);
        }
        
        this.renderFilteredLogs(filteredLogs);
    }

    renderFilteredLogs(logs) {
        const logTableBody = document.getElementById('logTableBody');
        if (!logTableBody) return;

        logTableBody.innerHTML = '';
        
        logs.forEach(log => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td class="ant-table-cell">${this.formatDateTime(log.timestamp)}</td>
                <td class="ant-table-cell"><span class="log-level ${log.level}">${log.level.toUpperCase()}</span></td>
                <td class="ant-table-cell">${log.user}</td>
                <td class="ant-table-cell">${log.action}</td>
                <td class="ant-table-cell">${log.details}</td>
            `;
            logTableBody.appendChild(row);
        });
    }

    // ログエクスポート
    exportLogs() {
        const csvContent = this.convertLogsToCSV();
        this.downloadCSV(csvContent, 'system_logs.csv');
        this.showToast('ログがエクスポートされました。');
    }

    convertLogsToCSV() {
        const headers = ['日時', 'レベル', 'ユーザー', 'アクション', '詳細'];
        const csvRows = [headers.join(',')];
        
        this.logs.forEach(log => {
            const row = [
                this.formatDateTime(log.timestamp),
                log.level,
                log.user,
                log.action,
                `"${log.details}"`
            ];
            csvRows.push(row.join(','));
        });
        
        return csvRows.join('\n');
    }

    downloadCSV(content, filename) {
        const blob = new Blob([content], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        const url = URL.createObjectURL(blob);
        link.setAttribute('href', url);
        link.setAttribute('download', filename);
        link.style.visibility = 'hidden';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

    // メンテナンス設定読み込み
    loadMaintenanceSettings() {
        // 現在の設定を読み込み（サンプル）
        const settings = {
            maintenanceMode: false,
            newRegistration: true,
            loginRestriction: false
        };
        
        Object.keys(settings).forEach(key => {
            const element = document.getElementById(key);
            if (element) {
                element.checked = settings[key];
            }
        });
    }

    // システム設定更新
    updateSystemSetting(setting, value) {
        console.log(`Setting ${setting} to ${value}`);
        this.showToast(`${setting}が${value ? '有効' : '無効'}になりました。`);
    }

    // キャッシュクリア
    clearCache() {
        // キャッシュクリア処理
        setTimeout(() => {
            this.showToast('キャッシュがクリアされました。');
        }, 1000);
    }

    // 設定再読み込み
    refreshConfig() {
        this.showToast('設定が再読み込みされました。');
    }

    // バックアップ作成
    createBackup() {
        this.showToast('バックアップを作成しています...');
        setTimeout(() => {
            this.showToast('バックアップが作成されました。');
        }, 2000);
    }

    // バックアップ復元
    restoreBackup() {
        this.showConfirmDialog(
            'バックアップ復元',
            '現在のデータは失われます。バックアップを復元しますか？',
            () => {
                this.showToast('バックアップを復元しています...');
                setTimeout(() => {
                    this.showToast('バックアップが復元されました。');
                }, 2000);
            }
        );
    }

    // データベースデータ読み込み
    loadDatabaseData() {
        this.generateSampleData();
        this.loadTableData(this.currentTable);
    }

    // サンプルデータ生成
    generateSampleData() {
        this.databaseData = {
            users: [
                { id: 1, name: '管理者', email: 'admin@example.com', role: 'admin', status: 'active' },
                { id: 2, name: '田中太郎', email: 'tanaka@example.com', role: 'user', status: 'active' },
                { id: 3, name: '佐藤花子', email: 'sato@example.com', role: 'user', status: 'inactive' }
            ],
            medical_institutions: [
                { id: 1, name: '○○総合病院', address: '東京都新宿区...', phone: '03-1234-5678', status: 'active' },
                { id: 2, name: '△△クリニック', address: '大阪府大阪市...', phone: '06-9876-5432', status: 'pending' }
            ],
            system_logs: [
                { id: 1, timestamp: '2025-09-11 14:30', level: 'INFO', message: 'User login', user_id: 1 },
                { id: 2, timestamp: '2025-09-11 14:25', level: 'WARNING', message: 'Failed login attempt', user_id: 2 }
            ],
            configurations: [
                { key: 'max_login_attempts', value: '5', description: '最大ログイン試行回数' },
                { key: 'session_timeout', value: '3600', description: 'セッションタイムアウト（秒）' }
            ]
        };
    }

    // テーブルデータ読み込み
    loadTableData(tableName) {
        const data = this.databaseData[tableName] || [];
        this.renderDatabaseTable(data, tableName);
    }

    // データベーステーブル表示
    renderDatabaseTable(data, tableName) {
        const tableHead = document.getElementById('databaseTableHead');
        const tableBody = document.getElementById('databaseTableBody');
        
        if (!tableHead || !tableBody || data.length === 0) return;

        // ヘッダー生成
        const headers = Object.keys(data[0]);
        tableHead.innerHTML = `
            <tr>
                ${headers.map(header => `<th class="ant-table-cell">${header}</th>`).join('')}
                <th class="ant-table-cell">操作</th>
            </tr>
        `;

        // データ行生成
        tableBody.innerHTML = '';
        data.forEach(row => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                ${headers.map(header => `<td class="ant-table-cell">${row[header]}</td>`).join('')}
                <td class="ant-table-cell table-actions">
                    <button class="ant-btn ant-btn-text" onclick="adminSystem.editRecord('${tableName}', ${row.id})">
                        <span class="anticon">✏️</span>
                    </button>
                    <button class="ant-btn ant-btn-text" onclick="adminSystem.deleteRecord('${tableName}', ${row.id})">
                        <span class="anticon">🗑️</span>
                    </button>
                </td>
            `;
            tableBody.appendChild(tr);
        });
    }

    // データベース検索
    searchDatabase(query) {
        if (!query) {
            this.loadTableData(this.currentTable);
            return;
        }

        const data = this.databaseData[this.currentTable] || [];
        const filteredData = data.filter(row => 
            Object.values(row).some(value => 
                value.toString().toLowerCase().includes(query.toLowerCase())
            )
        );
        
        this.renderDatabaseTable(filteredData, this.currentTable);
    }

    // レコード追加
    addDatabaseRecord() {
        this.showToast(`新しい${this.currentTable}レコードを追加（実装予定）`);
    }

    // レコード編集
    editRecord(table, id) {
        this.showToast(`${table}の${id}を編集（実装予定）`);
    }

    // レコード削除
    deleteRecord(table, id) {
        this.showConfirmDialog(
            'レコード削除',
            'このレコードを削除してもよろしいですか？',
            () => {
                const data = this.databaseData[table];
                const index = data.findIndex(item => item.id == id);
                if (index !== -1) {
                    data.splice(index, 1);
                    this.loadTableData(table);
                    this.showToast('レコードが削除されました。');
                }
            }
        );
    }

    // モーダル設定
    setupModal() {
        const modal = document.getElementById('confirmModal');
        const cancelBtn = document.getElementById('modalCancel');
        const confirmBtn = document.getElementById('modalConfirm');

        if (cancelBtn) {
            cancelBtn.addEventListener('click', () => {
                this.hideModal();
            });
        }

        if (modal) {
            modal.addEventListener('click', (e) => {
                if (e.target === modal) {
                    this.hideModal();
                }
            });
        }
    }

    // 確認ダイアログ表示
    showConfirmDialog(title, message, onConfirm) {
        const modal = document.getElementById('confirmModal');
        const modalTitle = document.getElementById('modalTitle');
        const modalMessage = document.getElementById('modalMessage');
        const confirmBtn = document.getElementById('modalConfirm');

        if (modalTitle) modalTitle.textContent = title;
        if (modalMessage) modalMessage.textContent = message;

        // 既存のイベントリスナーを削除
        const newConfirmBtn = confirmBtn.cloneNode(true);
        confirmBtn.parentNode.replaceChild(newConfirmBtn, confirmBtn);

        newConfirmBtn.addEventListener('click', () => {
            onConfirm();
            this.hideModal();
        });

        modal.classList.add('active');
    }

    // ダイアログ表示（汎用）
    showDialog(title, content) {
        const modal = document.getElementById('confirmModal');
        const modalTitle = document.getElementById('modalTitle');
        const modalMessage = document.getElementById('modalMessage');
        const confirmBtn = document.getElementById('modalConfirm');
        const cancelBtn = document.getElementById('modalCancel');

        if (modalTitle) modalTitle.textContent = title;
        if (modalMessage) modalMessage.innerHTML = content;

        confirmBtn.style.display = 'none';
        cancelBtn.textContent = '閉じる';

        modal.classList.add('active');
    }

    // モーダル非表示
    hideModal() {
        const modal = document.getElementById('confirmModal');
        const confirmBtn = document.getElementById('modalConfirm');
        const cancelBtn = document.getElementById('modalCancel');

        modal.classList.remove('active');
        confirmBtn.style.display = 'inline-flex';
        cancelBtn.textContent = 'キャンセル';
    }

    // トースト表示
    showToast(message) {
        // Ant Design風トースト実装
        const toast = document.createElement('div');
        toast.className = 'ant-message-notice';
        toast.style.cssText = `
            position: fixed;
            top: 80px;
            left: 50%;
            transform: translateX(-50%);
            background-color: var(--ant-color-bg-container);
            color: var(--ant-color-text);
            padding: var(--ant-padding-sm) var(--ant-padding);
            border-radius: var(--ant-border-radius);
            z-index: 1010;
            box-shadow: var(--ant-box-shadow-secondary);
            transition: all 0.3s ease;
        `;
        toast.textContent = message;
        
        document.body.appendChild(toast);
        
        setTimeout(() => {
            toast.style.opacity = '0';
            toast.style.transform = 'translateX(-50%) translateY(-20px)';
            setTimeout(() => {
                document.body.removeChild(toast);
            }, 300);
        }, 3000);
    }

    // 設定画面を開く
    openSettings() {
        this.showToast('設定画面（実装予定）');
    }

    // ログアウト
    logout() {
        this.showConfirmDialog(
            'ログアウト',
            'ログアウトしてもよろしいですか？',
            () => {
                this.showToast('ログアウトしました。');
                // リダイレクト処理などを実装
            }
        );
    }

    // ユーティリティ関数
    formatDateTime(date) {
        return new Intl.DateTimeFormat('ja-JP', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit'
        }).format(date);
    }

    getPriorityText(priority) {
        const priorityMap = {
            urgent: '緊急',
            high: '高',
            normal: '通常',
            low: '低'
        };
        return priorityMap[priority] || priority;
    }
}

// アプリケーション初期化
let adminSystem;
document.addEventListener('DOMContentLoaded', () => {
    adminSystem = new AdminSystem();
});
