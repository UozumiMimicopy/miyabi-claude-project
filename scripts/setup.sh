#!/bin/bash

# miyabi-claude-project セットアップスクリプト
# このスクリプトは、プロジェクトのクローン後に実行してください

set -e

echo "========================================="
echo "miyabi-claude-project セットアップ"
echo "========================================="
echo ""

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 前提条件チェック
echo "1. 前提条件のチェック..."
echo ""

# Git
if command -v git &> /dev/null; then
    echo -e "${GREEN}✓${NC} Git: $(git --version)"
else
    echo -e "${RED}✗${NC} Git: Not installed"
    echo "  Git をインストールしてください"
    exit 1
fi

# GitHub CLI
if command -v gh &> /dev/null; then
    echo -e "${GREEN}✓${NC} GitHub CLI: $(gh --version | head -1)"
else
    echo -e "${YELLOW}⚠${NC} GitHub CLI: Not installed"
    echo "  GitHub CLI のインストールを推奨します"
fi

# Miyabi
if command -v miyabi &> /dev/null; then
    echo -e "${GREEN}✓${NC} Miyabi: $(miyabi --version)"
else
    echo -e "${YELLOW}⚠${NC} Miyabi: Not installed"
    echo "  Miyabi CLI のインストールを推奨します"
fi

# PHP
if command -v php &> /dev/null; then
    echo -e "${GREEN}✓${NC} PHP: $(php --version | head -1)"
else
    echo -e "${RED}✗${NC} PHP: Not installed"
    echo "  PHP 8.2+ をインストールしてください"
    exit 1
fi

# Composer
if command -v composer &> /dev/null; then
    echo -e "${GREEN}✓${NC} Composer: $(composer --version)"
else
    echo -e "${RED}✗${NC} Composer: Not installed"
    echo "  Composer をインストールしてください"
    exit 1
fi

echo ""
echo "2. ディレクトリ構造の作成..."
echo ""

# 必要なディレクトリを作成
mkdir -p logs
mkdir -p reports
mkdir -p .worktrees

echo -e "${GREEN}✓${NC} logs/ ディレクトリを作成"
echo -e "${GREEN}✓${NC} reports/ ディレクトリを作成"
echo -e "${GREEN}✓${NC} .worktrees/ ディレクトリを作成"

echo ""
echo "3. Laravel環境のセットアップ..."
echo ""

cd laravel-app

# Composer install
if [ -f "composer.json" ]; then
    echo "Composer依存関係をインストール中..."
    composer install --no-interaction
    echo -e "${GREEN}✓${NC} Composer依存関係のインストール完了"
else
    echo -e "${YELLOW}⚠${NC} composer.json が見つかりません"
fi

# .env作成
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}✓${NC} .env ファイルを作成"
    fi
fi

# アプリケーションキー生成
if [ -f ".env" ]; then
    php artisan key:generate --no-interaction
    echo -e "${GREEN}✓${NC} アプリケーションキーを生成"
fi

# データベースファイル作成（SQLite）
if [ ! -f "database/database.sqlite" ]; then
    touch database/database.sqlite
    echo -e "${GREEN}✓${NC} データベースファイルを作成"
fi

# マイグレーション
php artisan migrate --no-interaction --force
echo -e "${GREEN}✓${NC} データベースマイグレーション完了"

cd ..

echo ""
echo "4. Git設定の確認..."
echo ""

# Gitユーザー設定の確認
if git config user.name &> /dev/null && git config user.email &> /dev/null; then
    echo -e "${GREEN}✓${NC} Git user.name: $(git config user.name)"
    echo -e "${GREEN}✓${NC} Git user.email: $(git config user.email)"
else
    echo -e "${YELLOW}⚠${NC} Git user.name または user.email が設定されていません"
    echo "  以下のコマンドで設定してください:"
    echo "  git config --global user.name \"Your Name\""
    echo "  git config --global user.email \"your@email.com\""
fi

echo ""
echo "5. 環境変数の確認..."
echo ""

# GITHUB_TOKEN
if [ -n "$GITHUB_TOKEN" ]; then
    echo -e "${GREEN}✓${NC} GITHUB_TOKEN: 設定済み"
elif gh auth status &> /dev/null; then
    echo -e "${GREEN}✓${NC} GitHub CLI: 認証済み"
else
    echo -e "${YELLOW}⚠${NC} GITHUB_TOKEN: 未設定"
    echo "  'gh auth login' を実行してください"
fi

# ANTHROPIC_API_KEY
if [ -n "$ANTHROPIC_API_KEY" ]; then
    echo -e "${GREEN}✓${NC} ANTHROPIC_API_KEY: 設定済み"
else
    echo -e "${YELLOW}⚠${NC} ANTHROPIC_API_KEY: 未設定（オプション）"
    echo "  AI機能を使用する場合は設定してください"
fi

echo ""
echo "========================================="
echo "セットアップ完了！"
echo "========================================="
echo ""
echo "次のステップ:"
echo "  1. ドキュメントを確認: cat README.md"
echo "  2. Miyabiの状態確認: miyabi status"
echo "  3. Laravelサーバー起動: cd laravel-app && php artisan serve"
echo "  4. 最初のIssueを作成: gh issue create"
echo ""
echo "詳細は docs/SETUP.md を参照してください"
echo ""
