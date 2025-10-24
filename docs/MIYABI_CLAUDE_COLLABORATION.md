# Miyabi + Claude Code 連携ガイド

このドキュメントでは、MiyabiとClaude Codeを効果的に連携させる方法を説明します。

## 目次

1. [3つのワークフローパターン](#3つのワークフローパターン)
2. [パターンA: Miyabi-First](#パターンa-miyabi-first)
3. [パターンB: Claude Code-First](#パターンb-claude-code-first)
4. [パターンC: Explore-First](#パターンc-explore-first)
5. [ワークフローの選択フローチャート](#ワークフローの選択フローチャート)
6. [ベストプラクティス](#ベストプラクティス)
7. [コミットメッセージのテンプレート](#コミットメッセージのテンプレート)
8. [Issue進捗報告のテンプレート](#issue進捗報告のテンプレート)

## 3つのワークフローパターン

### パターンA: Miyabi-First

**推奨される場面**: 10ファイル以上の変更が必要な大規模タスク

```
Issue作成
    ↓
miyabi work-on <issue> → Plans.md生成
    ↓
Claude Code: Plans.mdをレビュー
    ↓
Claude Code: サブタスクの実装
    ↓
Claude Code: Git commit & Issue報告
```

**メリット**:
- タスクが明確に分解される
- 複雑な依存関係を把握できる
- 実装の方向性が明確になる

**デメリット**:
- 小規模タスクでは overkill になる
- セットアップに時間がかかる

**実例**: Issue #1 - DataProcessingServiceのリファクタリング（5つの専門サービスに分割）

### パターンB: Claude Code-First

**推奨される場面**: 小規模タスク（1-3ファイル程度の変更）

```
Claude Code: タスク理解
    ↓
Claude Code: 直接実装
    ↓
Claude Code: Commit & Close
    ↓
Miyabi（任意）: 追加検証
```

**メリット**:
- 迅速な実装が可能
- オーバーヘッドが少ない
- 柔軟な対応が可能

**デメリット**:
- 大規模タスクでは見通しが悪くなる
- タスク分解が手動になる

**実例**: Issue #6 - Issueテンプレートの作成

### パターンC: Explore-First

**推奨される場面**: コードベースの調査が必要な場合

```
Claude Code: Exploreエージェントを呼び出し
    ↓
Agent: コードベース分析（手動の3倍速）
    ↓
Claude Code: 意思決定
    ↓
Claude Code: 実装
```

**メリット**:
- コードベースの理解が速い
- 影響範囲の把握が正確
- 既存パターンを活用できる

**デメリット**:
- Exploreエージェントが必要
- 初回実行に時間がかかる

**実例**: 既存アーキテクチャの調査、リファクタリング前の影響分析

## ワークフローの選択フローチャート

```
タスク開始
    ↓
[10ファイル以上の変更？]
  YES → パターンA (Miyabi first)
  NO  ↓
[コードベースの理解が必要？]
  YES → パターンC (Explore first)
  NO  ↓
[単一ファイルの変更？]
  YES → パターンB (Claude Code direct)
  NO  ↓
[ドキュメント作成？]
  YES → パターンB (Claude Code direct)
  NO  → パターンA (Miyabi first)
```

## ベストプラクティス

### DO（推奨）

✅ **大規模タスクではMiyabiを使用**
- 10ファイル以上の変更が必要な場合
- 複数の関連タスクがある場合

✅ **Exploreエージェントを積極的に活用**
- コードベースの理解に時間を節約
- 既存パターンの発見に活用

✅ **Plans.mdを完全なタスクコンテキストとして参照**
- Miyabi生成のPlans.mdは実装の指針
- 依存関係を確認して順序を守る

✅ **Claude Code TodoListで進捗を追跡**
- タスクの可視化
- 完了状況の管理

✅ **頻繁にコミット、適切なメッセージ**
- 論理的な単位でコミット
- Claudeの署名を含める

✅ **GitHubのIssueコメントで進捗報告**
- 透明性の確保
- チームメンバーとの共有

✅ **コミットは分離して論理的に**
- 各タスクを個別にコミット
- レビューしやすい単位で分割

### DON'T（非推奨）

❌ **小規模タスクでMiyabiを使わない**
- オーバーヘッドが大きい
- 直接実装の方が速い

❌ **Plans.mdのガイダンスを無視しない**
- Miyabiの分析結果を活用
- 推奨される実装順序を守る

❌ **Exploreエージェントなしで大規模変更を実行しない**
- 影響範囲の把握が不十分になる
- 予期しない副作用が発生する可能性

❌ **タスク間でコミットをスキップしない**
- チェックポイントコミットを作成
- ロールバックが容易になる

❌ **`&&`でGitコマンドをチェーンしない**
- 確認プロンプトがトリガーされる可能性
- 個別に実行する方が安全

❌ **Issueでの追跡をスキップしない**
- 進捗の可視化
- 透明性の確保

❌ **他の開発者のコミットをamendしない**
- 履歴の保全
- 責任の明確化

## コミットメッセージのテンプレート

```bash
git commit -m "$(cat <<'EOF'
<変更内容の簡潔な説明>

<詳細な説明（必要に応じて）>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### 例

```bash
git commit -m "$(cat <<'EOF'
Add HtmlParsingService for data extraction

- Extract HTML parsing logic from DataProcessingService
- Implement robust error handling
- Add comprehensive PHPDoc comments

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

## Issue進捗報告のテンプレート

```markdown
## 進捗報告 [タスク名]

### 実施した作業
- [x] サブタスク1 - 完了詳細
- [x] サブタスク2 - 完了詳細

### 発見した問題
- 問題1の説明

### 解決した課題
- 課題1: 解決方法の詳細

### 次のステップ
1. 次のアクションの詳細
2. その次のアクション

### メトリクス
- 完了時間: XX分
- 変更行数: +XXX/-YYY
- コミット数: N
```

## Claude Code の権限設定

`.claude/settings.local.json` で以下の権限が設定されています：

```json
{
  "permissions": {
    "allow": [
      "Bash(miyabi:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)",
      "Bash(gh issue:*)",
      "Read(**)",
      "Write(**)",
      "Edit(**)"
    ]
  }
}
```

これにより、Claude CodeはMiyabiやGitコマンドを直接実行できます。

## 実践例: Issue #1のワークフロー

### 1. Issue作成
```bash
gh issue create --title "DataProcessingService refactoring" --body "..."
```

### 2. Miyabi実行
```bash
miyabi work-on 1
```

### 3. Plans.md確認
```bash
cat Plans.md
```

### 4. Claude Codeで実装
- Plans.mdをレビュー
- 各サブタスクを順番に実装
- 論理的な単位でコミット

### 5. 進捗報告
```bash
gh issue comment 1 --body "## 進捗報告..."
```

### 6. Issue完了
```bash
gh issue close 1
```

## まとめ

- タスクの規模に応じて適切なワークフローを選択
- MiyabiとClaude Codeの長所を活かす
- 透明性のある開発プロセスを維持
- 頻繁なコミットと報告で進捗を可視化

詳細な設定方法については、[MIYABI_SETUP.md](../MIYABI_SETUP.md) を参照してください。
