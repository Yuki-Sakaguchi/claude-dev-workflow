# 自動レビュープロセス（Claude Code用）

## 概要

個人開発において、Claude Codeが客観的な第三者視点でPull Requestの品質レビューを実行するためのプロセス定義です。
一人開発では見落としがちな問題を発見し、プロレベルの品質向上と学習効果を実現します。

## 基本方針

### 個人開発に最適化された自動レビュー
- **客観的品質チェック**: 主観的判断を排除した一貫性のあるレビュー
- **学習促進**: なぜその指摘なのかを説明し、スキル向上をサポート
- **実用性重視**: 過度に厳格でなく、現実的な改善提案
- **効率性**: 重要な問題に集中し、枝葉末節は避ける

### 既存ワークフローとの連携
- @workflow/development-flow.md の品質基準に準拠
- @workflow/tdd-process.md のテスト戦略と整合
- @templates/pr-template.md の情報を活用

## レビュー観点・チェック項目

### 1. コード品質（必須）

#### 命名規則・可読性
```javascript
// 悪い例
function calc(x, y) { return x * y * 0.1; }

// 良い例  
function calculateTaxAmount(price, taxRate) {
  return price * taxRate * TAX_MULTIPLIER;
}
```

**チェック項目**:
- [ ] 変数・関数名が意図を明確に表している
- [ ] 定数が適切に定義されている
- [ ] マジックナンバーが排除されている
- [ ] 略語が適切に使用されている

#### 関数・クラス設計
**チェック項目**:
- [ ] 単一責任原則に従っている
- [ ] 関数が適切なサイズ（20-30行以内）
- [ ] 引数が適切な数（3-4個以内推奨）
- [ ] 戻り値の型が明確

#### DRY原則・重複コード
**チェック項目**:
- [ ] 同じロジックが複数箇所にない
- [ ] 共通処理が適切に抽出されている
- [ ] コピー&ペーストコードがない

### 2. アーキテクチャ・設計（重要）

#### 責務分離
**チェック項目**:
- [ ] UI・ビジネスロジック・データアクセスが分離
- [ ] 関心の分離ができている
- [ ] モジュール間の依存関係が適切

#### 拡張性・保守性
```typescript
// 悪い例：拡張が困難
if (userType === 'admin') { /* 処理A */ }
else if (userType === 'editor') { /* 処理B */ }
else if (userType === 'viewer') { /* 処理C */ }

// 良い例：拡張しやすい
const userHandlers = {
  admin: AdminHandler,
  editor: EditorHandler,
  viewer: ViewerHandler
};
userHandlers[userType].handle();
```

**チェック項目**:
- [ ] 新機能追加が容易な設計
- [ ] 変更の影響範囲が限定的
- [ ] インターフェースが適切に定義

#### パフォーマンス考慮
**チェック項目**:
- [ ] 不要な再計算・再描画がない
- [ ] 適切なキャッシュ戦略
- [ ] メモリリークの可能性がない
- [ ] N+1問題が発生していない

### 3. セキュリティ（Critical機能は必須）

#### 入力値検証
```javascript
// 悪い例：検証なし
function updateUser(userData) {
  return database.update(userData); // SQLインジェクション可能性
}

// 良い例：適切な検証
function updateUser(userData) {
  const validated = validateUserData(userData);
  if (!validated.isValid) {
    throw new ValidationError(validated.errors);
  }
  return database.update(validated.data);
}
```

**チェック項目**:
- [ ] 入力値バリデーションが実装されている
- [ ] SQLインジェクション対策がある
- [ ] XSS対策が適切
- [ ] 認証・認可が正しく実装

#### 機密情報管理
**チェック項目**:
- [ ] パスワード・APIキーがハードコードされていない
- [ ] 環境変数が適切に使用されている
- [ ] ログに機密情報が出力されていない

### 4. テスト品質（@workflow/tdd-process.md準拠）

#### テスト網羅性
**チェック項目**:
- [ ] 機能の重要度に応じたテスト範囲
- [ ] エッジケースのテストがある
- [ ] エラーケースのテストがある
- [ ] 境界値テストがある

#### テスト可読性
```javascript
// 悪い例：何をテストしているか不明
test('test1', () => {
  const result = func(1, 2);
  expect(result).toBe(3);
});

// 良い例：意図が明確
test('二つの正の整数を加算すると正しい結果を返す', () => {
  const result = addNumbers(1, 2);
  expect(result).toBe(3);
});
```

**チェック項目**:
- [ ] テスト名が意図を明確に表している
- [ ] Given-When-Then構造になっている
- [ ] テストが独立している（他のテストに依存しない）

### 5. ドキュメント・コメント

#### コード内ドキュメント
**チェック項目**:
- [ ] 複雑なロジックに適切な説明がある
- [ ] API仕様がJSDoc/TypeDocで記載
- [ ] TODOコメントが適切に管理されている

#### 外部ドキュメント整合性
**チェック項目**:
- [ ] README.mdと実装が一致している
- [ ] API仕様書が最新状態
- [ ] アクセプタンス基準が満たされている

