# Claude Code 開発ガイドライン

## 🎯 このガイドラインについて

個人開発プロジェクトにおいて、Claude Codeと効率的に協働するための包括的なガイドラインです。
要件定義からリリースまで、一貫した品質でプロジェクトを進行できる体系を提供します。

## 📋 プロジェクト開始時

### 1. 要件定義プロセス
新しいプロジェクトを始める際の手順：

1. **[事前準備シート](templates/preparation-sheet.md)**を記入
2. **[ヒアリングテンプレート](requirements/interview-template.md)**でClaude Codeに要件整理を依頼
3. **[ドキュメント構造](requirements/document-structure.md)**に従ってプロジェクト文書を作成

**Claude Codeへの指示例**:
```
templates/preparation-sheet.mdを元に、
requirements/interview-template.mdの手順で詳細をヒアリングしてください。
```

### 2. 環境構築
**[自動化ツール設定](templates/automation-setup.md)**に従って開発環境を整備

**Claude Codeへの指示例**:
```
templates/automation-setup.mdに従って、
プロジェクトの自動化環境を構築してください。
```

## 🔄 開発フロー

### 全体の流れ
```
要件定義 → Issue作成 → 機能実装 → PR作成 → レビュー → マージ
         ↓
      調査・分析（技術選定・競合分析・コードベース分析）
```

### 3. 開発ワークフロー
- **[開発フロー全体](workflow/development-flow.md)** - 機能実装とドキュメント更新の同期実行
- **[Git運用](workflow/git-workflow.md)** - ブランチ戦略とワークフロー自動化
- **[TDD手順](workflow/tdd-process.md)** - テスト駆動開発とテスト戦略

### 4. 調査・分析ワークフロー
- **[調査プロセス](workflow/research-process.md)** - 体系的な調査手法と情報収集
- **[分析手法](workflow/analysis-methods.md)** - 分析手法とツールの使い分け

**Claude Codeへの指示例**:
```
issue #12 のユーザーログイン機能を実装してください。
workflow/以下のファイルに従って進めてください。
```

## 📝 テンプレート集

### 5. 各種テンプレート
- **[Issue作成](templates/issue-template.md)** - GitHub Issue自動生成
- **[PR作成](templates/pr-template.md)** - Pull Request自動生成  
- **[コミット規則](templates/commit-message.md)** - Conventional Commits準拠
- **[調査結果](templates/research-template.md)** - 調査レポートの標準化フォーマット
- **[分析レポート](templates/analysis-report.md)** - 分析結果レポートテンプレート

**Claude Codeへの指示例**:
```
要件定義書からGitHub Issueを作成してください。
templates/issue-template.mdに従って進めてください。
```

## 🚀 使用シーン別ガイド

### 新規プロジェクト開始
```
1. templates/preparation-sheet.md を記入
2. Claude Code に要件定義依頼
3. templates/automation-setup.md で環境構築
4. GitHub Repository 作成
5. 開発開始
```

### 機能実装
```
1. "issue #XX を実装して" と指示
2. Claude Code が自動実行:
   - ブランチ作成
   - TDDサイクル実行
   - ドキュメント更新
   - PR作成
3. レビュー・マージ
```

### バグ修正
```
1. GitHub Issue 作成
2. "issue #XX のバグを修正して" と指示
3. Claude Code が自動実行:
   - hotfix ブランチ作成
   - バグ修正・テスト追加
   - PR作成
```

### 調査・分析
```
1. 調査目的の明確化
2. "/research" "/analyze-codebase" "/competitor-analysis" "/tech-research" で指示
3. Claude Code が自動実行:
   - 体系的な情報収集
   - 複数観点での分析
   - 構造化されたレポート作成
```

## 💡 Claude Code への効果的な指示方法

### ✅ 良い指示例

**要件定義時**:
```
この準備シートを元に、requirements/interview-template.mdの手順で
詳細をヒアリングして、要件定義関連ドキュメントを作成してください。
```

**機能実装時**:
```
issue #15 の決済処理機能を実装してください。
workflow/development-flow.mdに従って、TDDサイクルで進めてください。
```

**環境構築時**:
```
templates/automation-setup.mdに従って、自動化ツールを設定してください。
設定完了後、動作確認も実行してください。
```

**調査・分析時**:
```
/tech-research Next.js vs Nuxt.js の比較調査をして、
個人開発プロジェクトに適した選択肢を提案してください。
```

**コードベース分析時**:
```
/analyze-codebase このReactアプリのパフォーマンス分析をして、
改善提案とリファクタリング計画を作成してください。
```

**競合分析時**:
```
/competitor-analysis Notionなどのノートアプリの競合分析をして、
差別化戦略を提案してください。
```

### ❌ 避けるべき指示例

```
# 曖昧すぎる
"ログイン機能を作って"
"テストも書いて"
"競合を調べて"
"技術を選んで"

# 情報不足
"バグを直して"
"設定を変更して"
"分析をして"
"調査をして"
```

