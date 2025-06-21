# `/pr-review` コマンド

## 🎯 概要

GitHub PRのレビューコメントを自動で取得・分析し、効率的に修正対応を行うカスタムコマンドです。

## 🚀 使用方法

### 基本コマンド
```
/pr-review <PR番号>
```

### 高度なオプション
```
/pr-review <PR番号> --priority <critical|important|minor>
/pr-review <PR番号> --auto-fix <true|false>
/pr-review <PR番号> --include-tests <true|false>
/pr-review <PR番号> --focus <security|performance|style>
```

## 📋 実行フロー

### 1. レビュー分析フェーズ
- PRのレビューコメントを取得
- 重要度別に分類（Critical/Important/Minor）
- 修正範囲と影響度を分析
- 修正計画を自動生成

### 2. 修正実装フェーズ
- 優先度順に修正を実行
- 各修正後に自動テスト実行
- コード品質チェック実行
- 関連ドキュメントの更新

### 3. 品質確認フェーズ
- 全体テストの実行
- リンター・型チェックの実行
- テストカバレッジの確認
- 修正内容の最終確認

### 4. 完了フェーズ
- 修正内容をコミット
- プッシュ実行
- レビュー完了レポート生成

## 🔧 実装仕様

### Claude Code実行内容

```markdown
## PRレビュー対応開始

1. **レビュー取得・分析**
   ```bash
   gh pr view {PR番号} --comments
   gh api repos/:owner/:repo/pulls/{PR番号}/reviews
   ```

2. **重要度分類**
   - 🔴 Critical: セキュリティ・バグ・破壊的変更
   - 🟡 Important: パフォーマンス・設計・可読性  
   - 🟢 Minor: スタイル・命名・ドキュメント

3. **修正計画作成**
   ```markdown
   ## 修正計画
   ### Critical Issues
   - [ ] [file:line] 修正内容
   ### Important Issues  
   - [ ] [file:line] 修正内容
   ### Minor Issues
   - [ ] [file:line] 修正内容
   ```

4. **段階的修正実行**
   - Critical → Important → Minor の順で実行
   - 各段階で品質チェック実行
   - テスト追加・更新

5. **完了処理**
   - 修正完了のコミット作成
   - プッシュ実行
   - レビュー完了レポート生成
```

### 自動実行内容

#### レビュー取得
```bash
gh pr view $PR_NUMBER --comments --json reviews,comments
```

#### 品質チェック
```bash
npm run lint
npm run typecheck  
npm run test
npm run test:coverage
```

#### コミット・プッシュ
```bash
git add .
git commit -m "fix: レビュー指摘事項の修正

- Critical issues: {count}件修正
- Important issues: {count}件修正  
- Minor issues: {count}件修正
- Tests: {count}件追加/更新

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"

git push origin HEAD
```

## 📊 オプション詳細

### `--priority`
特定の重要度のみに焦点を当てて修正
- `critical`: Critical issuesのみ対応
- `important`: Critical + Important issuesを対応
- `minor`: 全ての issues を対応（デフォルト）

### `--auto-fix`  
自動修正の範囲を制御
- `true`: 可能な限り自動で修正実行（デフォルト）
- `false`: 修正計画のみ作成し、実装は手動

### `--include-tests`
テスト関連の処理を制御
- `true`: テスト追加・更新を実行（デフォルト）
- `false`: テスト処理をスキップ

### `--focus`
特定の観点に焦点を当てた修正
- `security`: セキュリティ関連のみ
- `performance`: パフォーマンス関連のみ
- `style`: コードスタイル関連のみ

## 🎯 使用例

### 基本的な使用例
```
/pr-review 123
```
**実行内容**: PR #123の全レビューコメントに対応

### クリティカルな問題のみ対応
```
/pr-review 123 --priority critical
```
**実行内容**: セキュリティ・バグのみ緊急対応

### 修正計画のみ作成
```
/pr-review 123 --auto-fix false
```
**実行内容**: 修正計画を作成し、実装は手動で行う

### セキュリティ観点の修正
```
/pr-review 123 --focus security --include-tests true
```
**実行内容**: セキュリティ関連の修正とテスト強化

## 📋 出力レポート例

```markdown
# PRレビュー対応完了レポート

## 📊 対応サマリー
- **PR番号**: #123
- **レビューコメント総数**: 15件
- **修正完了**: 15件
- **テスト追加**: 3件
- **実行時間**: 12分30秒

## 🔍 重要度別対応状況
### 🔴 Critical Issues (5件)
- ✅ auth.ts:45 - SQLインジェクション脆弱性修正
- ✅ api.ts:120 - 認証バイパス修正
- ✅ utils.ts:78 - XSS脆弱性修正
- ✅ db.ts:200 - データ漏洩リスク修正
- ✅ validation.ts:55 - 入力検証強化

### 🟡 Important Issues (7件)
- ✅ performance.ts:33 - N+1クエリ問題修正
- ✅ cache.ts:91 - キャッシュ戦略改善
- ✅ component.tsx:156 - レンダリング最適化
- ✅ api.ts:89 - レスポンス時間改善
- ✅ memory.ts:67 - メモリリーク修正
- ✅ algorithm.ts:134 - 計算量改善
- ✅ database.ts:203 - インデックス最適化

### 🟢 Minor Issues (3件)  
- ✅ styles.css:45 - CSS命名規則修正
- ✅ README.md:78 - ドキュメント更新
- ✅ types.ts:23 - 型定義整理

## 🧪 テスト結果
- **テストカバレッジ**: 87% → 92%
- **追加テスト**: 3ファイル、15テストケース
- **実行結果**: 全テスト PASS

## 🚀 次のアクション
- [x] 修正内容をコミット・プッシュ完了
- [ ] レビュアーへの完了通知（手動）
- [ ] CI/CDパイプラインの確認（自動）
```

## 🔄 ワークフロー連携

### Git連携
- 現在のブランチで修正を実行
- 自動的にコミット・プッシュ
- コミットメッセージは規則に準拠

### CI/CD連携
- プッシュ後の自動テスト実行
- デプロイプロセスとの連携
- 品質ゲートの確認

### 通知連携
- Slack/Teams通知（設定時）
- メール通知（設定時）
- GitHub Issue自動更新

## 🆘 トラブルシューティング

### エラー対応

#### 認証エラー
```bash
gh auth status
gh auth login
```

#### レビュー取得失敗
- PR番号の確認
- リポジトリアクセス権限の確認
- GitHub API制限の確認

#### 修正実行失敗
- ファイルの存在確認
- 編集権限の確認
- 競合状態の解消

## 📚 関連ドキュメント

- [PRレビューワークフロー](../workflow/pr-review-workflow.md)
- [Git運用ルール](../workflow/git-workflow.md)  
- [品質管理ガイド](../workflow/tdd-process.md)
- [テンプレート集](../templates/)

---

**効率的なPRレビュー対応で開発速度と品質を両立させましょう！**