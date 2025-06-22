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
- 3-5倍の開発効率向上

## セットアップ

### 🚀 自動インストール（推奨）
ワンコマンドで簡単セットアップ：

```bash
# このリポジトリをクローンしてインストール
git clone https://github.com/Yuki-Sakaguchi/claude-dev-workflow.git
cd claude-dev-workflow
./scripts/install.sh
```

**または直接実行**:
```bash
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/install.sh | bash
```

#### 🔧 インストール機能（v1.1.0改善）
- **動的ファイル取得**: GitHub APIで全ファイルを自動検出・ダウンロード
- **完全自動化**: 新しいコマンドやテンプレートも漏れなく取得
- **エラー耐性**: curlパイプ実行時の堅牢なエラーハンドリング
- **進捗表示**: 詳細なダウンロード状況をリアルタイム表示

### 📁 手動インストール
```bash
# このリポジトリをクローン
git clone https://github.com/Yuki-Sakaguchi/claude-code-template.git ~/.claude

# または手動でファイルをコピー
cp -r . ~/.claude/
```

### 📂 インストール後の構成
```
~/.claude/
├── CLAUDE.md                    # メインガイド
├── .claude-version              # バージョン情報
├── commands/                    # カスタムスラッシュコマンド（14個）
│   ├── start-project.md         # プロジェクト開始
│   ├── implement.md             # 機能実装
│   ├── auto-review.md           # 自動レビュー
│   ├── research.md              # 一般調査
│   ├── tech-research.md         # 技術比較
│   ├── analyze-codebase.md      # コード分析
│   ├── competitor-analysis.md   # 競合分析
│   ├── pr-review.md             # PRレビュー対応
│   └── ...（計14個のコマンド）
├── requirements/                # 要件定義関連（2個）
├── workflow/                    # 開発ワークフロー（7個）
├── templates/                   # 各種テンプレート（11個）
├── docs/                        # ドキュメント・アイデア保存
│   └── idea/                    # 調査結果・分析レポート
└── scripts/                     # 管理スクリプト
    ├── install.sh               # インストールスクリプト
    ├── update.sh                # 更新スクリプト
    └── backup.sh                # バックアップ管理スクリプト
```

**📊 動的取得により計37個のファイルを自動取得！**（scriptsディレクトリ込み）

### 🔄 アップデート方法

#### 🚀 リモート実行（推奨）
ワンコマンドで最新版に更新：

```bash
curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/update.sh | bash
```

#### 📁 ローカル実行
インストール済み環境での更新：

```bash
# ~/.claude ディレクトリで実行
cd ~/.claude
./scripts/update.sh
```

#### 🔧 更新機能（v1.1.0改善）
- **リモート実行対応**: https経由での直接更新が可能
- **スマート更新**: カスタマイズファイルを自動検出・保護
- **選択的更新**: 個別ファイル選択による部分更新対応（ローカル実行時）
- **動的取得**: 新しいファイルも自動で更新対象に含める
- **ロールバック**: 更新前の自動バックアップとワンクリック復旧

### 💾 バックアップ管理
Claude Dev Workflow設定の安全なバックアップ・復元が可能：

```bash
# バックアップ作成
~/.claude/scripts/backup.sh backup

# バックアップ一覧表示
~/.claude/scripts/backup.sh list

# 指定したバックアップから復元
~/.claude/scripts/backup.sh restore 1

# 古いバックアップ削除（30日以上）
~/.claude/scripts/backup.sh cleanup
```

#### 🛡️ バックアップ機能
- **タイムスタンプ付きバックアップ**: `claude-backup_YYYYMMDD_HHMMSS.tar.gz`
- **自動圧縮**: tar.gz形式でファイルサイズを最適化
- **安全な復元**: 復元前に現在の設定を自動バックアップ
- **整合性チェック**: バックアップファイルの破損検出
- **自動削除**: 30日以上古いバックアップを自動削除

### 3. ガイドライン読み込み（重要！）
Claude Codeに以下を指示してガイドラインを読み込ませてください：
```
~/.claude/CLAUDE.md の内容を読み込んで、今後このガイドラインに従って動作してください
```

### 4. 動作確認
読み込みが成功すると、Claude Codeが以下のように応答します：
```
ガイドラインを読み込みました。今後このガイドラインに従って動作します。
利用可能なコマンド: /start-project, /implement, /auto-review など
```

## 🚀 クイックスタート（初回セットアップ）

**⚠️ 最初に必ず実行**：
```
~/.claude/CLAUDE.md の内容を読み込んで、今後このガイドラインに従って動作してください
```

### Step 1: 最初のプロジェクト作成
```bash
/start-project [プロジェクト名]
```
30分で要件定義〜GitHub Issue作成まで完了

### Step 2: 開発開始
```bash
/implement issue #1
```
1つのコマンドで実装〜テスト〜PR作成まで自動実行

### Step 3: 品質チェック
```bash
/auto-review [ブランチ名]
```
プロレベルの自動コードレビューで品質確保

**これだけで個人開発が3-5倍効率化されます！**

## 📋 日常的な使い方

### 朝の作業開始
```bash
/implement issue #15    # 今日のタスクを1コマンドで実装
```

### 作業完了時
```bash
/auto-review feature/issue-15-payment   # 自動品質チェック
```

### 調査・分析が必要な時
```bash
/tech-research Next.js vs Nuxt.js    # 技術比較調査
/competitor-analysis Notion          # 競合分析
/analyze-codebase                     # コードベース分析
```

