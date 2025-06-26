# Claude Dev Workflow - スクリプト使用方法ガイド

Claude Dev Workflow の自動化スクリプト集の包括的な使用方法とトラブルシューティングガイドです。

## 📋 目次

- [クイックスタート](#-クイックスタート)
- [スクリプト一覧](#-スクリプト一覧)
- [詳細な使用方法](#-詳細な使用方法)
- [実行環境と前提条件](#-実行環境と前提条件)
- [トラブルシューティング](#-トラブルシューティング)
- [FAQ](#-faq)
- [メンテナンス](#-メンテナンス)

## 🚀 クイックスタート

### 初回インストール
```bash
# 最も簡単な方法（推奨）
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/install.sh | bash
```

### Claude Code での設定読み込み
インストール後、Claude Code で以下を実行：
```
~/.claude/CLAUDE.md の内容を読み込んで、今後このガイドラインに従って動作してください
```

### 動作確認
```bash
# ガイドライン活用の確認
cd ~/.claude
ls -la

# 調査機能のテスト
# Claude Code で: /research PWAの導入可能性
```

## 📁 スクリプト一覧

| スクリプト | 用途 | 主要機能 | 実行頻度 |
|-----------|------|----------|----------|
| **install.sh** | 初回インストール | 全ファイル設置、バックアップ作成 | 1回のみ |
| **update.sh** | 更新・アップグレード | カスタマイズ保護、選択的更新 | 週次・月次 |
| **backup.sh** | バックアップ管理 | 定期バックアップ、復元、削除 | 日次・週次 |
| **version.sh** | バージョン管理 | バージョン表示、互換性確認 | 必要時 |
| **config-protection.sh** | 設定保護 | カスタマイズ検出・保護 | 自動実行 |
| **config-merge.sh** | 設定マージ | インテリジェントな設定統合 | 更新時自動 |
| **customization-history.sh** | カスタマイズ履歴 | 変更履歴管理・追跡 | 更新時自動 |
| **check-compatibility.sh** | 互換性チェック | 環境・依存関係確認 | インストール・更新時 |

## 🔧 詳細な使用方法

### install.sh - 初回インストール

#### 概要
Claude Dev Workflow を `~/.claude/` ディレクトリにインストールします。

#### 実行方法

**リモート実行（推奨）**:
```bash
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/install.sh | bash
```

**ローカル実行**:
```bash
# リポジトリをクローン
git clone https://github.com/Yuki-Sakaguchi/claude-dev-workflow.git
cd claude-dev-workflow

# インストール実行
./scripts/install.sh
```

#### 実行内容
1. **権限チェック**: ホームディレクトリの書き込み権限確認
2. **バックアップ**: 既存の `~/.claude/` を自動バックアップ
3. **ファイル取得**: GitHub APIを使用した動的ファイル取得
4. **設定初期化**: バージョン管理・設定保護機能の初期化
5. **動作確認**: インストールの整合性チェック

#### 実行例
```bash
$ curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/install.sh | bash

🚀 Claude Dev Workflow セットアップ開始

ℹ️  実行環境: curl
ℹ️  GitHubからファイルをダウンロードします

ℹ️  権限をチェックしています...
✅ 権限チェック完了

⚠️  既存の Claude Dev Workflow が検出されました
ℹ️  バックアップを作成しています...
✅ バックアップ完了: /Users/user/.claude.backup.20240120_143052

ℹ️  ファイルを取得しています...
[1/8] ダウンロード中: CLAUDE.md
✅ ダウンロード完了: CLAUDE.md
...

✅ インストール検証完了
ℹ️  バージョン管理機能の動作確認中...
✅ 互換性チェック完了

🎉 Claude Dev Workflow のセットアップが完了しました！

📍 インストール場所: /Users/user/.claude
```

### update.sh - 更新スクリプト

#### 概要
既存のインストールを安全に最新版に更新します。カスタマイズした設定は自動保護されます。

#### 実行方法

**リモート実行（推奨）**:
```bash
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/update.sh | bash
```

**ローカル実行**:
```bash
cd ~/.claude
./scripts/update.sh
```

**ロールバック**:
```bash
~/.claude/scripts/update.sh --rollback
```

#### 主要機能

1. **カスタマイズ検出**: 
   - 変更されたファイルを自動検出
   - `.customizations.json` での管理
   
2. **選択的更新**（ローカル実行時）:
   - ファイル別更新可否の選択
   - 変更内容のプレビュー表示
   
3. **インテリジェントマージ**:
   - カスタマイズと新機能の自動統合
   - 設定の競合回避

#### 実行例
```bash
$ ~/.claude/scripts/update.sh

🔄 Claude Dev Workflow 更新開始

ℹ️  現在のバージョン: 1.0.0
ℹ️  リモートより 3 コミット遅れています

📝 変更されるファイル一覧:
  📄 CLAUDE.md
  📄 workflow/development-flow.md
  📄 templates/pr-template.md

⚠️  カスタマイズ済みファイルが検出されました:
  - CLAUDE.md

🤔 更新を実行しますか？

選択してください:
1) 更新を実行する
2) 個別ファイル選択
3) キャンセル

選択 (1-3): 1

ℹ️  更新前バックアップを作成しています...
✅ バックアップ完了: /Users/user/.claude.backup.update.20240120_143052

🔒 カスタマイズファイルのマージ処理: CLAUDE.md
✅ インテリジェントマージ完了: CLAUDE.md
✅ 更新完了: workflow/development-flow.md
✅ 更新完了: templates/pr-template.md

🎉 Claude Dev Workflow の更新が完了しました！
```

### backup.sh - バックアップ管理

#### 概要
Claude Dev Workflow の定期バックアップ、復元、メンテナンスを行います。

#### コマンド一覧

| コマンド | 機能 | 使用例 |
|----------|------|--------|
| `backup` | バックアップ作成 | `backup.sh backup` |
| `list` | バックアップ一覧表示 | `backup.sh list` |
| `restore <N>` | 指定バックアップから復元 | `backup.sh restore 1` |
| `cleanup` | 古いバックアップ削除 | `backup.sh cleanup` |
| `help` | ヘルプ表示 | `backup.sh help` |

#### 使用方法

**バックアップ作成**:
```bash
# ローカル実行
~/.claude/scripts/backup.sh backup

# リモート実行
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/backup.sh | bash -s backup
```

**バックアップ一覧表示**:
```bash
~/.claude/scripts/backup.sh list
```

**復元**:
```bash
# バックアップ一覧を確認してから復元
~/.claude/scripts/backup.sh list
~/.claude/scripts/backup.sh restore 2
```

#### 実行例
```bash
$ ~/.claude/scripts/backup.sh backup

🔄 バックアップを作成しています...

ℹ️  バックアップ対象: /Users/user/.claude
ℹ️    - CLAUDE.md（メインガイド）
ℹ️    - settings.json（Claude Code設定）
ℹ️    - commands/（カスタムコマンド）
ℹ️    - requirements/（要件定義）
ℹ️    - workflow/（開発フロー）
ℹ️    - templates/（テンプレート）
ℹ️    - scripts/（管理スクリプト）
ℹ️  バックアップファイル: /Users/user/.claude-backups/claude-backup_20240120_143052.tar.gz

✅ ファイルコピー完了
✅ バックアップ作成完了: /Users/user/.claude-backups/claude-backup_20240120_143052.tar.gz
ℹ️  バックアップサイズ: 2.1MB
✅ 整合性チェック完了
✅ バックアップ処理が完了しました

$ ~/.claude/scripts/backup.sh list

📋 バックアップ一覧

No. ファイル名                サイズ     作成日時           経過日数
--- -------------------- ---------- --------------- ---------
1   claude-backup_20240120_143052.tar.gz 2.1MB      2024-01-20 14:30:52 0日前
2   claude-backup_20240119_094521.tar.gz 2.0MB      2024-01-19 09:45:21 1日前
3   claude-backup_20240118_183015.tar.gz 1.9MB      2024-01-18 18:30:15 2日前

ℹ️  合計: 3個のバックアップ, 総サイズ: 6.0MB
```

### その他のユーティリティスクリプト

#### version.sh - バージョン管理
```bash
# 現在のバージョン表示
~/.claude/scripts/version.sh --show

# 詳細情報表示
~/.claude/scripts/version.sh --info

# バージョン比較
~/.claude/scripts/version.sh --compare 1.0.0 1.0.1
```

#### check-compatibility.sh - 互換性チェック
```bash
# 環境チェック
~/.claude/scripts/check-compatibility.sh --check

# 詳細診断
~/.claude/scripts/check-compatibility.sh --diagnose
```

## 🔧 実行環境と前提条件

### 対応OS
- **macOS**: 10.14 (Mojave) 以降
- **Linux**: Ubuntu 18.04, CentOS 7, RHEL 7 以降

### 必要なコマンド
| コマンド | 用途 | インストール方法 |
|----------|------|------------------|
| `curl` | ファイルダウンロード | 通常プリインストール |
| `tar` | アーカイブ作成・展開 | 通常プリインストール |
| `rsync` | ファイル同期 | 通常プリインストール |
| `git` | バージョン管理（ローカル実行時） | `brew install git` / `apt install git` |
| `jq` | JSON処理（推奨） | `brew install jq` / `apt install jq` |

### ディレクトリ構造
```
~/.claude/                          # メインインストールディレクトリ
├── CLAUDE.md                       # メインガイドライン
├── settings.json                   # Claude Code設定
├── .claude-version                 # バージョン情報
├── .customizations.json            # カスタマイズ管理
├── .last-backup                    # 最新バックアップ情報
├── commands/                       # カスタムコマンド
├── requirements/                   # 要件定義テンプレート
├── workflow/                       # 開発フロー定義
├── templates/                      # 各種テンプレート
├── docs/                          # ドキュメント
└── scripts/                       # 管理スクリプト

~/.claude-backups/                  # バックアップディレクトリ
├── claude-backup_20240120_143052.tar.gz
├── claude-backup_20240119_094521.tar.gz
└── ...
```

### 権限要件
- ホームディレクトリ（`~`）への読み書き権限
- バックアップディレクトリ（`~/.claude-backups`）作成権限
- インターネット接続（GitHubアクセス用）

## 🚨 トラブルシューティング

### よくある問題と解決方法

#### 1. インストール失敗

**症状**: `install.sh` の実行でエラーが発生
```
❌ エラーが発生しました: ディレクトリの作成に失敗しました: /Users/user/.claude
```

**原因と対処法**:
- **権限不足**: ホームディレクトリの書き込み権限確認
  ```bash
  ls -ld ~ ~/.claude*
  chmod 755 ~
  ```
- **ディスク容量不足**: 空き容量確認
  ```bash
  df -h ~
  ```
- **既存プロセス**: Claude Dev Workflow を使用中のプロセス確認
  ```bash
  lsof ~/.claude
  ```

#### 2. 更新時のカスタマイズ競合

**症状**: `update.sh` でカスタマイズが失われる
```
⚠️  マージ処理をスキップ: CLAUDE.md
```

**対処法**:
1. **手動バックアップ**: 更新前に重要ファイルをバックアップ
   ```bash
   cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.backup
   ```
2. **個別ファイル選択**: 更新時に選択的更新を使用
   ```bash
   ~/.claude/scripts/update.sh
   # → 選択: 2) 個別ファイル選択
   ```
3. **手動マージ**: 競合ファイルを手動で統合
   ```bash
   diff ~/.claude/CLAUDE.md.backup ~/.claude/CLAUDE.md
   ```

#### 3. バックアップファイル破損

**症状**: 復元時に整合性エラー
```
❌ バックアップファイルが破損しています: claude-backup_20240120_143052.tar.gz
```

**対処法**:
1. **他のバックアップ確認**: 利用可能なバックアップ一覧確認
   ```bash
   ~/.claude/scripts/backup.sh list
   ```
2. **整合性チェック**: 各バックアップの状態確認
   ```bash
   for file in ~/.claude-backups/*.tar.gz; do
     echo "Checking: $(basename "$file")"
     tar -tzf "$file" >/dev/null && echo "OK" || echo "BROKEN"
   done
   ```
3. **新規バックアップ**: 現在の状態から新しいバックアップ作成
   ```bash
   ~/.claude/scripts/backup.sh backup
   ```

#### 4. リモート実行での接続エラー

**症状**: curlでのダウンロード失敗
```
curl: (6) Could not resolve host: raw.githubusercontent.com
```

**対処法**:
1. **ネットワーク確認**: インターネット接続確認
   ```bash
   ping github.com
   ```
2. **DNS設定**: DNS設定確認・変更
   ```bash
   nslookup raw.githubusercontent.com
   # 必要に応じて DNS変更: 8.8.8.8 など
   ```
3. **プロキシ設定**: 企業環境でのプロキシ設定
   ```bash
   export http_proxy=http://proxy.company.com:8080
   export https_proxy=http://proxy.company.com:8080
   ```
4. **ローカル実行**: リモート実行の代わりにローカル実行
   ```bash
   git clone https://github.com/Yuki-Sakaguchi/claude-dev-workflow.git
   cd claude-dev-workflow
   ./scripts/install.sh
   ```

#### 5. macOS特有の問題

**症状**: macOS上でdate/statコマンドエラー
```
date: illegal option -- d
```

**対処法**:
- **GNU coreutils インストール**（推奨）:
  ```bash
  brew install coreutils
  # PATHに/usr/local/opt/coreutils/libexec/gnubinを追加
  ```
- **macOS標準コマンド使用**: スクリプトは自動対応済み

### デバッグモード

**詳細ログ出力**:
```bash
# インストール時のデバッグ
bash -x <(curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/install.sh)

# 更新時のデバッグ
bash -x ~/.claude/scripts/update.sh
```

**一時ファイル確認**:
```bash
# 一時ディレクトリの確認
echo $TMPDIR
ls -la $TMPDIR/claude-*

# プロセス確認
ps aux | grep claude
```

## ❓ FAQ

### インストール・セットアップ

**Q: 既存の設定は削除されますか？**
A: いいえ。既存の `~/.claude/` は自動的にバックアップされ、タイムスタンプ付きで保存されます。

**Q: インストール中にエラーが発生した場合の対処は？**
A: 
1. エラーメッセージを確認
2. [トラブルシューティング](#-トラブルシューティング)を参照
3. 権限・ネットワーク・容量を確認
4. 問題が解決しない場合は、[GitHub Issues](https://github.com/Yuki-Sakaguchi/claude-dev-workflow/issues)で報告

**Q: curlパイプ実行とローカル実行の違いは？**
A: 
- **curlパイプ**: 常に最新版、シンプル、ネットワーク必須
- **ローカル実行**: Git履歴確認可能、オフライン実行可能、選択的更新対応

### 更新・メンテナンス

**Q: どのくらいの頻度で更新すべきですか？**
A: 
- **推奨**: 月1回の定期更新
- **最低**: 四半期に1回
- **重要更新時**: GitHub Releasesの通知に従って

**Q: カスタマイズした設定が消える心配はありませんか？**
A: いいえ。カスタマイズ保護機能により以下が自動実行されます：
- カスタマイズファイルの自動検出
- インテリジェントマージによる設定統合
- 更新前の自動バックアップ

**Q: 更新に失敗した場合のロールバック方法は？**
A: 
```bash
# 最新のバックアップに復元
~/.claude/scripts/update.sh --rollback

# または特定のバックアップから復元
~/.claude/scripts/backup.sh list
~/.claude/scripts/backup.sh restore 2
```

### バックアップ・復元

**Q: バックアップはどこに保存されますか？**
A: `~/.claude-backups/` ディレクトリに以下の形式で保存：
```
claude-backup_YYYYMMDD_HHMMSS.tar.gz
```

**Q: バックアップの自動削除はいつ実行されますか？**
A: 30日を経過したバックアップが `cleanup` コマンド実行時に削除されます。

**Q: 他のマシンに設定を移行できますか？**
A: はい。バックアップファイルを他のマシンにコピーして復元可能：
```bash
# 移行元でバックアップ作成
~/.claude/scripts/backup.sh backup

# バックアップファイルを移行先にコピー
scp ~/.claude-backups/claude-backup_*.tar.gz user@newmachine:~/

# 移行先でインストール後、復元
./scripts/install.sh
~/.claude/scripts/backup.sh restore 1
```

### 機能・使用方法

**Q: Claude Code以外のAIツールでも使用できますか？**
A: 基本的にClaude Code専用ですが、一部のテンプレートやワークフローは他のツールでも参考になります。

**Q: チーム開発で共有する方法は？**
A: 
1. プロジェクトごとの `CLAUDE.md` をカスタマイズ
2. チーム用のプライベートリポジトリでフォーク
3. チーム共通のテンプレート・ワークフロー作成

**Q: 調査・分析コマンド（/research等）が動作しません**
A: 
1. Claude Codeで `~/.claude/CLAUDE.md` が正しく読み込まれているか確認
2. 最新版への更新確認
3. コマンド定義ファイル（`commands/`）の存在確認

### トラブル対応

**Q: スクリプト実行権限がない場合は？**
A: 
```bash
# 実行権限付与
chmod +x ~/.claude/scripts/*.sh

# または直接実行
bash ~/.claude/scripts/backup.sh backup
```

**Q: ネットワーク環境でcurlが使用できない場合は？**
A: 
1. ローカル実行を使用
2. プロキシ設定を追加
3. 管理者にファイアウォール設定を確認依頼

**Q: ディスク容量不足でバックアップ作成できない場合は？**
A: 
1. 古いバックアップを削除: `~/.claude/scripts/backup.sh cleanup`
2. 不要ファイルの削除
3. バックアップ場所の変更（要スクリプト修正）

## 🛠 メンテナンス

### 定期メンテナンスタスク

#### 週次（推奨）
```bash
# 1. 現在の設定をバックアップ
~/.claude/scripts/backup.sh backup

# 2. 古いバックアップを削除
~/.claude/scripts/backup.sh cleanup
```

#### 月次（推奨）
```bash
# 1. バックアップ作成
~/.claude/scripts/backup.sh backup

# 2. 最新版への更新
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/update.sh | bash

# 3. 動作確認
# Claude Codeで: /research テスト調査

# 4. バックアップクリーンアップ
~/.claude/scripts/backup.sh cleanup
```

#### 四半期（最低限）
```bash
# 1. フルバックアップ
~/.claude/scripts/backup.sh backup

# 2. バージョン確認
~/.claude/scripts/version.sh --info

# 3. 互換性チェック
~/.claude/scripts/check-compatibility.sh --diagnose

# 4. 強制更新（必要に応じて）
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/install.sh | bash
```

### ヘルスチェック

**日常のクイックチェック**:
```bash
# Claude Dev Workflow の基本確認
ls -la ~/.claude/CLAUDE.md
cat ~/.claude/.claude-version

# スクリプトの実行権限確認
ls -la ~/.claude/scripts/
```

**詳細な健全性チェック**:
```bash
# ファイル整合性チェック
~/.claude/scripts/check-compatibility.sh --check

# バックアップ整合性チェック
for file in ~/.claude-backups/*.tar.gz; do
  echo "Checking: $(basename "$file")"
  tar -tzf "$file" >/dev/null && echo "✅ OK" || echo "❌ BROKEN"
done

# 権限確認
find ~/.claude -type f -name "*.sh" -exec ls -la {} \;
```

### アンインストール

**完全削除（注意：設定も削除されます）**:
```bash
# 最終バックアップ作成
~/.claude/scripts/backup.sh backup

# Claude Dev Workflow削除
rm -rf ~/.claude

# バックアップディレクトリ削除（任意）
rm -rf ~/.claude-backups
```

**一時的な無効化**:
```bash
# Claude Dev Workflow を一時的に移動
mv ~/.claude ~/.claude.disabled

# 復元時
mv ~/.claude.disabled ~/.claude
```

### 設定の継続的改善

#### カスタマイズの記録
```bash
# カスタマイズ履歴の確認
~/.claude/scripts/customization-history.sh --list

# 重要な変更を記録
~/.claude/scripts/customization-history.sh --add ~/.claude/CLAUDE.md "project_specific" "プロジェクト固有の設定追加"
```

#### パフォーマンス最適化
- 不要なテンプレートファイルの削除
- 大きなバックアップファイルの定期削除
- カスタマイズファイルの統合・整理

#### セキュリティ考慮事項
- バックアップファイルの暗号化（機密プロジェクト）
- リモートバックアップの設定
- アクセス権限の定期見直し

---

## 📞 サポート

### 問題が解決しない場合

1. **GitHub Issues**: [claude-dev-workflow/issues](https://github.com/Yuki-Sakaguchi/claude-dev-workflow/issues)
2. **ドキュメント**: `~/.claude/docs/` のその他のドキュメント
3. **コミュニティ**: DiscussionsでQ&A

### バグ報告時の情報

以下の情報を含めてください：
```bash
# システム情報
uname -a
echo "Shell: $SHELL"

# Claude Dev Workflow情報
cat ~/.claude/.claude-version
~/.claude/scripts/version.sh --info

# エラーログ
# 実行時のエラーメッセージ全体
```

### 機能リクエスト

新機能のリクエストは [GitHub Issues](https://github.com/Yuki-Sakaguchi/claude-dev-workflow/issues) で `enhancement` ラベルを付けて投稿してください。

---

*このドキュメントは Claude Dev Workflow v1.0.0 に基づいています。最新情報は [GitHub リポジトリ](https://github.com/Yuki-Sakaguchi/claude-dev-workflow) を確認してください。*