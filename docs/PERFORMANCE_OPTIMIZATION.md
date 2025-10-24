# パフォーマンス最適化ガイド

スケーラブルで高速なアプリケーションを構築するための最適化手法。

## 目的

- レスポンスタイムの短縮
- スループットの向上
- サーバーリソースの効率化
- ユーザー体験の向上

## データベース最適化

### 1. N+1問題の回避

**Bad** (N+1問題):
```php
// 100件のユーザーを取得
$users = User::all();

// 各ユーザーの投稿を取得（100回のクエリが発行される）
foreach ($users as $user) {
    echo $user->posts->count(); // ← N+1問題
}
// 合計: 1 + 100 = 101クエリ
```

**Good** (Eager Loading):
```php
// 一度に取得
$users = User::with('posts')->get();

foreach ($users as $user) {
    echo $user->posts->count();
}
// 合計: 2クエリ
```

**確認方法**:
```php
// Laravel Debugbarでクエリ数を確認
composer require barryvdh/laravel-debugbar --dev
```

### 2. インデックスの適切な設定

**マイグレーションでインデックス追加**:
```php
Schema::create('users', function (Blueprint $table) {
    $table->id();
    $table->string('email')->unique(); // ← 自動的にインデックス
    $table->string('name');
    $table->enum('role', ['user', 'developer'])->index(); // ← インデックス追加
    $table->timestamps();
});

// 複合インデックス
$table->index(['role', 'created_at']);
```

**インデックスが有効なケース**:
- WHERE句で頻繁に検索されるカラム
- JOIN句で使用されるカラム
- ORDER BY句で使用されるカラム

**インデックスが不要なケース**:
- 値の種類が少ないカラム（boolean等）
- 頻繁に更新されるカラム
- テーブルサイズが小さい（〜1000行）

### 3. クエリの最適化

**Bad**:
```php
// 全カラム取得
$users = User::all();

// 不要なカラムも取得される
foreach ($users as $user) {
    echo $user->name;
}
```

**Good**:
```php
// 必要なカラムのみ取得
$users = User::select('id', 'name')->get();
```

**集計クエリ**:
```php
// Bad: PHP側で集計
$count = User::all()->count();

// Good: DB側で集計
$count = User::count();
```

### 4. ページネーション

**Bad**:
```php
// 全件取得（メモリ使用量大）
$users = User::all();
```

**Good**:
```php
// ページネーション
$users = User::paginate(20);

// または簡易ページネーション
$users = User::simplePaginate(20);
```

## キャッシュ戦略

### 1. ビューキャッシュ

```bash
# 本番環境デプロイ時
php artisan view:cache

# 開発時はクリア
php artisan view:clear
```

### 2. ルートキャッシュ

```bash
# 本番環境デプロイ時
php artisan route:cache

# 注意: クロージャを使ったルートはキャッシュできない
Route::get('/users', function () { ... }); // NG
Route::get('/users', [UserController::class, 'index']); // OK
```

### 3. 設定キャッシュ

```bash
# 本番環境デプロイ時
php artisan config:cache

# 注意: .envの変更は反映されない
```

### 4. データキャッシュ

**ファイルキャッシュ**:
```php
use Illuminate\Support\Facades\Cache;

// キャッシュに保存（60秒）
Cache::put('users_count', User::count(), 60);

// キャッシュから取得（なければクエリ実行）
$count = Cache::remember('users_count', 60, function () {
    return User::count();
});

// キャッシュ削除
Cache::forget('users_count');
```

**Redis/Memcached**:
```env
# .env
CACHE_DRIVER=redis
```

```php
// 同じAPI
Cache::put('key', 'value', 60);
```

## フロントエンド最適化

### 1. アセットの最小化

**Vite設定**:
```javascript
// vite.config.js
export default defineConfig({
    build: {
        minify: 'terser',
        rollupOptions: {
            output: {
                manualChunks: {
                    vendor: ['jquery', 'bootstrap']
                }
            }
        }
    }
});
```

```bash
# 本番ビルド
npm run build
```

### 2. 画像の最適化

**WebP形式への変換**:
```bash
# ImageMagickで変換
convert image.jpg -quality 80 image.webp
```

**Blade でのレスポンシブ画像**:
```blade
<picture>
    <source srcset="{{ asset('images/hero.webp') }}" type="image/webp">
    <img src="{{ asset('images/hero.jpg') }}" alt="Hero">
</picture>
```

### 3. Lazy Loading

**画像の遅延読み込み**:
```blade
<img src="{{ asset('images/placeholder.jpg') }}"
     data-src="{{ asset('images/large-image.jpg') }}"
     loading="lazy"
     alt="Large Image">
```

