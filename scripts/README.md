# Scripts ディレクトリ

Claude Dev Workflow の管理・運用スクリプト集です。

## 📁 スクリプト一覧

### 🚀 install.sh
Claude Dev Workflow の初回インストールスクリプト

**機能**:
- `~/.claude/` ディレクトリに全ファイルを設置
- 既存ファイルの自動バックアップ
- GitHub API による動的ファイル取得
- curlパイプ実行対応（リモートインストール）
- 権限チェックとエラーハンドリング

**使用方法**:
```bash
# ローカル実行
./scripts/install.sh

# リモート実行（推奨）
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/install.sh | bash
```

**対応環境**: macOS, Linux

### 🔄 update.sh
Claude Dev Workflow の更新スクリプト

**機能**:
- 既存環境の安全な更新
- カスタマイズファイルの自動検出・保護
- 選択的更新（ローカル実行時）
- 更新前の自動バックアップ
- ロールバック機能

**使用方法**:
```bash
# ローカル実行
cd ~/.claude
./scripts/update.sh

# リモート実行（推奨）
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/update.sh | bash
```

**対応環境**: macOS, Linux

### 💾 backup.sh
Claude Dev Workflow のバックアップ管理スクリプト

**機能**:
- タイムスタンプ付きバックアップ作成
- バックアップ一覧表示
- 30日以上古いバックアップ自動削除
- ロールバック機能（指定バックアップからの復元）
- バックアップファイル整合性チェック
- 復元前の現在設定自動バックアップ

**使用方法**:
```bash
# ローカル実行
~/.claude/scripts/backup.sh backup        # バックアップ作成
~/.claude/scripts/backup.sh list          # バックアップ一覧表示
~/.claude/scripts/backup.sh restore 1     # 指定したバックアップから復元
~/.claude/scripts/backup.sh cleanup       # 古いバックアップ削除
~/.claude/scripts/backup.sh help          # ヘルプ表示

# リモート実行（HTTPS経由）
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/backup.sh | bash -s backup
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/backup.sh | bash -s list
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/backup.sh | bash -s restore 1
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/backup.sh | bash -s cleanup
```

**バックアップ場所**: `~/.claude-backups/`  
**ファイル形式**: `claude-backup_YYYYMMDD_HHMMSS.tar.gz`  
**対応環境**: macOS, Linux

## 🔧 共通仕様

### エラーハンドリング
全スクリプトは以下の安全機能を実装：
- `set -euo pipefail` による厳密なエラーチェック
- 割り込み処理（Ctrl+C）対応
- 適切なクリーンアップ処理
- わかりやすいエラーメッセージ

### ログ出力
統一されたカラーログ出力：
- 🔵 **Info**: 情報メッセージ
- 🟢 **Success**: 成功メッセージ  
- 🟡 **Warning**: 警告メッセージ
- 🔴 **Error**: エラーメッセージ

### macOS対応
macOS固有の仕様に対応：
- `date -j` を使用した日付計算
- `stat -f%z` を使用したファイルサイズ取得
- BSD版 `tar` コマンド対応

## 🚀 使用シナリオ

### 初回セットアップ
```bash
# 1. インストール実行
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/install.sh | bash

# 2. Claude Codeでガイドライン読み込み
# "~/.claude/CLAUDE.md の内容を読み込んで、今後このガイドラインに従って動作してください"
```

### 定期メンテナンス
```bash
# 1. 現在の設定をバックアップ
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/backup.sh | bash -s backup

# 2. 最新版に更新
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/update.sh | bash

# 3. 古いバックアップを削除
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/backup.sh | bash -s cleanup
```

### 問題発生時の復旧
```bash
# 1. バックアップ一覧確認
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/backup.sh | bash -s list

# 2. 適切なバックアップから復元
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/backup.sh | bash -s restore 2

# 3. 動作確認
ls -la ~/.claude/
```

## 📋 開発者向け情報

### スクリプト開発規約
- シェルスクリプトベストプラクティス準拠
- 関数分割による可読性確保
- 設定値の定数化
- 詳細なコメント記述

### テスト項目
各スクリプトは以下の項目でテスト：
- 正常系動作確認
- エラーケース処理
- 権限不足時の動作
- 割り込み処理
- macOS/Linux 両環境での動作

### 今後の拡張予定
- Windows環境対応（PowerShell版）
- 自動テストスイート追加
- ログ出力レベル制御
- 設定ファイル（`.claude-config`）対応