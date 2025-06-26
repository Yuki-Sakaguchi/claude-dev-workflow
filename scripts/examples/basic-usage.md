# 基本的な使用例

Claude Dev Workflow スクリプトの基本的な使用パターンを実例で紹介します。

## 📋 シナリオ別使用例

### シナリオ1: 初回セットアップ

**状況**: 新しいマシンでClaude Dev Workflowを使い始める

```bash
# 1. 初回インストール（最も簡単な方法）
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/install.sh | bash

# 実行結果例:
# 🚀 Claude Dev Workflow セットアップ開始
# ℹ️  実行環境: curl
# ℹ️  GitHubからファイルをダウンロードします
# ✅ 権限チェック完了
# ℹ️  新規インストールです
# ✅ インストール検証完了
# 🎉 Claude Dev Workflow のセットアップが完了しました！

# 2. インストール確認
ls -la ~/.claude/

# 期待される結果:
# drwxr-xr-x  10 user  staff   320 Jan 20 14:30 .
# drwxr-xr-x+ 50 user  staff  1600 Jan 20 14:30 ..
# -rw-r--r--   1 user  staff  15000 Jan 20 14:30 CLAUDE.md
# -rw-r--r--   1 user  staff    500 Jan 20 14:30 settings.json
# drwxr-xr-x   5 user  staff   160 Jan 20 14:30 commands
# drwxr-xr-x   3 user  staff    96 Jan 20 14:30 docs
# drwxr-xr-x   4 user  staff   128 Jan 20 14:30 requirements
# drwxr-xr-x  10 user  staff   320 Jan 20 14:30 scripts
# drwxr-xr-x   8 user  staff   256 Jan 20 14:30 templates
# drwxr-xr-x   5 user  staff   160 Jan 20 14:30 workflow

# 3. Claude Codeでの設定読み込み
# Claude Code で以下を実行:
# "~/.claude/CLAUDE.md の内容を読み込んで、今後このガイドラインに従って動作してください"

# 4. 動作確認
# Claude Code で:
# "/research PWAの導入可能性について調査してください"
```

### シナリオ2: 定期メンテナンス

**状況**: 月次の定期メンテナンス作業

```bash
# 1. 現在のバージョン確認
~/.claude/scripts/version.sh --show

# 実行結果例:
# Claude Dev Workflow v1.0.0
# Last updated: 2024-01-15T09:30:00Z
# Features: research, automation, templates, workflow, commands

# 2. 更新前バックアップ
~/.claude/scripts/backup.sh backup

# 実行結果例:
# 🔄 バックアップを作成しています...
# ℹ️  バックアップ対象: /Users/user/.claude
# ✅ バックアップ作成完了: /Users/user/.claude-backups/claude-backup_20240120_140000.tar.gz
# ℹ️  バックアップサイズ: 2.1MB
# ✅ 整合性チェック完了

# 3. 最新版への更新
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/update.sh | bash

# 実行結果例:
# 🔄 Claude Dev Workflow 更新開始
# ℹ️  現在のバージョン: 1.0.0
# ℹ️  リモート実行では強制的に全ファイルを更新します
# ✅ バックアップ完了: /Users/user/.claude.backup.update.20240120_140130
# [1/8] 更新中: CLAUDE.md
# ✅ 更新完了: CLAUDE.md
# 🎉 Claude Dev Workflow の更新が完了しました！

# 4. 古いバックアップ削除
~/.claude/scripts/backup.sh cleanup

# 実行結果例:
# 🧹 古いバックアップを削除しています...
# ✅ 削除しました: claude-backup_20231120_140000.tar.gz
# ✅ 削除しました: claude-backup_20231125_140000.tar.gz
# ✅ 2 個の古いバックアップを削除しました

# 5. 動作確認
# Claude Code で:
# "/research Claude Dev Workflowの最新機能について"
```

### シナリオ3: 問題発生時の復旧

**状況**: アップデート後に問題が発生、ロールバックが必要

