// メンテナンス通知管理システム - メインJavaScript

class MaintenanceNotificationSystem {
    constructor() {
        this.notifications = [];
        this.currentEditId = null;
        this.autoRefreshInterval = null;
        this.init();
    }

    init() {
        this.loadSampleData();
        this.setupEventListeners();
        this.updateDashboard();
        this.renderNotificationsTable();
        this.setupAutoRefresh();
    }

    // サンプルデータの読み込み
    loadSampleData() {
        const sampleData = [
            {
                id: 1,
                title: "定期メンテナンス",
                content: "システムの定期メンテナンスを実施いたします。",
                startDateTime: "2025-08-26T02:00",
                endDateTime: "2025-08-26T06:00",
                type: "maintenance",
                status: "scheduled",
                isVisible: true,
                createdAt: new Date().toISOString()
            },
            {
                id: 2,
                title: "セキュリティ更新",
                content: "セキュリティ関連のアップデートを行います。",
                startDateTime: "2025-08-25T01:00",
                endDateTime: "2025-08-25T03:00",
                type: "update",
                status: "completed",
                isVisible: false,
                createdAt: new Date(Date.now() - 86400000).toISOString()
            }
        ];
        
        // ローカルストレージから既存データを読み込む
        const stored = localStorage.getItem('maintenanceNotifications');
        if (stored) {
            this.notifications = JSON.parse(stored);
        } else {
            this.notifications = sampleData;
            this.saveToStorage();
        }
    }

    // ローカルストレージに保存
    saveToStorage() {
        localStorage.setItem('maintenanceNotifications', JSON.stringify(this.notifications));
    }