## レビュー実行手順

### Phase 1: 基本情報収集

#### PR情報確認
1. **変更内容の把握**
   - 変更ファイル一覧と変更行数
   - 新規追加・修正・削除の分類
   - 対応するIssue番号とアクセプタンス基準

2. **機能の重要度判定**
   - Critical: 認証・決済・データ保存等
   - Important: 主要ビジネスロジック・UI/UX
   - Normal: 補助機能・設定・ログ等

### Phase 2: 段階的品質チェック

#### Step 1: 自動チェック結果確認
```bash
# 既存の自動チェック結果確認
- リンター・フォーマッター結果
- テスト実行結果・カバレッジ
- 型チェック結果
```

#### Step 2: コード品質レビュー
機能の重要度に応じてチェック深度を調整：
- **Critical**: 全観点で厳密にチェック
- **Important**: コード品質・設計を重点的に
- **Normal**: 基本的な品質チェックのみ

#### Step 3: セキュリティレビュー
Critical・Importantな機能では必須実行：
- 入力値検証の実装確認
- 認証・認可ロジックの確認
- 機密情報管理の確認

### Phase 3: 改善提案生成

#### 問題レベル分類
- **🚫 Critical（修正必須）**: セキュリティ脆弱性、重大なバグ
- **⚠️ Major（修正推奨）**: 設計問題、パフォーマンス問題
- **💡 Minor（改善案）**: 可読性向上、リファクタリング案
- **📚 Info（学習）**: ベストプラクティス紹介、参考情報

#### 改善提案フォーマット
```markdown
## 🚫 Critical: SQLインジェクション脆弱性

**ファイル**: `src/api/users.js:15`
**問題**: 入力値がそのままSQLクエリに渡されています

**現在のコード**:
```javascript
const query = `SELECT * FROM users WHERE email = '${email}'`;
```

**修正案**:
```javascript
const query = 'SELECT * FROM users WHERE email = ?';
const result = await database.query(query, [email]);
```

**理由**: SQLインジェクション攻撃を防ぐため、パラメータ化クエリを使用してください

**参考**: [OWASP SQL Injection Prevention](https://example.com)
```

### Phase 4: 学習ポイント抽出

#### 良いコード例の紹介
変更内容から優れた実装を見つけて評価：
```markdown
## ✅ Good Practice: 適切なエラーハンドリング

**ファイル**: `src/utils/validator.js:25`
**良い点**: 詳細なエラー情報と適切な例外タイプ

この実装により、デバッグが容易になり、エラーの原因特定が効率的です。
```

#### 改善の学習効果
```markdown
## 📚 学習ポイント: 関数型プログラミングの活用

今回の修正で、mapやfilterを使った関数型アプローチを採用されています。
これにより、コードの可読性と保守性が向上しています。

**メリット**:
- 副作用が少ない
- テストしやすい
- 再利用しやすい
```

## 最終判定・承認基準

### 承認可能な条件
- [ ] Critical問題が0件
- [ ] Major問題への対応方針が明確
- [ ] 全テストが通過している
- [ ] セキュリティ要件を満たしている
- [ ] ドキュメントが更新されている

### 修正要求の条件
- [ ] Critical問題が1件以上存在
- [ ] Major問題が複数あり品質に重大な影響
- [ ] テストが失敗している
- [ ] セキュリティ脆弱性が発見

### レビューコメント例

#### 承認時
```markdown
## ✅ レビュー完了：承認

### 概要
実装内容を確認しました。品質基準を満たしており、承認します。

### 評価ポイント
- ✅ 適切なテストカバレッジ（87.3%）
- ✅ セキュリティ要件遵守
- ✅ 可読性の高いコード
- ✅ ドキュメント更新済み

### Minor改善案（任意）
{改善提案があれば記載}

Great job! 🎉
```

#### 修正要求時
```markdown
## ⚠️ レビュー完了：修正要求

### 修正必須項目
{Critical・Major問題のリスト}

### 改善推奨項目
{Minor問題のリスト}

### 修正後の再レビュー
修正完了後、`/auto-review {PR番号}` で再レビューをお願いします。

ご質問があれば遠慮なくお聞かせください！
```

## エラー・例外処理

### レビュー実行失敗時
1. **PR情報取得失敗**: PR番号・ブランチ名の確認
2. **ファイル解析失敗**: 変更内容の手動確認
3. **自動チェック失敗**: 個別項目での手動レビュー

### 判定困難な場合
1. **複雑な設計問題**: 複数の改善案を提示
2. **トレードオフがある場合**: メリット・デメリットを明記
3. **プロジェクト固有の判断**: 判断材料を提供して決定を委ねる

## 継続的改善

### レビュー品質向上
- **月次**: レビュー指摘の傾向分析
- **四半期**: レビュー基準の見直し
- **随時**: 新しいベストプラクティスの取り込み

### 学習効果測定
- 同じ種類の問題の減少傾向
- コード品質指標の改善
- 開発速度と品質のバランス向上