## 🔧 カスタマイズガイド

### プロジェクトに応じた調整

**技術スタック変更時**:
- `workflow/tdd-process.md` のテストツール設定を更新
- `templates/automation-setup.md` の依存関係を調整
- `workflow/analysis-methods.md` の分析ツール設定を更新

**チーム開発時**:
- `templates/pr-template.md` にレビュアー指定項目を追加
- `workflow/git-workflow.md` にコードレビュー規則を詳細化
- `workflow/research-process.md` に情報共有プロセスを追加

**企業・商用プロジェクト時**:
- `requirements/document-structure.md` にセキュリティ・法務ドキュメントを追加
- `workflow/development-flow.md` にリリース承認プロセスを追加
- `templates/analysis-report.md` にコンプライアンス要件を追加

## 🎛️ 品質管理

### 継続的改善

**週次確認項目**:
- [ ] Phase進捗の確認
- [ ] テストカバレッジの確認
- [ ] ドキュメント更新状況の確認
- [ ] 調査・分析結果の活用状況

**月次見直し項目**:
- [ ] Issue粒度の適切性
- [ ] Claude Code指示の効率性
- [ ] 自動化ツールの動作状況
- [ ] 調査手法・分析精度の評価

**プロジェクト完了時**:
- [ ] 全体フローの振り返り
- [ ] テンプレート改善点の記録
- [ ] 次回プロジェクトへの改善案
- [ ] 調査・分析ナレッジの蓄積

## 📊 成功指標

### プロセス効率性
- **要件定義時間**: 従来の50%短縮目標
- **実装速度**: TDD適用で品質向上しつつ効率化
- **ドキュメント更新漏れ**: 0件（自動化により）
- **調査・分析時間**: 体系的なプロセスで30%効率化

### 品質指標
- **テストカバレッジ**: 80%以上維持
- **バグ発生率**: Phase1完了時点で最小化
- **技術負債**: リファクタリング自動実行で最小化
- **意思決定精度**: 調査結果活用により向上

## 🆘 トラブルシューティング

### よくある問題と解決策

**Claude Codeが期待通りに動作しない**:
1. 指示が具体的かどうか確認
2. 該当するテンプレートファイルを明示的に指定
3. 段階的に指示を分割して実行

**自動化ツールが動作しない**:
1. `templates/automation-setup.md` の設定確認
2. 依存関係のバージョン確認
3. エラーログの詳細確認

**ドキュメントの整合性問題**:
1. `requirements/document-structure.md` の構造確認
2. 自動更新スクリプトの動作確認
3. 手動更新部分の見直し

**調査・分析結果の精度が低い**:
1. `workflow/research-process.md` の手順確認
2. 情報源の信頼性・多様性見直し
3. 分析観点・評価基準の再設定

**調査コマンドが適切に動作しない**:
1. 調査目的・範囲の明確化
2. 適切なコマンド（/research, /tech-research等）の選択
3. `workflow/analysis-methods.md` の手法確認

## 📚 参考資料・外部リンク

### 開発手法
- [Test-Driven Development](https://martinfowler.com/bliki/TestDrivenDevelopment.html)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)

### ツール・ライブラリ
- [Vitest](https://vitest.dev/) - テストフレームワーク
- [Storybook](https://storybook.js.org/) - UIコンポーネント開発
- [Playwright](https://playwright.dev/) - E2Eテスト
- [TypeScript](https://www.typescriptlang.org/) - 型安全な開発

---

## 🎉 このガイドラインの活用で期待できる効果

- **開発効率**: Claude Codeとの協働で3-5倍の生産性向上
- **品質向上**: TDD + 自動テストで安定したコード品質
- **保守性**: 一貫したドキュメント管理で将来の自分が助かる
- **学習効果**: 体系的なプロセスで開発スキルの向上
- **意思決定精度**: 体系的な調査・分析による的確な判断
- **リスク軽減**: 事前の調査・分析による課題の早期発見

## 📋 新しい調査・分析コマンド

### 利用可能なコマンド
- **`/research`** - 一般的な調査（技術選定・市場調査等）
- **`/analyze-codebase`** - コードベース分析（品質・パフォーマンス・セキュリティ）
- **`/competitor-analysis`** - 競合分析（機能・戦略・市場ポジション）
- **`/tech-research`** - 技術調査（フレームワーク・ライブラリ比較）

### 使用例
```
/tech-research Next.js vs Nuxt.js の個人開発向け比較
/analyze-codebase パフォーマンス改善のためのコード分析
/competitor-analysis ノートアプリの市場分析と差別化戦略
/research PWAの導入可能性調査
```

**最初は完璧を目指さず、段階的にプロセスを改善していくことが成功の鍵です。**

Happy Coding with Claude! 🚀