# 完全セットアップガイド

このドキュメントは、miyabi-claude-projectをクローンしてから開発を開始するまでの完全な手順を説明します。

## 目次

1. [前提条件](#前提条件)
2. [リポジトリのクローン](#リポジトリのクローン)
3. [環境変数の設定](#環境変数の設定)
4. [Miyabiの設定](#miyabiの設定)
5. [Claude Codeの設定](#claude-codeの設定)
6. [Laravel環境のセットアップ](#laravel環境のセットアップ)
7. [セットアップの検証](#セットアップの検証)
8. [次のステップ](#次のステップ)

## 前提条件

以下のツールがインストールされている必要があります：

### 必須ツール

- **Git**: バージョン管理
- **GitHub CLI (gh)**: GitHubとの連携
- **Miyabi CLI**: タスク自動化
- **PHP 8.2+**: Laravel実行環境
- **Composer**: PHP依存関係管理
- **Claude Code**: AI開発アシスタント

### オプションツール

- **Node.js**: フロントエンド開発
- **npm/yarn/pnpm**: JavaScriptパッケージ管理

### インストール確認

```bash
# バージョン確認
git --version
gh --version
miyabi --version
php --version
composer --version
```

## リポジトリのクローン

### 1. GitHubからクローン

```bash
# HTTPSでクローン
git clone https://github.com/UozumiMimicopy/miyabi-claude-project.git

# もしくはSSHでクローン
git clone git@github.com:UozumiMimicopy/miyabi-claude-project.git

# プロジェクトディレクトリに移動
cd miyabi-claude-project
```

### 2. ディレクトリ構造の確認

```bash
tree -L 2 -a
```

期待される構造：
```
miyabi-claude-project/
├── .claude/
│   ├── agents/
│   └── settings.local.json
├── .github/
│   └── ISSUE_TEMPLATE/
├── .miyabi.yml
├── docs/
│   ├── development-guide.md
│   ├── MIYABI_CLAUDE_COLLABORATION.md
│   └── SETUP.md
├── laravel-app/
├── logs/
├── reports/
├── MIYABI_SETUP.md
└── README.md
```

## 環境変数の設定

### 1. GitHub認証

```bash
# GitHub CLIでログイン
gh auth login

# トークンを確認
gh auth status
```

### 2. 環境変数ファイルの作成

プロジェクトルートに `.env` ファイルを作成（オプション）：

```bash
# .env
GITHUB_TOKEN=your_github_token_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# Miyabi設定
RUST_LOG=info
RUST_BACKTRACE=1
LOG_DIRECTORY=logs
REPORT_DIRECTORY=reports

# 並列実行設定
DEFAULT_CONCURRENCY=2
USE_WORKTREE=true
WORKTREE_BASE_DIR=.worktrees
```

### 3. 環境変数の読み込み

```bash
# .envファイルを読み込む場合
source .env

# もしくは、シェル設定ファイルに追加
echo 'export ANTHROPIC_API_KEY="your_key"' >> ~/.bashrc
source ~/.bashrc
```

## Miyabiの設定

### 1. 設定ファイルの確認

`.miyabi.yml` が正しく設定されているか確認：

```bash
cat .miyabi.yml
```

### 2. Miyabiの初期化確認

```bash
# プロジェクト状態の確認
miyabi status

# JSON形式で確認
miyabi --json status
```

### 3. ログディレクトリの作成（必要に応じて）

```bash
mkdir -p logs reports
```

## Claude Codeの設定

### 1. 権限設定の確認

`.claude/settings.local.json` が存在することを確認：

```bash
cat .claude/settings.local.json
```

### 2. エージェントディレクトリの確認

```bash
ls -la .claude/agents/
```

### 3. Claude Codeでプロジェクトを開く

```bash
# Claude Codeでプロジェクトを開く
claude-code .
```

## Laravel環境のセットアップ

### 1. Laravel依存関係のインストール

```bash
cd laravel-app

# Composer依存関係のインストール
composer install

# Node.js依存関係のインストール（必要に応じて）
npm install
```

### 2. Laravel環境設定

```bash
# .envファイルをコピー
cp .env.example .env

# アプリケーションキーの生成
php artisan key:generate

# データベースファイルの作成（SQLiteの場合）
touch database/database.sqlite

# データベースマイグレーション
php artisan migrate
```

### 3. Laravel開発サーバーの起動

```bash
# 開発サーバーを起動
php artisan serve
```

ブラウザで `http://localhost:8000` にアクセスして動作確認。

## セットアップの検証

### チェックリスト

以下の項目を確認してください：

- [ ] `miyabi --version` が動作する
- [ ] `GITHUB_TOKEN` 環境変数が設定されている
- [ ] Gitリポジトリとして認識されている
- [ ] `.claude/agents/` ディレクトリが存在する
- [ ] `.claude/settings.local.json` が存在する
- [ ] `.miyabi.yml` が正しく設定されている
- [ ] `logs/` と `reports/` ディレクトリが存在する
- [ ] Gitユーザーがグローバルまたはローカルで設定されている
- [ ] `ANTHROPIC_API_KEY` が設定されている（オプション）
- [ ] Laravel依存関係がインストールされている
- [ ] Laravelが正常に起動する

### 動作確認コマンド

```bash
# 1. Miyabi動作確認
miyabi status

# 2. GitHub CLI動作確認
gh auth status

# 3. Git設定確認
git config --list

# 4. Laravel動作確認
cd laravel-app
php artisan --version
```

## 次のステップ

### 1. 最初のIssueを作成

```bash
# GitHub UIから、または
gh issue create --title "First Task" --body "Description"
```

### 2. Miyabiでタスクを開始

```bash
# Issue #2で作業を開始
miyabi work-on 2

# Plans.mdを確認
cat Plans.md
```

### 3. Claude Codeで実装

1. Plans.mdをレビュー
2. タスクを実装
3. 適切なコミットメッセージでコミット
4. Issueに進捗を報告

### 4. ドキュメントを読む

- [開発ガイド](development-guide.md)
- [Miyabi + Claude Code連携ガイド](MIYABI_CLAUDE_COLLABORATION.md)
- [Miyabiセットアップ](../MIYABI_SETUP.md)

## トラブルシューティング

### Miyabiが認識されない

```bash
# Miyabiのパスを確認
which miyabi

# パスが通っていない場合、PATHに追加
export PATH=$PATH:/path/to/miyabi
```

### GitHub認証エラー

```bash
# 再ログイン
gh auth logout
gh auth login
```

### Laravel起動エラー

```bash
# 権限エラーの場合
chmod -R 775 storage bootstrap/cache

# キャッシュクリア
php artisan cache:clear
php artisan config:clear
```

### Plans.mdが生成されない

- Issue番号が正しいか確認
- `.miyabi.yml` の `repo` 設定が正しいか確認
- GitHub Tokenが有効か確認

## サポート

問題が解決しない場合は、GitHubのIssueを作成してください：

```bash
gh issue create --title "Setup Issue: [問題の概要]" --body "詳細な説明"
```

または、以下のドキュメントを参照：

- [README.md](../README.md)
- [MIYABI_SETUP.md](../MIYABI_SETUP.md)
- [MIYABI_CLAUDE_COLLABORATION.md](MIYABI_CLAUDE_COLLABORATION.md)
