# Laravel コーディング規約・設計パターン

保守性・拡張性の高いコードを書くための指針。

## 目的

- コードの可読性向上
- 技術的負債の削減
- チーム開発の円滑化
- セキュリティリスクの軽減

## Laravel設計パターン

### MVC + Service層アーキテクチャ

```
Request
  ↓
Controller（ルーティング・バリデーション）
  ↓
Service（ビジネスロジック）
  ↓
Model / Repository（データアクセス）
  ↓
Database
```

### コントローラーの責務

**Good**:
```php
class UserController extends Controller
{
    public function store(StoreUserRequest $request)
    {
        // リクエスト検証（FormRequest）
        $validated = $request->validated();

        // サービス層への委譲
        $user = app(UserService::class)->create($validated);

        // レスポンス返却
        return redirect()->route('users.show', $user)
            ->with('success', 'ユーザーを作成しました');
    }
}
```

**Bad**:
```php
class UserController extends Controller
{
    public function store(Request $request)
    {
        // バリデーション
        $request->validate([...]);

        // ビジネスロジックをコントローラーに書く（NG）
        $user = User::create($request->all());

        if ($user->role === 'developer') {
            // 複雑な処理（NG）
            ...
        }

        return redirect()->route('users.show', $user);
    }
}
```

**原則**:
- ✅ リクエスト検証
- ✅ サービス層への委譲
- ✅ レスポンス返却
- ❌ ビジネスロジックをコントローラーに書かない

### サービス層の活用

複雑なビジネスロジックはServiceクラスへ分離。

```php
// app/Services/UserService.php
namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserService
{
    public function create(array $data): User
    {
        // 複雑なビジネスロジック
        $data['password'] = Hash::make($data['password']);

        $user = User::create($data);

        // メール送信等の副作用
        $user->sendWelcomeEmail();

        return $user;
    }

    public function updateRole(User $user, string $role): User
    {
        $user->update(['role' => $role]);

        // ロール変更時の追加処理
        if ($role === 'developer') {
            $this->grantDeveloperPermissions($user);
        }

        return $user;
    }

    private function grantDeveloperPermissions(User $user): void
    {
        // 権限付与ロジック
    }
}
```

**適用ケース**:
- 複数モデルにまたがる処理
- 外部API連携
- 複雑な計算・集計
- トランザクション処理

### リポジトリパターン（必要に応じて）

データアクセスの抽象化。テスタビリティ向上。

```php
// app/Repositories/UserRepository.php
namespace App\Repositories;

use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

class UserRepository
{
    public function findByEmail(string $email): ?User
    {
        return User::where('email', $email)->first();
    }

    public function getDevelopers(): Collection
    {
        return User::where('role', 'developer')->get();
    }

    public function create(array $data): User
    {
        return User::create($data);
    }
}
```

**適用ケース**:
- 複雑なクエリの再利用
- テストでのモック化
- データソースの抽象化（将来的なDB変更等）

**注意**: 小規模プロジェクトでは過剰設計になるため、Eloquentの直接使用でOK。

## セキュリティベストプラクティス

### 1. SQLインジェクション対策

**Good** (Eloquent ORM):
```php
// プレースホルダー使用
$users = User::where('email', $email)->get();

// パラメータバインディング
$users = DB::select('SELECT * FROM users WHERE email = ?', [$email]);
```

**Bad** (生SQLの直接実行):
```php
// 危険！
$users = DB::select("SELECT * FROM users WHERE email = '$email'");
```

### 2. XSS対策

**Good** (Bladeエスケープ):
```blade
{{-- 自動エスケープ --}}
<p>{{ $user->name }}</p>

{{-- HTMLとして出力（信頼できるデータのみ） --}}
<div>{!! $trustedHtml !!}</div>
```

**Bad**:
```blade
{{-- エスケープなし（危険） --}}
<p><?php echo $user->name; ?></p>
```

### 3. CSRF対策

**Good**:
```blade
<form method="POST" action="{{ route('users.store') }}">
    @csrf
    {{-- フォーム内容 --}}
</form>
```

### 4. 認証・認可

**認証** (Laravel Breeze/Fortify):
```php
// ルート保護
Route::middleware('auth')->group(function () {
    Route::get('/dashboard', ...);
});
```

**認可** (Policy/Gate):
```php
// app/Policies/UserPolicy.php
public function update(User $authUser, User $user): bool
{
    return $authUser->id === $user->id || $authUser->role === 'developer';
}

// コントローラーで使用
public function update(Request $request, User $user)
{
    $this->authorize('update', $user);

    // 更新処理
}
```

### 5. Mass Assignment対策