```bash
# 1. 現在の状況確認
ls -la ~/.claude/

# 問題発生を確認:
# 一部ファイルが破損または設定が正しく動作しない

# 2. バックアップ一覧確認
~/.claude/scripts/backup.sh list

# 実行結果例:
# 📋 バックアップ一覧
# 
# No. ファイル名                          サイズ     作成日時           経過日数
# --- -------------------------------- ---------- --------------- ---------
# 1   claude-backup_20240120_140130.tar.gz 2.1MB      2024-01-20 14:01:30 0日前
# 2   claude-backup_20240120_140000.tar.gz 2.1MB      2024-01-20 14:00:00 0日前
# 3   claude-backup_20240119_140000.tar.gz 2.0MB      2024-01-19 14:00:00 1日前
# 
# ℹ️  合計: 3個のバックアップ, 総サイズ: 6.2MB

# 3. 安全なバックアップから復元
~/.claude/scripts/backup.sh restore 2

# 実行結果例:
# 🔄 バックアップからの復元
# ℹ️  復元対象: claude-backup_20240120_140000.tar.gz
# ✅ バックアップファイルの整合性OK: claude-backup_20240120_140000.tar.gz
# ℹ️  現在の設定をバックアップしています: claude-backup_before_restore_20240120_141500.tar.gz
# ✅ 現在の設定のバックアップ完了
# ℹ️  既存の設定を削除しています...
# ℹ️  バックアップから復元しています...
# ✅ 復元完了: /Users/user/.claude
# ✅ ロールバック処理が完了しました

# 4. 復元後の動作確認
cat ~/.claude/.claude-version

# 期待される結果:
# {
#   "version": "1.0.0",
#   "last_updated": "2024-01-20T14:00:00Z",
#   ...
# }

# 5. Claude Codeでの動作確認
# Claude Code で:
# "/research 復旧テスト"
```

### シナリオ4: カスタマイズ設定の管理

**状況**: CLAUDE.mdをプロジェクト用にカスタマイズ後、安全に更新

```bash
# 1. カスタマイズ前の状態保存
~/.claude/scripts/backup.sh backup

# 2. CLAUDE.mdをカスタマイズ
# エディタでファイルを編集:
# vim ~/.claude/CLAUDE.md
# 
# プロジェクト固有の設定を追加:
# - 特定の技術スタック
# - チーム固有のワークフロー
# - プロジェクト特有のガイドライン

# 3. カスタマイズ履歴の記録
~/.claude/scripts/customization-history.sh --add ~/.claude/CLAUDE.md "project_specific" "Eコマースプロジェクト用の設定追加"

# 4. 更新時の保護確認
~/.claude/scripts/update.sh

# 実行結果例:
# 🔄 Claude Dev Workflow 更新開始
# ℹ️  現在のバージョン: 1.0.0
# ℹ️  リモートより 2 コミット遅れています
# 
# ⚠️  カスタマイズ済みファイルが検出されました:
#   - CLAUDE.md
# 
# 🤔 更新を実行しますか？
# 
# 選択してください:
# 1) 更新を実行する    # ← カスタマイズを保護してマージ
# 2) 個別ファイル選択  # ← ファイル別に選択
# 3) キャンセル
# 
# 選択 (1-3): 1

# 5. インテリジェントマージの確認
# 実行結果例:
# ℹ️  更新前バックアップを作成しています...
# ✅ バックアップ完了: /Users/user/.claude.backup.update.20240120_143000
# 🔒 カスタマイズファイルのマージ処理: CLAUDE.md
# ✅ インテリジェントマージ完了: CLAUDE.md
# ✅ 更新完了: workflow/development-flow.md
# 🎉 Claude Dev Workflow の更新が完了しました！

# 6. マージ結果の確認
grep -A 5 -B 5 "Eコマースプロジェクト" ~/.claude/CLAUDE.md

# カスタマイズが保持されていることを確認
```

### シナリオ5: 複数マシン間での設定共有

**状況**: 開発環境と本番環境で同じ設定を使用

```bash
# === 開発マシン (設定元) ===

# 1. 最新の設定をバックアップ
~/.claude/scripts/backup.sh backup

# 実行結果例:
# ✅ バックアップ作成完了: /Users/dev/.claude-backups/claude-backup_20240120_150000.tar.gz

# 2. バックアップファイルを本番環境に転送
scp ~/.claude-backups/claude-backup_20240120_150000.tar.gz user@production-server:~/

# または
rsync -av ~/.claude-backups/claude-backup_20240120_150000.tar.gz user@production-server:~/

# === 本番マシン (設定先) ===

# 3. Claude Dev Workflowをインストール（未インストールの場合）
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/install.sh | bash

# 4. 転送されたバックアップファイルを配置
mkdir -p ~/.claude-backups
mv ~/claude-backup_20240120_150000.tar.gz ~/.claude-backups/

# 5. 開発環境の設定で復元
~/.claude/scripts/backup.sh restore 1

# 実行結果例:
# 🔄 バックアップからの復元
# ℹ️  復元対象: claude-backup_20240120_150000.tar.gz
# ✅ バックアップファイルの整合性OK
# ✅ 復元完了: /Users/prod/.claude
# ✅ ロールバック処理が完了しました

# 6. 設定の同期確認
diff <(ssh dev-server 'cat ~/.claude/CLAUDE.md') ~/.claude/CLAUDE.md

# 違いがないことを確認
```