    // イベントリスナーの設定
    setupEventListeners() {
        // ハンバーガーメニュー
        const hamburgerMenu = document.getElementById('hamburgerMenu');
        const navMenu = document.getElementById('navMenu');
        
        hamburgerMenu.addEventListener('click', () => {
            navMenu.classList.toggle('active');
        });

        // ナビゲーションメニュー
        document.querySelectorAll('[data-section]').forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                this.showSection(e.target.dataset.section);
                navMenu.classList.remove('active');
            });
        });

        // モーダル関連
        const addNotificationBtn = document.getElementById('addNotificationBtn');
        const notificationModal = document.getElementById('notificationModal');
        const closeModal = document.getElementById('closeModal');
        const cancelModal = document.getElementById('cancelModal');
        const notificationForm = document.getElementById('notificationForm');

        addNotificationBtn.addEventListener('click', () => this.openModal());
        closeModal.addEventListener('click', () => this.closeModal());
        cancelModal.addEventListener('click', () => this.closeModal());
        
        // モーダル外クリックで閉じる
        notificationModal.addEventListener('click', (e) => {
            if (e.target === notificationModal) {
                this.closeModal();
            }
        });

        // フォーム送信
        notificationForm.addEventListener('submit', (e) => {
            e.preventDefault();
            this.saveNotification();
        });

        // 設定変更
        document.getElementById('autoRefresh').addEventListener('change', (e) => {
            if (e.target.checked) {
                this.setupAutoRefresh();
            } else {
                this.clearAutoRefresh();
            }
        });

        document.getElementById('refreshInterval').addEventListener('change', (e) => {
            if (document.getElementById('autoRefresh').checked) {
                this.setupAutoRefresh();
            }
        });

        // ログアウト
        document.getElementById('logout').addEventListener('click', (e) => {
            e.preventDefault();
            if (confirm('ログアウトしますか？')) {
                alert('ログアウトしました');
                // 実際の実装では認証システムにリダイレクト
            }
        });
    }

    // セクション表示切り替え
    showSection(sectionId) {
        document.querySelectorAll('.content-section').forEach(section => {
            section.classList.remove('active');
        });
        document.getElementById(sectionId).classList.add('active');

        // アクティブなナビゲーションアイテムのハイライト
        document.querySelectorAll('[data-section]').forEach(link => {
            link.parentElement.classList.remove('active');
        });
        document.querySelector(`[data-section="${sectionId}"]`).parentElement.classList.add('active');
    }

    // ダッシュボード更新
    updateDashboard() {
        const now = new Date();
        const activeNotifications = this.notifications.filter(n => {
            const start = new Date(n.startDateTime);
            const end = new Date(n.endDateTime);
            return start <= now && now <= end;
        }).length;

        const pastNotifications = this.notifications.filter(n => {
            const end = new Date(n.endDateTime);
            return end < now;
        }).length;

        const visibleNotifications = this.notifications.filter(n => n.isVisible).length;

        document.getElementById('activeNotifications').textContent = activeNotifications;
        document.getElementById('pastNotifications').textContent = pastNotifications;
        document.getElementById('visibleNotifications').textContent = visibleNotifications;
    }

    // 通知テーブルの描画
    renderNotificationsTable() {
        const tableBody = document.getElementById('notificationsTableBody');
        tableBody.innerHTML = '';

        this.notifications.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt)).forEach(notification => {
            const row = this.createNotificationRow(notification);
            tableBody.appendChild(row);
        });
    }

    // 通知テーブル行の作成
    createNotificationRow(notification) {
        const row = document.createElement('tr');
        const now = new Date();
        const start = new Date(notification.startDateTime);
        const end = new Date(notification.endDateTime);
        
        let status = 'scheduled';
        if (end < now) {
            status = 'completed';
        } else if (start <= now && now <= end) {
            status = 'active';
        }

        row.innerHTML = `
            <td>${notification.id}</td>
            <td>${notification.title}</td>
            <td>${this.formatDateTime(notification.startDateTime)}</td>
            <td>${this.formatDateTime(notification.endDateTime)}</td>
            <td><span class="status-badge status-${status}">${this.getStatusText(status)}</span></td>
            <td><span class="status-badge visibility-${notification.isVisible ? 'visible' : 'hidden'}">${notification.isVisible ? '表示中' : '非表示'}</span></td>
            <td>
                <button class="btn btn-sm btn-primary" onclick="maintenanceSystem.editNotification(${notification.id})">
                    <i class="fas fa-edit"></i>
                </button>
                <button class="btn btn-sm ${notification.isVisible ? 'btn-secondary' : 'btn-success'}" onclick="maintenanceSystem.toggleVisibility(${notification.id})">
                    <i class="fas fa-eye${notification.isVisible ? '-slash' : ''}"></i>
                </button>
                <button class="btn btn-sm btn-danger" onclick="maintenanceSystem.deleteNotification(${notification.id})">
                    <i class="fas fa-trash"></i>
                </button>
            </td>
        `;
        return row;
    }

    // 日時フォーマット
    formatDateTime(dateTimeString) {
        const date = new Date(dateTimeString);
        return date.toLocaleString('ja-JP', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit'
        });
    }

    // ステータステキスト取得
    getStatusText(status) {
        const statusMap = {
            'active': '実行中',
            'scheduled': '予定',
            'completed': '完了'
        };
        return statusMap[status] || status;
    }

    // モーダルを開く
    openModal(notification = null) {
        const modal = document.getElementById('notificationModal');
        const modalTitle = document.getElementById('modalTitle');
        const form = document.getElementById('notificationForm');

        if (notification) {
            // 編集モード
            this.currentEditId = notification.id;
            modalTitle.textContent = 'メンテナンス通知編集';
            document.getElementById('notificationTitle').value = notification.title;
            document.getElementById('notificationContent').value = notification.content;
            document.getElementById('startDateTime').value = notification.startDateTime;
            document.getElementById('endDateTime').value = notification.endDateTime;
            document.getElementById('notificationType').value = notification.type;
            document.getElementById('isVisible').checked = notification.isVisible;
        } else {
            // 新規作成モード
            this.currentEditId = null;
            modalTitle.textContent = 'メンテナンス通知登録';
            form.reset();
            
            // デフォルト値設定
            const now = new Date();
            const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000);
            const nextDay = new Date(tomorrow.getTime() + 24 * 60 * 60 * 1000);
            
            document.getElementById('startDateTime').value = this.formatDateTimeForInput(tomorrow);
            document.getElementById('endDateTime').value = this.formatDateTimeForInput(nextDay);
        }

        modal.style.display = 'block';
    }

    // モーダルを閉じる
    closeModal() {
        const modal = document.getElementById('notificationModal');
        modal.style.display = 'none';
        this.currentEditId = null;
    }

    // 通知保存
    saveNotification() {
        const formData = {
            title: document.getElementById('notificationTitle').value,
            content: document.getElementById('notificationContent').value,
            startDateTime: document.getElementById('startDateTime').value,
            endDateTime: document.getElementById('endDateTime').value,
            type: document.getElementById('notificationType').value,
            isVisible: document.getElementById('isVisible').checked
        };

        // バリデーション
        if (!this.validateNotification(formData)) {
            return;
        }

        if (this.currentEditId) {
            // 編集
            const index = this.notifications.findIndex(n => n.id === this.currentEditId);
            if (index !== -1) {
                this.notifications[index] = {
                    ...this.notifications[index],
                    ...formData
                };
            }
        } else {
            // 新規作成
            const newNotification = {
                id: this.getNextId(),
                ...formData,
                createdAt: new Date().toISOString()
            };
            this.notifications.push(newNotification);
        }

        this.saveToStorage();
        this.updateDashboard();
        this.renderNotificationsTable();
        this.closeModal();
        
        const action = this.currentEditId ? '更新' : '登録';
        alert(`通知が${action}されました`);
    }

    // バリデーション
    validateNotification(data) {
        if (!data.title.trim()) {
            alert('タイトルを入力してください');
            return false;
        }

        if (!data.content.trim()) {
            alert('内容を入力してください');
            return false;
        }

        const start = new Date(data.startDateTime);
        const end = new Date(data.endDateTime);

        if (start >= end) {
            alert('終了日時は開始日時より後に設定してください');
            return false;
        }

        return true;
    }

    // 次のIDを取得
    getNextId() {
        const maxId = this.notifications.reduce((max, n) => Math.max(max, n.id), 0);
        return maxId + 1;
    }

    // 通知編集
    editNotification(id) {
        const notification = this.notifications.find(n => n.id === id);
        if (notification) {
            this.openModal(notification);
        }
    }

    // 表示状態切り替え
    toggleVisibility(id) {
        const notification = this.notifications.find(n => n.id === id);
        if (notification) {
            notification.isVisible = !notification.isVisible;
            this.saveToStorage();
            this.updateDashboard();
            this.renderNotificationsTable();
            
            const status = notification.isVisible ? '表示' : '非表示';
            alert(`通知を${status}に変更しました`);
        }
    }

    // 通知削除
    deleteNotification(id) {
        if (confirm('この通知を削除しますか？')) {
            this.notifications = this.notifications.filter(n => n.id !== id);
            this.saveToStorage();
            this.updateDashboard();
            this.renderNotificationsTable();
            alert('通知が削除されました');
        }
    }

    // 入力用日時フォーマット
    formatDateTimeForInput(date) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const hours = String(date.getHours()).padStart(2, '0');
        const minutes = String(date.getMinutes()).padStart(2, '0');
        
        return `${year}-${month}-${day}T${hours}:${minutes}`;
    }

    // 自動更新設定
    setupAutoRefresh() {
        this.clearAutoRefresh();
        
        const interval = parseInt(document.getElementById('refreshInterval').value) * 1000;
        this.autoRefreshInterval = setInterval(() => {
            this.updateDashboard();
            this.renderNotificationsTable();
        }, interval);
    }

    // 自動更新クリア
    clearAutoRefresh() {
        if (this.autoRefreshInterval) {
            clearInterval(this.autoRefreshInterval);
            this.autoRefreshInterval = null;
        }
    }
}

// システム初期化
let maintenanceSystem;

document.addEventListener('DOMContentLoaded', () => {
    maintenanceSystem = new MaintenanceNotificationSystem();
});

// ESCキーでモーダルを閉じる
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        const modal = document.getElementById('notificationModal');
        if (modal.style.display === 'block') {
            maintenanceSystem.closeModal();
        }
    }
});
