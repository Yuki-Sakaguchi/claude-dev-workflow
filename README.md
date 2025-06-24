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

その他のアップデートコマンドは [scripts - README.md](scripts/README.md)

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

## ⚠️ トラブルシューティング

### Claude Codeが期待通りに動作しない
1. `/clear` を実行し、メモリをクリアにする
2. 該当するガイドラインファイルを明示的に指定
3. 段階的に指示を分割して実行
4. 具体的な成果物を明示

### ファイルが見つからないエラー
1. `~/.claude/` にファイルが正しく配置されているか確認
2. ファイルパスに誤字がないか確認
3. 必要に応じて絶対パスで指定