## 🔧 実用的なワンライナー

### 日常使いのコマンド集

```bash
# クイックバックアップ + 更新
~/.claude/scripts/backup.sh backup && curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/update.sh | bash

# バックアップ状況の確認
~/.claude/scripts/backup.sh list | head -10

# 緊急時のクイック復元（最新バックアップ）
~/.claude/scripts/backup.sh restore 1

# 健全性チェック
~/.claude/scripts/check-compatibility.sh --check && echo "✅ All OK"

# ディスク使用量チェック
du -sh ~/.claude ~/.claude-backups

# カスタマイズファイルの確認
grep -r "カスタマイズ\|custom" ~/.claude/ 2>/dev/null || echo "カスタマイズなし"

# バージョン情報の表示
~/.claude/scripts/version.sh --info | grep -E "(version|last_updated|features)"
```

### トラブルシューティング用

```bash
# 権限問題の修正
find ~/.claude -type f -name "*.sh" -exec chmod +x {} \;

# 破損したバックアップの特定
for f in ~/.claude-backups/*.tar.gz; do echo -n "$f: "; tar -tzf "$f" >/dev/null 2>&1 && echo "OK" || echo "BROKEN"; done

# 設定ファイルの文法チェック（JSON）
for f in ~/.claude/*.json; do echo -n "$f: "; python -m json.tool "$f" >/dev/null 2>&1 && echo "OK" || echo "INVALID"; done

# ネットワーク接続テスト
curl -s --max-time 5 https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/install.sh | head -1

# 詳細ログ付きでの実行
bash -x ~/.claude/scripts/backup.sh backup 2>backup-debug.log
```

## 📊 モニタリング・統計

### 使用状況の把握

```bash
# インストール日時
stat -f "%SB" ~/.claude 2>/dev/null || stat -c "%y" ~/.claude 2>/dev/null

# 最終更新日時
cat ~/.claude/.claude-version | grep last_updated

# バックアップ統計
echo "バックアップ数: $(ls ~/.claude-backups/*.tar.gz 2>/dev/null | wc -l)"
echo "総サイズ: $(du -sh ~/.claude-backups 2>/dev/null | cut -f1)"

# 最も大きなファイル
find ~/.claude -type f -exec ls -lh {} \; | sort -k5 -hr | head -5

# カスタマイズ状況
if [[ -f ~/.claude/.customizations.json ]]; then
  echo "カスタマイズ数: $(cat ~/.claude/.customizations.json | grep -o '"file"' | wc -l)"
else
  echo "カスタマイズなし"
fi
```

### 自動化スクリプト例

**週次メンテナンス用スクリプト**:
```bash
#!/bin/bash
# weekly-maintenance.sh

echo "=== Claude Dev Workflow 週次メンテナンス ==="
echo "開始時刻: $(date)"

# バックアップ作成
echo "1. バックアップ作成中..."
~/.claude/scripts/backup.sh backup

# 古いバックアップ削除
echo "2. 古いバックアップ削除中..."
~/.claude/scripts/backup.sh cleanup

# ヘルスチェック
echo "3. ヘルスチェック実行中..."
~/.claude/scripts/check-compatibility.sh --check

echo "完了時刻: $(date)"
echo "=== メンテナンス完了 ==="
```

**月次更新用スクリプト**:
```bash
#!/bin/bash
# monthly-update.sh

echo "=== Claude Dev Workflow 月次更新 ==="
echo "開始時刻: $(date)"

# 現在のバージョン表示
echo "現在のバージョン:"
~/.claude/scripts/version.sh --show

# バックアップ作成
echo "1. 更新前バックアップ作成中..."
~/.claude/scripts/backup.sh backup

# 更新実行
echo "2. 更新実行中..."
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/update.sh | bash

# 更新後バージョン表示
echo "更新後のバージョン:"
~/.claude/scripts/version.sh --show

echo "完了時刻: $(date)"
echo "=== 更新完了 ==="
echo ""
echo "Claude Codeで動作確認を実行してください:"
echo '"/research Claude Dev Workflowの動作確認"'
```

---

これらの例を参考に、自分の環境と用途に合わせてコマンドやスクリプトをカスタマイズしてください。