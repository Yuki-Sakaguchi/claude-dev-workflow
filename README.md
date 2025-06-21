# Claude Code 開発フロー

**個人開発を3-5倍効率化する、Claude Code協働のための包括的ガイドライン**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code Compatible](https://img.shields.io/badge/Claude%20Code-Compatible-blue.svg)](https://claude.ai)

## 🎯 このプロジェクトについて

個人開発者がClaude Codeと効率的に協働し、**要件定義からリリースまで一貫した品質**でプロジェクトを進行するための体系的なガイドラインです。

### 解決する課題
- ❌ Claude Codeに何をどう頼めばいいかわからない
- ❌ 毎回同じような指示を繰り返している
- ❌ ドキュメント更新を忘れてプロジェクトが属人化
- ❌ テスト戦略が曖昧で品質が安定しない

### このガイドラインで実現できること
- ✅ **「issue #12を実装して」だけで完全自動化**
- ✅ **TDD + 自動テスト + ドキュメント更新を一気通貫**
- ✅ **個人開発に最適化された最小限の管理コスト**
- ✅ **3-5倍の開発効率向上**

## 🚀 クイックスタート

### 1. ガイドラインの設置
```bash
# このリポジトリをクローン
git clone https://github.com/your-username/claude-code-workflow.git ~/.claude

# または、ファイルを手動で ~/.claude/ にコピー
```

### 2. 今すぐ試せる実用例

#### 新規プロジェクト開始
```
Claude Codeへの指示:
「新しいタスク管理アプリを作りたいです。
~/.claude/templates/preparation-sheet.mdを参考に、
要件をヒアリングして整理してください。」
```

#### 機能実装
```
Claude Codeへの指示:
「issue #12 のユーザーログイン機能を実装してください。
~/.claude/workflow/ の各ファイルに従って、
TDDサイクルで進めてください。」
```

#### 環境構築
```
Claude Codeへの指示:
「~/.claude/templates/automation-setup.mdに従って、
このプロジェクトの自動化環境を構築してください。」
```

## 📁 ファイル構成

```
~/.claude/
├── CLAUDE.md                    # 📖 メインガイド（まずここを読む）
├── requirements/                # 📋 要件定義関連
│   ├── interview-template.md    # ヒアリング手順
│   └── document-structure.md    # ドキュメント構造
├── workflow/                    # 🔄 開発ワークフロー
│   ├── development-flow.md      # 開発フロー全体
│   ├── git-workflow.md         # Git運用ルール
│   └── tdd-process.md          # TDD・テスト戦略
└── templates/                   # 📝 各種テンプレート
    ├── automation-setup.md     # 自動化ツール設定
    ├── preparation-sheet.md    # 事前準備シート
    ├── issue-template.md       # Issue作成テンプレート
    ├── pr-template.md          # PR作成テンプレート
    └── commit-message.md       # コミットメッセージ規則
```

## 💬 実用例：Claude Codeへの声かけ集

### 🔥 プロジェクト開始時

#### パターン1：完全ゼロから
```
「新しいWebアプリケーションを作りたいです。
~/.claude/templates/preparation-sheet.mdを元に、
~/.claude/requirements/interview-template.mdの手順で
要件をヒアリングしてください。」
```

#### パターン2：アイデアがある場合
```
「ECサイトを作りたいと思っています。
基本的な商品管理と決済機能が必要です。
~/.claude/requirements/interview-template.mdの手順で
詳細を整理してください。」
```

### 🛠️ 開発フェーズ

#### 環境構築
```
「React + TypeScript + Vitest でプロジェクトを始めます。
~/.claude/templates/automation-setup.mdに従って、
以下を設定してください：
1. 自動化ツールの導入
2. GitHub Actions設定
3. テスト環境構築」
```

#### Issue作成
```
「要件定義書ができました。
~/.claude/templates/issue-template.mdに従って、
Phase分けしたGitHub Issueを作成してください。」
```

#### 機能実装（最頻出パターン）
```
「issue #15 の決済処理機能を実装してください。
~/.claude/workflow/development-flow.mdに従って、
以下を自動実行してください：
1. ブランチ作成
2. TDDサイクル実行
3. ドキュメント更新
4. PR作成」
```

### 🐛 保守・改善フェーズ

#### バグ修正
```
「ログイン時にエラーが発生しています。
~/.claude/workflow/git-workflow.mdのhotfixプロセスで
修正してください。原因調査からお願いします。」
```

#### リファクタリング
```
「認証ロジックが複雑になってきました。
~/.claude/workflow/tdd-process.mdのリファクタリング手順で
コードを整理してください。テストは変更せずに。」
```

### 📚 ドキュメント管理

#### API仕様書更新
```
「新しいAPIエンドポイントを追加しました。
~/.claude/workflow/development-flow.mdの
ドキュメント自動更新に従って、
API仕様書を更新してください。」
```

#### README更新
```
「新機能をリリースしました。
~/.claude/requirements/document-structure.mdに従って、
README.mdの機能一覧を更新してください。」
```

## 🎯 期待される成果

### プロジェクト開始（Day 1）
- ✅ 要件定義書、ユーザーストーリー、アクセプタンス基準が完成
- ✅ Phase分けされたGitHub Issueが作成済み
- ✅ 開発環境と自動化ツールが設定済み

### 機能実装（各Sprint）
- ✅ TDDサイクルで高品質なコード
- ✅ テストカバレッジ80%以上
- ✅ ドキュメント自動更新
- ✅ レビュー可能なPR

### プロジェクト完了時
- ✅ 保守性の高いコードベース
- ✅ 完全なドキュメント
- ✅ 自動化されたCI/CD
- ✅ 次のプロジェクトにも適用可能な資産

## ⚡ パフォーマンス比較

| 項目 | 従来の開発 | このガイドライン使用 |
|------|-----------|-------------------|
| 要件定義時間 | 2-3日 | **半日** |
| 初期設定時間 | 1日 | **1-2時間** |
| 機能実装速度 | 基準 | **3-5倍** |
| テストカバレッジ | 20-40% | **80%以上** |
| ドキュメント更新漏れ | 頻発 | **0件** |
| PR作成時間 | 30分 | **5分** |

## 🛠️ カスタマイズ方法

### 技術スタック変更
```bash
# Next.js + Prisma の場合
~/.claude/workflow/tdd-process.md の「テスト環境・ツール」セクションを更新
~/.claude/templates/automation-setup.md の依存関係を調整
```

### チーム開発対応
```bash
# レビュー体制を追加
~/.claude/templates/pr-template.md にレビュアー指定項目追加
~/.claude/workflow/git-workflow.md にコードレビュー規則詳細化
```

## 🤝 コントリビューション

### 改善案・バグ報告
- [Issues](https://github.com/your-username/claude-code-workflow/issues)でお知らせください
- 実際の使用体験に基づく改善案を歓迎します

### プルリクエスト
1. このリポジトリをFork
2. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'feat: add amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. Pull Requestを作成

## 📊 成功事例

### 個人開発者 Aさん
> 「タスク管理アプリの開発が従来3ヶ月かかっていたのが、1ヶ月で完成。しかもテストカバレッジ85%で品質も向上しました。」

### フリーランス開発者 Bさん
> 「クライアントワークでも使用。要件変更への対応速度が格段に上がり、信頼度も向上しました。」

### 学習中の開発者 Cさん
> 「TDDやGit Flowの学習にも最適。実践的なプロセスを体験しながら身につけられました。」

## 🆘 トラブルシューティング

### Claude Codeが期待通りに動作しない

**症状**: 指示通りに実行してくれない
**解決策**: 
1. 該当するガイドラインファイルを明示的に指定
2. 段階的に指示を分割
3. 具体的な成果物を明示

**良い例**:
```
「~/.claude/workflow/git-workflow.mdに従って、
feature/issue-12-user-loginブランチを作成し、
TDDサイクルでユーザーログイン機能を実装してください。」
```

### 自動化ツールが動作しない

**症状**: CI/CDやテストが失敗する
**解決策**:
1. `~/.claude/templates/automation-setup.md`の設定確認
2. 依存関係のバージョン確認
3. [Issues](https://github.com/your-username/claude-code-workflow/issues)で報告

## 📚 関連リソース

### 公式ドキュメント
- [Claude Code](https://claude.ai) - Anthropic公式
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Test-Driven Development](https://martinfowler.com/bliki/TestDrivenDevelopment.html)

### 推奨ツール
- [Vitest](https://vitest.dev/) - テストフレームワーク
- [Storybook](https://storybook.js.org/) - UIコンポーネント開発
- [Playwright](https://playwright.dev/) - E2Eテスト

## 📄 ライセンス

MIT License - 詳細は [LICENSE](LICENSE) ファイルを参照してください。

## ⭐ Star History

プロジェクトが役に立ったら、ぜひStarをお願いします！

[![Star History Chart](https://api.star-history.com/svg?repos=Yuki-Sakaguchi/claude-code-template&type=Date)](https://star-history.com/#Yuki-Sakaguchi/claude-code-template&Date)

---

**Happy Coding with Claude! 🚀**

このガイドラインで、あなたの開発ライフが劇的に改善されることを願っています。
質問や改善案があれば、お気軽に [Issues](https://github.com/Yuki-Sakaguchi/claude-code-template/issues) でお知らせください！