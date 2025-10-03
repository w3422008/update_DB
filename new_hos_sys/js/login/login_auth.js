// login_auth.js
// ログイン画面のJS処理
//
// - フォーム送信をJSでハンドリング
// - API（lib/login.php）にPOSTし認証
// - 結果に応じて画面遷移・エラー表示

document.addEventListener('DOMContentLoaded', function() {
    // ログインフォーム取得
    const form = document.querySelector('form[action="./login.php"]');
    console.log('フォーム要素:', form);
    // エラー表示領域取得
    const errDiv = document.querySelector('.err');

    if (form) {
        form.addEventListener('submit', async function(e) {
            e.preventDefault();
            if (errDiv) errDiv.textContent = '';
            const userId = form.user_id.value.trim();
            const password = form.password.value;
            try {
            const res = await fetch('../../lib/login.php', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ user_id: userId, password: password })
            });
            const rawText = await res.text();
            console.log('APIレスポンス:', rawText);
            let data;
            try {
                data = JSON.parse(rawText);
            } catch (e) {
                if (errDiv) errDiv.textContent = 'APIレスポンスが不正です: ' + rawText;
                return;
            }
            if (data.success) {
                // ログイン後のページへ遷移
                window.location.href = '../control/menu.php';
            } else {
                if (errDiv) errDiv.textContent = data.message || 'ログインに失敗しました。';
            }
            } catch (err) {
            if (errDiv) errDiv.textContent = '通信エラーが発生しました。';
            }
        });
    }
});
