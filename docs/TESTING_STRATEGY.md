# テスト戦略

品質保証と継続的インテグレーションのためのテスト戦略。

## 目的

- バグの早期発見
- リファクタリングの安全性確保
- ドキュメントとしての役割
- 継続的な品質維持

## テストピラミッド

```
       /\
      /  \   E2E Tests (Browser Tests)
     /    \  少ない、遅い、高コスト
    /------\
   /        \ Feature Tests (HTTP Tests)
  /          \ 中程度、適度な速度
 /------------\
/              \ Unit Tests
----------------  多い、速い、低コスト
```

### 比率の目安

- Unit Tests: 70%
- Feature Tests: 20%
- E2E Tests: 10%

## Unit Tests（単体テスト）

### 対象

- モデルのメソッド
- サービスクラスのロジック
- ヘルパー関数
- バリデーションルール

### 例: モデルのテスト

```php
// tests/Unit/UserTest.php
namespace Tests\Unit;

use App\Models\User;
use Tests\TestCase;

class UserTest extends TestCase
{
    public function test_user_has_full_name_attribute(): void
    {
        $user = new User([
            'first_name' => 'John',
            'last_name' => 'Doe',
        ]);

        $this->assertEquals('John Doe', $user->full_name);
    }

    public function test_user_can_check_if_developer(): void
    {
        $user = new User(['role' => 'developer']);

        $this->assertTrue($user->isDeveloper());
    }
}
```

### 例: サービスクラスのテスト

```php
// tests/Unit/UserServiceTest.php
namespace Tests\Unit;

use App\Services\UserService;
use App\Models\User;
use Tests\TestCase;

class UserServiceTest extends TestCase
{
    public function test_create_user_hashes_password(): void
    {
        $service = new UserService();

        $user = $service->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => 'plain-password',
        ]);

        $this->assertNotEquals('plain-password', $user->password);
        $this->assertTrue(Hash::check('plain-password', $user->password));
    }
}
```

## Feature Tests（機能テスト）

### 対象

- HTTP リクエスト/レスポンス
- 認証フロー
- データベース連携
- セッション

### 例: 認証テスト

```php
// tests/Feature/Auth/LoginTest.php
namespace Tests\Feature\Auth;

use App\Models\User;
use Tests\TestCase;

class LoginTest extends TestCase
{
    public function test_users_can_authenticate(): void
    {
        $user = User::factory()->create();

        $response = $this->post('/login', [
            'email' => $user->email,
            'password' => 'password',
        ]);

        $this->assertAuthenticated();
        $response->assertRedirect('/dashboard');
    }

    public function test_users_cannot_authenticate_with_invalid_password(): void
    {
        $user = User::factory()->create();

        $this->post('/login', [
            'email' => $user->email,
            'password' => 'wrong-password',
        ]);

        $this->assertGuest();
    }
}
```

### 例: CRUD テスト

```php
// tests/Feature/StoreManagementTest.php
namespace Tests\Feature;

use App\Models\Store;
use App\Models\User;
use Tests\TestCase;

class StoreManagementTest extends TestCase
{
    public function test_developers_can_create_store(): void
    {
        $developer = User::factory()->create(['role' => 'developer']);

        $response = $this->actingAs($developer)->post('/stores', [
            'name' => 'Test Store',
            'address' => '123 Main St',
        ]);

        $response->assertRedirect('/stores');
        $this->assertDatabaseHas('stores', [
            'name' => 'Test Store',
        ]);
    }

    public function test_regular_users_cannot_create_store(): void
    {
        $user = User::factory()->create(['role' => 'user']);

        $response = $this->actingAs($user)->post('/stores', [
            'name' => 'Test Store',
        ]);

        $response->assertForbidden();
    }
}
```

## Browser Tests（E2Eテスト）

### Laravel Dusk

```bash
composer require --dev laravel/dusk
php artisan dusk:install
```

### 例: ログインフロー

```php
// tests/Browser/LoginTest.php
namespace Tests\Browser;

use App\Models\User;
use Laravel\Dusk\Browser;
use Tests\DuskTestCase;

class LoginTest extends DuskTestCase
{
    public function test_user_can_login(): void
    {
        $user = User::factory()->create();

        $this->browse(function (Browser $browser) use ($user) {
            $browser->visit('/login')
                    ->type('email', $user->email)
                    ->type('password', 'password')
                    ->press('Log in')
                    ->assertPathIs('/dashboard')
                    ->assertSee('Dashboard');
        });
    }
}
```

## データベーステスト

### テストデータベース

```env
# .env.testing
DB_CONNECTION=sqlite
DB_DATABASE=:memory:
```

### マイグレーション・シード

```php
use Illuminate\Foundation\Testing\RefreshDatabase;

class UserTest extends TestCase
{
    use RefreshDatabase;

    public function test_example(): void
    {
        // 各テストの前にマイグレーション実行
        // 各テストの後にロールバック
    }
}
```

### ファクトリの活用

```php
// database/factories/UserFactory.php
public function definition(): array
{
    return [
        'name' => fake()->name(),
        'email' => fake()->unique()->safeEmail(),
        'password' => Hash::make('password'),
        'role' => 'user',
    ];
}

public function developer(): static
{
    return $this->state(fn () => ['role' => 'developer']);
}

// テストで使用
$user = User::factory()->create();
$developer = User::factory()->developer()->create();
$users = User::factory()->count(10)->create();
```

