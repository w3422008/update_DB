const appRoot = document.getElementById("app");
const navLinks = [...document.querySelectorAll(".nav-link")];

const routes = {
    dashboard: renderDashboard,
    patients: renderPatients,
    appointments: renderAppointments,
    analytics: renderAnalytics,
    settings: renderSettings
};

function render(view) {
    const renderFn = routes[view] ?? routes.dashboard;
    appRoot.innerHTML = "";
    const fragment = renderFn();
    appRoot.appendChild(fragment);
    updateActiveLink(view);
}

function updateActiveLink(view) {
    navLinks.forEach(link => {
        const isActive = link.dataset.view === view;
        link.classList.toggle("is-active", isActive);
    });
}

function handleNavigation(view) {
    if (!routes[view]) {
        location.hash = "#dashboard";
        return;
    }
    if (location.hash.substring(1) === view) {
        render(view);
    } else {
        location.hash = `#${view}`;
    }
}

navLinks.forEach(link => {
    link.addEventListener("click", event => {
        const view = event.currentTarget.dataset.view;
        handleNavigation(view);
    });
});

window.addEventListener("hashchange", () => {
    const view = location.hash.replace(/^#/, "");
    render(view);
});

function init() {
    const initialView = location.hash.replace(/^#/, "") || "dashboard";
    render(initialView);
}

// --- Views --- //

function renderDashboard() {
    const fragment = document.createDocumentFragment();
    const container = document.createElement("section");
    container.className = "view";
    container.innerHTML = `
        <h2>ダッシュボード</h2>
        <p class="text-muted">本日の概要と重要なお知らせを確認できます。</p>
        <div class="cards stats">
            <article class="card">
                <h3>本日の外来件数</h3>
                <p><strong>128件</strong></p>
                <p class="text-muted">前日比 +12%</p>
            </article>
            <article class="card">
                <h3>入院患者数</h3>
                <p><strong>342名</strong></p>
                <p class="text-muted">ICU 12名 / 一般 330名</p>
            </article>
            <article class="card">
                <h3>待機時間中央値</h3>
                <p><strong>16分</strong></p>
                <p class="text-muted">目標 20分以下を達成</p>
            </article>
            <article class="card">
                <h3>重要アラート</h3>
                <p><span class="badge">感染症注意報</span></p>
                <p class="text-muted">耳鼻科より院内感染対策の強化を推奨</p>
            </article>
        </div>
        <div class="card" style="margin-top: 1.5rem;">
            <h3>本日のトピック</h3>
            <ul>
                <li>14:00 感染症対策委員会（大会議室A）</li>
                <li>15:30 電子カルテアップデート（システムメンテナンス）</li>
                <li>17:00 救急搬送対応振り返りミーティング</li>
            </ul>
        </div>
    `;
    fragment.appendChild(container);
    return fragment;
}

function renderPatients() {
    const fragment = document.createDocumentFragment();
    const container = document.createElement("section");
    container.className = "view";
    container.innerHTML = `
        <h2>患者情報</h2>
        <p class="text-muted">入退院や担当医、リスク情報を一覧で確認できます。</p>
        <div class="card">
            <header>
                <h3>入院患者サマリ</h3>
            </header>
            <table class="table" aria-label="主要患者一覧">
                <thead>
                    <tr>
                        <th>患者ID</th>
                        <th>氏名</th>
                        <th>担当医</th>
                        <th>部門</th>
                        <th>状態</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>P-10452</td>
                        <td>山田 太郎</td>
                        <td>内科／高橋</td>
                        <td>5階南病棟</td>
                        <td><span class="badge">術後経過良好</span></td>
                    </tr>
                    <tr>
                        <td>P-10988</td>
                        <td>鈴木 一葉</td>
                        <td>循環器内科／李</td>
                        <td>ICU</td>
                        <td><span class="badge">観察強化中</span></td>
                    </tr>
                    <tr>
                        <td>P-11234</td>
                        <td>田中 花子</td>
                        <td>整形外科／佐藤</td>
                        <td>4階西病棟</td>
                        <td><span class="badge">リハビリ実施中</span></td>
                    </tr>
                </tbody>
            </table>
        </div>
    `;
    fragment.appendChild(container);
    return fragment;
}

function renderAppointments() {
    const fragment = document.createDocumentFragment();
    const container = document.createElement("section");
    container.className = "view";
    container.innerHTML = `
        <h2>予約管理</h2>
        <p class="text-muted">本日の予約状況とリソース稼働状況を確認できます。</p>
        <div class="card">
            <h3>救急外来タイムライン</h3>
            <div class="timeline" aria-label="救急外来タイムライン">
                <div class="timeline__item">
                    <time datetime="08:20">08:20</time>
                    <strong>歩行困難／高齢男性</strong><br>
                    <span class="text-muted">整形外科 佐藤医師対応中</span>
                </div>
                <div class="timeline__item">
                    <time datetime="09:05">09:05</time>
                    <strong>胸痛／40代女性</strong><br>
                    <span class="text-muted">循環器内科 李医師が診察予定</span>
                </div>
                <div class="timeline__item">
                    <time datetime="09:45">09:45</time>
                    <strong>発熱／小児</strong><br>
                    <span class="text-muted">小児科に引き継ぎ・隔離室準備</span>
                </div>
            </div>
        </div>
        <div class="card" style="margin-top: 1rem;">
            <h3>手術室稼働状況</h3>
            <ul>
                <li>手術室1：人工関節置換術（進行度 60%）</li>
                <li>手術室2：心臓バイパス術（予定時間 +30分）</li>
                <li>手術室3：腹腔鏡手術（オンタイム）</li>
            </ul>
        </div>
    `;
    fragment.appendChild(container);
    return fragment;
}

function renderAnalytics() {
    const fragment = document.createDocumentFragment();
    const container = document.createElement("section");
    container.className = "view";
    container.innerHTML = `
        <h2>統計分析</h2>
        <p class="text-muted">過去30日間の実績指標を確認できます。</p>
        <div class="cards">
            <article class="card">
                <h3>入院期間平均</h3>
                <p><strong>8.4日</strong>（昨年同月比 -0.6日）</p>
            </article>
            <article class="card">
                <h3>再入院率</h3>
                <p><strong>3.2%</strong></p>
                <p class="text-muted">外来フォローの強化により改善傾向</p>
            </article>
            <article class="card">
                <h3>患者満足度</h3>
                <p><strong>4.6 / 5.0</strong></p>
                <p class="text-muted">受付対応の改善が寄与</p>
            </article>
        </div>
        <div class="card" style="margin-top: 1.5rem;">
            <h3>部門別患者数（サンプル）</h3>
            <p class="text-muted">チャート処理の代わりにテキストサマリを表示しています。</p>
            <ul>
                <li>内科: 480名（45%）</li>
                <li>外科: 250名（23%）</li>
                <li>小児科: 140名（13%）</li>
                <li>その他: 190名（19%）</li>
            </ul>
        </div>
    `;
    fragment.appendChild(container);
    return fragment;
}

function renderSettings() {
    const fragment = document.createDocumentFragment();
    const container = document.createElement("section");
    container.className = "view";
    container.innerHTML = `
        <h2>設定</h2>
        <p class="text-muted">通知やセキュリティに関する設定を更新できます。（サンプル）</p>
        <div class="card">
            <form class="settings-form">
                <label>
                    <span>メール通知</span><br>
                    <select>
                        <option>すべて受信</option>
                        <option>重要なもののみ</option>
                        <option>受信しない</option>
                    </select>
                </label>
                <label>
                    <span>操作ログの保存期間</span><br>
                    <input type="number" min="1" value="6"> ヶ月
                </label>
                <label>
                    <span>二要素認証</span><br>
                    <input type="checkbox" checked> 有効
                </label>
                <button type="button" class="primary">変更を保存</button>
            </form>
        </div>
    `;
    fragment.appendChild(container);
    return fragment;
}

init();