**Good**:
```php
// app/Models/User.php
class User extends Model
{
    protected $fillable = ['name', 'email', 'password'];

    protected $guarded = ['role']; // 保護
}
```

## コーディング規約

### 命名規則

| 対象 | 規則 | 例 |
|-----|------|-----|
| クラス | PascalCase | `UserController`, `UserService` |
| メソッド | camelCase | `getUsers()`, `createUser()` |
| 変数 | camelCase | `$userName`, `$isActive` |
| 定数 | UPPER_SNAKE_CASE | `MAX_USERS`, `API_VERSION` |
| テーブル | snake_case（複数形） | `users`, `blog_posts` |
| カラム | snake_case | `created_at`, `user_id` |

### ディレクトリ構造

```
app/
├── Http/
│   ├── Controllers/      # コントローラー
│   ├── Middleware/       # ミドルウェア
│   └── Requests/         # FormRequest
├── Models/               # Eloquentモデル
├── Services/             # ビジネスロジック
├── Repositories/         # データアクセス（必要に応じて）
└── Policies/             # 認可ロジック

resources/
├── views/
│   ├── layouts/          # レイアウト
│   ├── components/       # コンポーネント
│   └── [domain]/         # ドメインごとのビュー

database/
├── migrations/           # マイグレーション
├── seeders/              # シーダー
└── factories/            # ファクトリ
```

### コメント

**Good**:
```php
/**
 * ユーザーをアクティブ化する
 *
 * @param User $user
 * @return bool
 * @throws ActivationException ユーザーが既にアクティブな場合
 */
public function activate(User $user): bool
{
    if ($user->is_active) {
        throw new ActivationException('User is already active');
    }

    return $user->update(['is_active' => true]);
}
```

**Bad**:
```php
// ユーザーをアクティブにする関数
public function activate($user)
{
    // アクティブフラグをtrueにする
    $user->is_active = true;
    // 保存
    $user->save();
    // trueを返す
    return true;
}
```

**原則**:
- 「何をするか」ではなく「なぜそうするか」を書く
- 自明なコメントは不要
- 複雑なロジックには必ずコメント

## ベストプラクティス

### 1. Eloquentリレーションの活用

```php
// app/Models/User.php
class User extends Model
{
    public function posts()
    {
        return $this->hasMany(Post::class);
    }
}

// N+1問題の回避
$users = User::with('posts')->get();
```

### 2. FormRequestでバリデーション

```php
// app/Http/Requests/StoreUserRequest.php
class StoreUserRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users',
            'password' => 'required|min:8|confirmed',
        ];
    }

    public function messages(): array
    {
        return [
            'email.unique' => 'このメールアドレスは既に登録されています',
        ];
    }
}
```

### 3. Enum（PHP 8.1+）の活用

```php
// app/Enums/UserRole.php
enum UserRole: string
{
    case USER = 'user';
    case DEVELOPER = 'developer';
}

// マイグレーション
$table->enum('role', ['user', 'developer'])->default('user');

// モデル
protected function casts(): array
{
    return [
        'role' => UserRole::class,
    ];
}
```

### 4. Scopeでクエリの再利用

```php
// app/Models/User.php
public function scopeDevelopers($query)
{
    return $query->where('role', 'developer');
}

// 使用
$developers = User::developers()->get();
```

## チェックリスト

### コードレビュー時

- [ ] コントローラーにビジネスロジックが含まれていないか
- [ ] SQLインジェクションのリスクはないか
- [ ] XSSのリスクはないか
- [ ] CSRF対策がされているか
- [ ] 認証・認可が適切か
- [ ] N+1問題は発生しないか
- [ ] 変数名・メソッド名は適切か
- [ ] コメントは十分か
- [ ] テストは書かれているか

## まとめ

### 最重要ポイント

1. **コントローラーは薄く、サービス層を厚く**
2. **Eloquent ORMでSQLインジェクション対策**
3. **Bladeでエスケープ、XSS対策**
4. **Policy/Gateで認可ロジックを分離**
5. **N+1問題に注意**

### 次のステップ

- [パフォーマンス最適化ガイド](./PERFORMANCE_OPTIMIZATION.md)でN+1問題の詳細を学ぶ
- [テスト戦略](./TESTING_STRATEGY.md)で品質担保
- [ケーススタディ](./CASE_STUDIES.md)で実践例を参照

---

**関連ドキュメント**:
- [パフォーマンス最適化ガイド](./PERFORMANCE_OPTIMIZATION.md)
- [テスト戦略](./TESTING_STRATEGY.md)
- [開発ワークフロー](./DEVELOPMENT_WORKFLOW.md)