## モック・スタブ

### 外部APIのモック

```php
use Illuminate\Support\Facades\Http;

public function test_api_call(): void
{
    Http::fake([
        'api.example.com/*' => Http::response(['data' => 'value'], 200)
    ]);

    $response = Http::get('https://api.example.com/data');

    $this->assertEquals('value', $response->json()['data']);
}
```

### メール送信のモック

```php
use Illuminate\Support\Facades\Mail;
use App\Mail\WelcomeMail;

public function test_welcome_email_sent(): void
{
    Mail::fake();

    // メール送信を伴う処理
    $user = User::factory()->create();

    Mail::assertSent(WelcomeMail::class, function ($mail) use ($user) {
        return $mail->user->id === $user->id;
    });
}
```

## カバレッジ目標

### 目標カバレッジ

```
全体: 80%以上
├─ Models: 90%以上
├─ Services: 85%以上
├─ Controllers: 70%以上
└─ Views: 測定対象外
```

### カバレッジ計測

```bash
# Xdebug有効化
php --ini | grep xdebug

# テスト実行（カバレッジ出力）
php artisan test --coverage

# 最小カバレッジ設定
php artisan test --coverage --min=80
```

## CI/CD（GitHub Actions）

### ワークフロー例

```yaml
# .github/workflows/tests.yml
name: Tests

on:
  push:
    branches: [master, develop]
  pull_request:
    branches: [master, develop]

jobs:
  tests:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'
          extensions: mbstring, pdo, pdo_mysql

      - name: Install Dependencies
        run: composer install --no-progress --prefer-dist

      - name: Copy .env
        run: cp .env.example .env.testing

      - name: Generate key
        run: php artisan key:generate --env=testing

      - name: Run Tests
        run: php artisan test --coverage --min=80

      - name: Upload Coverage
        uses: codecov/codecov-action@v3
```

## テスト実行

### 全テスト実行

```bash
php artisan test
```

### 特定のテスト実行

```bash
# 1ファイル
php artisan test tests/Feature/Auth/LoginTest.php

# 1メソッド
php artisan test --filter test_users_can_authenticate
```

### 並列実行

```bash
php artisan test --parallel
```

## テストのベストプラクティス

### 1. テストは独立させる

**Bad**:
```php
// test_a が先に実行される前提（NG）
public function test_a(): void
{
    $user = User::factory()->create(['id' => 1]);
}

public function test_b(): void
{
    $user = User::find(1); // test_a に依存（NG）
}
```

**Good**:
```php
public function test_a(): void
{
    $user = User::factory()->create();
}

public function test_b(): void
{
    $user = User::factory()->create(); // 独立
}
```

### 2. Arrange-Act-Assert パターン

```php
public function test_example(): void
{
    // Arrange: 準備
    $user = User::factory()->create();

    // Act: 実行
    $response = $this->actingAs($user)->get('/dashboard');

    // Assert: 検証
    $response->assertOk();
    $response->assertSee('Dashboard');
}
```

### 3. 1テスト1検証

**Bad**:
```php
public function test_user_operations(): void
{
    // 複数の検証（NG）
    $this->assertTrue($user->isDeveloper());
    $this->assertEquals('John', $user->name);
    $this->assertNotNull($user->email);
}
```

**Good**:
```php
public function test_user_is_developer(): void
{
    $this->assertTrue($user->isDeveloper());
}

public function test_user_has_name(): void
{
    $this->assertEquals('John', $user->name);
}
```

### 4. わかりやすいテスト名

```php
// Good
test_users_can_authenticate()
test_users_cannot_authenticate_with_invalid_password()
test_developers_can_create_store()
test_regular_users_cannot_create_store()

// Bad
test_login()
test_store()
```

## テストチェックリスト

### テスト作成時

- [ ] Arrange-Act-Assert パターンを守っているか
- [ ] 1テスト1検証になっているか
- [ ] テスト名はわかりやすいか
- [ ] テストは独立しているか
- [ ] エッジケースをテストしているか

### プルリクエスト前

- [ ] 全テストが通るか
- [ ] カバレッジは80%以上か
- [ ] 新機能にテストを追加したか
- [ ] バグ修正に回帰テストを追加したか

## まとめ

### 優先順位

1. **Feature Tests（認証、CRUD）** → 最優先
2. **Unit Tests（ビジネスロジック）** → 次点
3. **Browser Tests（重要フロー）** → 最小限

### テスト駆動開発（TDD）

```
1. テストを書く（Red）
  ↓
2. 実装する（Green）
  ↓
3. リファクタリング（Refactor）
  ↓
4. 繰り返し
```

### CI/CD統合

- GitHub ActionsでPR時に自動テスト
- カバレッジ80%未満は失敗させる
- デプロイ前に必ずテスト実行

---

**関連ドキュメント**:
- [コーディング規約](./CODING_STANDARDS.md)
- [パフォーマンス最適化](./PERFORMANCE_OPTIMIZATION.md)
- [開発ワークフロー](./DEVELOPMENT_WORKFLOW.md)
