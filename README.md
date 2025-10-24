# miyabi-claude-project

Miyabi + Claude Code を活用した開発のためのテンプレートリポジトリ

## 概要

このリポジトリは、**Miyabi**（タスク自動化フレームワーク）と**Claude Code**（AI開発アシスタント）を組み合わせた効率的な開発環境のテンプレートです。クローンするだけで、すぐに開発を開始できるように設定されています。

### 特徴

- ✅ **Miyabi設定済み**: `.miyabi.yml` で即座に使える
- ✅ **Claude Code統合**: 適切な権限設定とエージェント構成
- ✅ **Laravel 12.x**: 最新のLaravelがすぐに使える
- ✅ **Issue テンプレート**: 標準化されたGitHub Issueテンプレート
- ✅ **ドキュメント完備**: セットアップから開発フローまで完全ガイド
- ✅ **セットアップスクリプト**: 自動化されたプロジェクト初期化

## クイックスタート

### 1. リポジトリのクローン

```bash
git clone https://github.com/UozumiMimicopy/miyabi-claude-project.git
cd miyabi-claude-project
```

### 2. セットアップスクリプトの実行

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### 3. 開発開始

```bash
# 最初のIssueを作成
gh issue create --title "First Task" --body "Description"

# Miyabiでタスクを開始
miyabi work-on 2

# Plans.mdを確認
cat Plans.md

# Claude Codeで実装開始
```

## ディレクトリ構造

```
miyabi-claude-project/
├── .claude/                      # Claude Code設定
│   ├── agents/                  # カスタムエージェント定義
│   └── settings.local.json      # Claude Code権限設定
├── .github/
│   └── ISSUE_TEMPLATE/          # GitHub Issueテンプレート
│       ├── task.md              # タスク用
│       ├── progress_report.md   # 進捗報告用
│       ├── tracking.md          # 追跡用
│       ├── bug_report.md        # バグ報告用
│       └── research.md          # 調査用
├── .miyabi.yml                   # Miyabi設定ファイル
├── docs/                         # ドキュメント
│   ├── development-guide.md     # 開発ガイド
│   ├── MIYABI_CLAUDE_COLLABORATION.md  # 連携ガイド
│   └── SETUP.md                 # 完全セットアップガイド
├── laravel-app/                  # Laravel アプリケーション
├── logs/                         # Miyabiログ（gitignore）
├── reports/                      # レポート出力（gitignore）
├── scripts/
│   └── setup.sh                 # セットアップスクリプト
├── MIYABI_SETUP.md              # Miyabi基本ガイド
└── README.md                     # このファイル
```

## 開発ワークフロー

### 3つのワークフローパターン

このテンプレートは、タスクの規模に応じた3つのワークフローパターンをサポートしています：

#### パターンA: Miyabi-First（大規模タスク向け）

```
Issue作成 → miyabi work-on → Plans.md生成 → Claude Code実装
```

**推奨**: 10ファイル以上の変更が必要な場合

#### パターンB: Claude Code-First（小規模タスク向け）

```
タスク理解 → Claude Code直接実装 → Commit
```

**推奨**: 1-3ファイル程度の変更

#### パターンC: Explore-First（調査が必要な場合）

```
Exploreエージェント → 分析 → Claude Code実装
```

**推奨**: コードベースの理解が必要な場合

詳細は [MIYABI_CLAUDE_COLLABORATION.md](docs/MIYABI_CLAUDE_COLLABORATION.md) を参照。

## ドキュメント

- **[SETUP.md](docs/SETUP.md)**: 完全なセットアップガイド
- **[MIYABI_SETUP.md](MIYABI_SETUP.md)**: Miyabiの基本的な使い方
- **[MIYABI_CLAUDE_COLLABORATION.md](docs/MIYABI_CLAUDE_COLLABORATION.md)**: Miyabi + Claude Codeの連携方法
- **[development-guide.md](docs/development-guide.md)**: プロジェクト構成と開発方針

## 前提条件

このテンプレートを使用するには、以下のツールが必要です：

- Git
- GitHub CLI (`gh`)
- Miyabi CLI
- PHP 8.2+
- Composer
- Claude Code

インストール確認：

```bash
git --version
gh --version
miyabi --version
php --version
composer --version
```

## 環境変数

### 必須

```bash
# GitHub認証（gh auth loginで自動設定）
gh auth login
```

### オプション

```bash
# Anthropic API Key（AI機能を使用する場合）
export ANTHROPIC_API_KEY="your_key_here"

# Miyabiログ設定
export RUST_LOG=info
export LOG_DIRECTORY=logs
export REPORT_DIRECTORY=reports
```

## 使い方

### 1. Issueの作成

```bash
# GitHub UIから、または
gh issue create --title "[TASK] Feature implementation" --body "..."
```

### 2. Miyabiで作業開始

```bash
miyabi work-on 2
```

### 3. Plans.mdの確認

```bash
cat Plans.md
```

### 4. Claude Codeで実装

Plans.mdを参考にして実装し、適切なコミットメッセージでコミット：

```bash
git commit -m "$(cat <<'EOF'
Add feature implementation

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### 5. 進捗報告

```bash
gh issue comment 2 --body "## 進捗報告..."
```

## テンプレートとして使う

このリポジトリを新しいプロジェクトのベースとして使用する場合：

1. **リポジトリをクローン**:
   ```bash
   git clone https://github.com/UozumiMimicopy/miyabi-claude-project.git my-new-project
   cd my-new-project
   ```

2. **Gitの再初期化**:
   ```bash
   rm -rf .git
   git init
   ```

3. **`.miyabi.yml`を更新**:
   ```yaml
   github:
     owner: YourUsername
     repo: your-new-project
   ```

4. **セットアップ実行**:
   ```bash
   ./scripts/setup.sh
   ```

5. **新しいリモートリポジトリを作成してプッシュ**:
   ```bash
   gh repo create your-new-project --public --source=. --remote=origin --push
   ```

## トラブルシューティング

### Miyabiが認識されない

```bash
which miyabi  # パスを確認
export PATH=$PATH:/path/to/miyabi
```

### GitHub認証エラー

```bash
gh auth logout
gh auth login
```

### Laravel起動エラー

```bash
cd laravel-app
chmod -R 775 storage bootstrap/cache
php artisan cache:clear
php artisan config:clear
```

詳細は [docs/SETUP.md](docs/SETUP.md) のトラブルシューティングセクションを参照。

## ライセンス

Apache-2.0 License

## サポート

問題や質問がある場合は、GitHubのIssueを作成してください：

```bash
gh issue create --title "Question: ..." --body "..."
```

## 貢献

このテンプレートの改善提案は歓迎します！Pull Requestをお待ちしています。