## 使用方法（詳細）

### 完全自動化開発フロー

#### 1. プロジェクト開始
```
/start-project タスク管理アプリ
```
- 要件定義ヒアリング
- ドキュメント作成
- GitHub Issue作成準備

#### 2. 環境構築
```
/setup-automation React + TypeScript + Vitest
```
- 自動化ツール設定
- CI/CD環境構築
- テスト環境準備

#### 3. 開発計画
```
/create-issues docs/01_要件定義書.md
```
- Phase分けしたIssue作成
- 優先度・依存関係設定
- 見積もり・工数設定

#### 4. 機能実装（繰り返し）
```
/implement issue #1
/implement issue #2
/implement issue #3
```
- TDDサイクル自動実行
- ブランチ作成→実装→テスト→PR作成
- ドキュメント自動更新

#### 5. 品質確認
```
/review-ready feature/issue-1-user-auth
```
- 全テスト通過確認
- アクセプタンス基準達成確認
- ドキュメント整合性確認

#### 6. 自動レビュー
```
/auto-review feature/issue-1-user-auth
```
- プロレベルの品質チェック
- セキュリティ・パフォーマンス確認
- 改善提案と学習ポイント抽出

#### 7. ドキュメント同期
```
/update-docs ユーザー認証機能
```
- README・CHANGELOG更新
- API仕様書生成
- アクセプタンス基準完了チェック

#### 8. バグ修正（必要時）
```
/fix-bug ログイン時のセッションエラー
```
- 原因分析→修正→テスト→PR作成
- 再発防止策の実装

#### 9. 調査・分析（必要時）
```
/research PWAの導入可能性
/tech-research Docker vs Podman
/competitor-analysis タスク管理アプリ
/analyze-codebase パフォーマンス改善
```
- 体系的な情報収集・分析
- 構造化されたレポート作成
- `docs/idea/` に結果保存

#### 10. PRレビュー対応（必要時）
```
/pr-review 123                              # 基本使用
/pr-review 123 --priority critical          # 緊急対応のみ
/pr-review 123 --focus security             # セキュリティ特化
/pr-review 123 --auto-fix false             # 計画のみ作成
```
- レビューコメント自動取得・分析
- 重要度別分類（Critical/Important/Minor）
- 段階的修正実行・品質チェック
- 修正完了レポート自動生成

## 利用可能なコマンド一覧

### 🚀 開発フロー
- `/start-project` - プロジェクト開始・要件定義
- `/setup-automation` - 環境構築・自動化設定
- `/create-issues` - GitHub Issue作成
- `/implement` - 機能実装（TDD自動実行）
- `/fix-bug` - バグ修正
- `/review-ready` - リリース前品質チェック
- `/auto-review` - 自動コードレビュー
- `/update-docs` - ドキュメント更新

### 🔍 調査・分析
- `/research` - 一般調査（市場・技術・可能性調査）
- `/tech-research` - 技術比較調査
- `/competitor-analysis` - 競合分析
- `/analyze-codebase` - コードベース分析

### 🔧 PRレビュー対応
- `/pr-review` - PRレビューコメント自動対応（取得・分析・修正実行）

## 効果測定

| 項目 | 従来 | 使用後 |
|------|------|--------|
| 要件定義時間 | 2-3日 | **半日** |
| 機能実装速度 | 基準 | **3-5倍** |
| コードレビュー | 手動・属人的 | **自動・客観的** |
| テストカバレッジ | 20-40% | **80%以上** |
| ドキュメント更新漏れ | 頻発 | **0件** |

## 🚀 最新の改善点

### 📦 動的ファイル取得機能（v1.1.0対応）

**問題解決**: install.shとupdate.shがハードコーディングされたファイルリストを使用していた問題を解決

#### 🔧 技術改善
- **リモート実行対応**: install.sh・update.sh両方でhttps経由実行が可能
- **GitHub API連携**: リアルタイムでファイル一覧を取得
- **自動スケーリング**: 新しいコマンド・テンプレートファイルを自動検出
- **階層構造対応**: `docs/idea/` 等のサブディレクトリもサポート
- **エラーハンドリング**: curlパイプ実行時の堅牢なエラー処理

#### 📊 取得ファイル数の改善実績
| ディレクトリ | 改善前 | 改善後 | 増加分 |
|-------------|--------|--------|--------|
| **commands** | 5個 | **14個** | **+9個** |
| **workflow** | 5個 | **7個** | **+2個** |
| **templates** | 7個 | **11個** | **+4個** |
| **requirements** | 2個 | **2個** | 維持 |
| **scripts** | 0個 | **3個** | **+3個** |
| **合計** | **19個** | **37個** | **+18個** |

#### 🎯 ユーザーメリット
- **完全自動化**: 新機能追加時にメンテナンス不要
- **常に最新**: 全てのコマンド・テンプレートを漏れなく取得
- **一貫性保証**: install/update両方で同じ仕組み

**これで今後コマンドやテンプレートが追加されても、自動で取得されます！**

## トラブルシューティング

### Claude Codeが期待通りに動作しない
1. 該当するガイドラインファイルを明示的に指定
2. 段階的に指示を分割して実行
3. 具体的な成果物を明示

### ファイルが見つからないエラー
1. `~/.claude/` にファイルが正しく配置されているか確認
2. ファイルパスに誤字がないか確認
3. 必要に応じて絶対パスで指定

## Tips

許可が必要なコマンドをスキップして実行する

```bash
claude --dangerously-skip-permissions
```