**JavaScript（Alpine.js）**:
```html
<div x-data="{ loaded: false }" x-intersect="loaded = true">
    <img x-show="loaded" :src="loaded ? 'image.jpg' : ''">
</div>
```

### 4. CDN活用

**静的ファイルをCDNから配信**:
```env
# .env
ASSET_URL=https://cdn.example.com
```

```blade
{{-- 自動的にCDN URLになる --}}
<img src="{{ asset('images/logo.png') }}">
```

## セッション・キュー最適化

### 1. セッションドライバー

**規模別推奨**:
```env
# 小規模: ファイル
SESSION_DRIVER=file

# 中規模: データベース
SESSION_DRIVER=database

# 大規模: Redis
SESSION_DRIVER=redis
```

### 2. キュー処理

**非同期処理**:
```php
use App\Jobs\SendWelcomeEmail;

// キューに追加（バックグラウンド実行）
SendWelcomeEmail::dispatch($user);

// 同期処理（即座に実行）
SendWelcomeEmail::dispatchSync($user);
```

```bash
# キューワーカー起動
php artisan queue:work

# 本番環境では Supervisor で監視
```

## パフォーマンス測定

### 1. Laravel Debugbar

```bash
composer require barryvdh/laravel-debugbar --dev
```

**確認項目**:
- クエリ数
- クエリ実行時間
- メモリ使用量
- ビューレンダリング時間

### 2. Laravel Telescope

```bash
composer require laravel/telescope
php artisan telescope:install
php artisan migrate
```

**機能**:
- リクエストログ
- クエリログ
- ジョブログ
- 例外ログ

### 3. Apache Bench (ab)

```bash
# 100リクエスト、同時接続10
ab -n 100 -c 10 https://your-domain.com/

# 結果
# Requests per second: 50.00 [#/sec]
# Time per request: 200.000 [ms]
```

### 4. Blackfire

```bash
# プロファイリングツール（有料）
blackfire run php artisan your:command
```

## 最適化チェックリスト

### デプロイ前

- [ ] `php artisan config:cache`
- [ ] `php artisan route:cache`
- [ ] `php artisan view:cache`
- [ ] `npm run build`
- [ ] `composer install --no-dev --optimize-autoloader`

### コード

- [ ] N+1問題がないか（Debugbarで確認）
- [ ] 不要なカラムを取得していないか
- [ ] インデックスが適切に設定されているか
- [ ] ページネーションを使用しているか
- [ ] キャッシュを活用しているか

### フロントエンド

- [ ] 画像を最適化しているか（WebP等）
- [ ] アセットを最小化しているか
- [ ] Lazy Loadingを使用しているか
- [ ] CDNを活用しているか

## 目標値

### レスポンスタイム

| ページ | 目標 | 許容 |
|--------|------|------|
| トップページ | < 1秒 | < 2秒 |
| 一覧ページ | < 1秒 | < 2秒 |
| 詳細ページ | < 0.5秒 | < 1秒 |
| API | < 200ms | < 500ms |

### データベースクエリ

| 指標 | 目標 | 許容 |
|------|------|------|
| 1ページあたりのクエリ数 | < 10 | < 20 |
| クエリ実行時間 | < 50ms | < 100ms |

### メモリ

| 指標 | 目標 | 許容 |
|------|------|------|
| 1リクエストあたり | < 10MB | < 20MB |

## トラブルシューティング

### 遅いページの特定

```bash
# ログでレスポンスタイムを確認
tail -f storage/logs/laravel.log

# 遅いクエリの特定
# config/database.php
'slow_query_log' => true,
```

### メモリ不足

```php
// メモリ使用量を確認
memory_get_usage(true);

// チャンク処理で対応
User::chunk(100, function ($users) {
    foreach ($users as $user) {
        // 処理
    }
});
```

## まとめ

### 優先順位

1. **N+1問題の解消**（最大の効果）
2. **適切なインデックス設定**
3. **キャッシュの活用**
4. **ページネーション**
5. **アセット最適化**

### 計測→改善のサイクル

```
1. パフォーマンス計測（Debugbar, ab）
  ↓
2. ボトルネック特定
  ↓
3. 改善実施
  ↓
4. 再計測
  ↓
5. 目標達成まで繰り返し
```

---

**関連ドキュメント**:
- [コーディング規約](./CODING_STANDARDS.md)
- [サーバープラン選定ガイド](./SERVER_PLANNING.md)
- [ケーススタディ](./CASE_STUDIES.md)
