# Claude Code 開発フロー

**個人開発を効率化するClaude Code協働ガイドライン**

## 概要

Claude Codeとの協働で個人開発を3-5倍効率化するためのガイドライン集です。  
要件定義からリリースまで、一貫した品質でプロジェクトを進行できます。

### 解決する課題
- Claude Codeへの指示が毎回バラバラで非効率
- 一人開発でコードレビューができない
- ドキュメント更新漏れが頻発
- プロジェクト管理が属人化

### 実現できること
- スラッシュコマンド1つで完全自動化
- プロレベルの自動コードレビュー
- TDD + 自動テスト + ドキュメント更新の一気通貫

## 📦 セットアップ

### インストール

以下のコマンドで `~/.claude/` 配下に `CLAUDE.md` などのファイルが配置されます。  
既存のファイルは変更しません。  

```bash
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/install.sh | bash
```

以下のファイルが展開されます。

```
~/.claude/
├── .claude-version              # バージョン情報
├── CLAUDE.md                    # メインガイド
├── settings.json                # Claude Code設定ファイル
├── commands/                    # カスタムスラッシュコマンド
├── requirements/                # 要件定義関連
├── workflow/                    # 開発ワークフロー
├── templates/                   # 各種テンプレート
└── scripts/                     # 管理スクリプト
```

### ガイドライン読み込み（重要！）
Claude Codeに以下を指示してガイドラインを読み込ませてください：
```
~/.claude/CLAUDE.md の内容を読み込んで、今後このガイドラインに従って動作してください
```

### 動作確認
読み込みが成功すると、Claude Codeが以下のように応答します：
```
ガイドラインを読み込みました。今後このガイドラインに従って動作します。
利用可能なコマンド: /start-project, /implement, /auto-review など
```

### スクリプト管理
詳細なスクリプト使用方法とトラブルシューティングガイド: [scripts/README.md](scripts/README.md)

#### クイック管理コマンド
```bash
# 更新チェック・実行
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/update.sh | bash

# バックアップ作成
~/.claude/scripts/backup.sh backup

# バックアップ一覧
~/.claude/scripts/backup.sh list

# 設定復元
~/.claude/scripts/backup.sh restore 1
```

## 🚀 使い方

###  使えるコマンド一覧
[commands - README.md](commands/README.md)

### 開発スタート

#### Step 1: 最初のプロジェクト作成
```bash
/start-project [プロジェクト名]
```
30分で要件定義〜GitHub Issue作成まで完了

#### Step 2: 開発開始
```bash
/implement issue #1
```
1つのコマンドで実装〜テスト〜PR作成まで自動実行

#### Step 3: 品質チェック
```bash
/auto-review feature/issue-15-payment
```
プロレベルの自動コードレビューで品質確保

### その他の使い方

#### 調査・分析が必要な時
```bash
/tech-research Next.js vs Nuxt.js    # 技術比較調査
/competitor-analysis Notion          # 競合分析
/analyze-codebase                    # コードベース分析
```

## 🛡️ 設定カスタマイズ保護

### カスタマイズ検出と管理
```bash
# カスタマイズファイルの初期化
./scripts/config-protection.sh --init

# カスタマイズ一覧表示
./scripts/config-protection.sh --list

# 特定ファイルのカスタマイズ検出
./scripts/config-protection.sh --detect CLAUDE.md
```

### インテリジェントマージ
```bash
# スマートマージ実行
./scripts/config-merge.sh --smart current.md new.md merged.md

# Markdownセクション別マージ
./scripts/config-merge.sh --markdown current.md new.md merged.md

# JSON設定のキー別マージ
./scripts/config-merge.sh --json settings.json new_settings.json merged.json

# マージプレビュー表示
./scripts/config-merge.sh --preview current.md new.md merged.md
```

### カスタマイズ履歴管理
```bash
# 履歴表示
./scripts/customization-history.sh --show

# 特定ファイルの履歴
./scripts/customization-history.sh --file CLAUDE.md

# 履歴統計情報
./scripts/customization-history.sh --stats

# 履歴検索
./scripts/customization-history.sh --search "merge"

# 履歴エクスポート
./scripts/customization-history.sh --export history.csv csv
```

### カスタマイズ復元
```bash
# バックアップから復元
./scripts/config-protection.sh --restore CLAUDE.md

# 古いバックアップクリーンアップ
./scripts/config-protection.sh --cleanup 30
```

### テスト実行
```bash
# 設定保護機能のテスト
./scripts/test-config-protection.sh
```

## 📚 ドキュメント・ガイド

### 主要ドキュメント
- [スクリプト使用方法とトラブルシューティング](scripts/README.md) - スクリプトの詳細な使用方法、FAQ、トラブル対応
- [基本的な使用例](scripts/examples/basic-usage.md) - 日常的な使用パターンとコマンド例
- [高度な使用例](scripts/examples/advanced-usage.md) - 企業環境、CI/CD統合、カスタマイズ例

### 開発フローガイド
- [commands/README.md](commands/README.md) - 利用可能なスラッシュコマンド一覧
- [workflow/](workflow/) - 開発ワークフロー詳細
- [templates/](templates/) - 各種テンプレート集

## ⚠️ トラブルシューティング

### よくある問題
詳細な解決方法は [scripts/README.md - トラブルシューティング](scripts/README.md#-トラブルシューティング) を参照

#### Claude Codeが期待通りに動作しない
1. `/clear` を実行し、メモリをクリアにする
2. 該当するガイドラインファイルを明示的に指定  
3. 段階的に指示を分割して実行
4. 具体的な成果物を明示

#### スクリプト実行エラー
```bash
# 権限確認・修正
chmod +x ~/.claude/scripts/*.sh

# 健全性チェック
~/.claude/scripts/check-compatibility.sh --check

# ヘルプ表示
~/.claude/scripts/backup.sh help
```

#### 設定が消えた・おかしくなった
```bash
# バックアップ確認
~/.claude/scripts/backup.sh list

# 最新のバックアップから復元
~/.claude/scripts/backup.sh restore 1

# または更新前の状態にロールバック
~/.claude/scripts/update.sh --rollback
```
