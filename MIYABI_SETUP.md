# Miyabi セットアップガイド

このドキュメントは、miyabiの基本的なセットアップと使用方法を説明します。

## 前提条件

- Git がインストールされていること
- GitHub CLI (`gh`) がインストールされていること
- Miyabi CLI がインストールされていること

## 環境変数の設定

### 必須の環境変数

```bash
# GitHub Token（gh authで自動設定されます）
gh auth login

# もしくは手動で設定
export GITHUB_TOKEN="your_github_token_here"
```

### オプションの環境変数

```bash
# Anthropic API Key（AI機能を使う場合）
export ANTHROPIC_API_KEY="your_anthropic_api_key_here"

# ログとレポートの設定
export RUST_LOG=info
export RUST_BACKTRACE=1
export LOG_DIRECTORY=logs
export REPORT_DIRECTORY=reports

# 並列実行の設定
export DEFAULT_CONCURRENCY=2
export USE_WORKTREE=true
export WORKTREE_BASE_DIR=.worktrees
```

## Miyabi の基本コマンド

### プロジェクトの状態確認

```bash
# プロジェクトの状態を表示
miyabi status

# JSON形式で出力（AI解析用）
miyabi --json status
```

### Issue での作業開始

```bash
# Issue #1で作業を開始
miyabi work-on 1

# Plans.md が生成されるので、内容を確認
cat Plans.md
```

### エージェントの実行

```bash
# 全エージェントを実行
miyabi agent

# 特定のエージェントを実行
miyabi agent run coordinator
miyabi agent run codegen
miyabi agent run review
```

### 並列実行

```bash
# 複数のIssueを並列処理
miyabi parallel --issues 1,2,3
```

## ディレクトリ構造

Miyabiは以下のディレクトリ構造を使用します：

```
project-root/
├── .miyabi.yml              # Miyabi設定ファイル
├── .claude/                 # Claude Code設定
│   ├── agents/             # カスタムエージェント定義
│   └── settings.local.json # Claude Code権限設定
├── logs/                    # エージェント実行ログ（gitignore）
├── reports/                 # レポート出力（gitignore）
└── Plans.md                 # タスク分解結果（自動生成）
```

## Claude Code との連携

Miyabiで生成された `Plans.md` は、Claude Codeが実装の参考にします。

### 基本的なワークフロー

1. **Issue作成**: GitHubでIssueを作成
2. **Miyabi実行**: `miyabi work-on <issue-number>`
3. **Plans.md確認**: 生成されたタスク分解を確認
4. **Claude Code実装**: Plans.mdを参考に実装
5. **コミット**: 適切なコミットメッセージで保存
6. **進捗報告**: Issueにコメントで報告

## トラブルシューティング

### Miyabiが認識されない

```bash
# Miyabiのバージョン確認
miyabi --version

# インストールされていない場合はインストール
# （インストール方法はMiyabiの公式ドキュメントを参照）
```

### GitHub Tokenが設定されていない

```bash
# GitHub CLIでログイン
gh auth login

# 手動で環境変数を設定
export GITHUB_TOKEN="your_token_here"
```

### Plans.mdが生成されない

- Issue番号が正しいか確認
- `.miyabi.yml` の設定が正しいか確認
- Gitリポジトリとして認識されているか確認

## 次のステップ

詳細な連携方法については、以下のドキュメントを参照してください：

- [Miyabi + Claude Codeの連携ガイド](docs/MIYABI_CLAUDE_COLLABORATION.md)
- [完全セットアップガイド](docs/SETUP.md)
- [開発ガイド](docs/development-guide.md)
