# 開発フロー（Claude Code自動実行用）

## 基本原則

**機能実装と同時にドキュメント更新を自動実行**

Claude Codeは以下を同期して実行する：
1. 機能実装
2. テスト作成
3. 関連ドキュメントの自動更新
4. 自動生成可能な仕様書の更新

## 全体開発フロー

### Phase 1: 要件定義
1. ヒアリングテンプレートに基づく要件整理
2. 要件定義書・ユーザーストーリー・アクセプタンス基準の作成
3. GitHub Issue作成とPhase分け

### Phase 2: 機能実装（自動実行）
**ユーザー指示例**: "issue #12 のユーザーログイン機能を実装して"

**Claude Code自動実行フロー**:
1. **ブランチ作成**: `feature/issue-12-user-login`
2. **TDDサイクル実行**: テスト → 実装 → リファクタリング
3. **ドキュメント自動更新** ⭐️ここが重要
4. **PR作成**: 全テスト通過確認後

## ドキュメント自動更新（実装と同時）

### 必須更新項目（毎回）

#### README.md更新
**トリガー**: 新機能・API追加時

**自動更新内容**:
- 機能一覧への追加
- 使用方法の更新
- 環境変数の追加（必要に応じて）

**例**:
```markdown
## 機能一覧
- [x] ユーザー登録
- [x] ユーザーログイン ← 自動追加
- [ ] パスワードリセット
```

#### アクセプタンス基準の完了チェック
**トリガー**: 機能実装完了時

**自動更新**:
```markdown
## issue #12: ユーザーログイン機能
- [x] ログインフォームの表示 ← 自動チェック
- [x] バリデーション処理
- [x] 認証API連携
```

### API関連自動生成（該当時のみ）

#### OpenAPI仕様書
**対象**: REST API実装時

**自動生成ツール**: コメント/アノテーションから生成

**実行タイミング**: API実装後

**出力場所**: `docs/api-spec.md` または `docs/openapi.yml`

#### 型定義ドキュメント
**対象**: TypeScript使用時

**自動生成**: TSDocコメントから生成

**例**:
```typescript
/**
 * ユーザーログイン情報
 * @param email - メールアドレス
 * @param password - パスワード（8文字以上）
 */
interface LoginRequest {
  email: string;
  password: string;
}
```

### 変更履歴自動更新

#### CHANGELOG.md
**トリガー**: PR作成時

**自動追記内容**:
```markdown
## [Unreleased]
### Added
- ユーザーログイン機能 (#12) ← 自動追加
```

**ルール**: Conventional Commits形式のコミットメッセージから自動生成

## Claude Code実行例

### 理想的な自動実行

**ユーザー**: "issue #15 の決済API機能を実装して"

**Claude Code応答**:
```
issue #15 の決済API機能の実装を開始します。

実行内容：
1. ブランチ作成: feature/issue-15-payment-api
2. TDDサイクルで実装
3. 以下のドキュメントを同時更新:
   - README.md: 機能一覧に決済API追加
   - docs/api-spec.md: 決済エンドポイント仕様追加
   - docs/03_アクセプタンス基準.md: 完了チェック更新
   - CHANGELOG.md: 変更履歴追記
4. PR作成

実装を開始します。
```

### 実装中の自動ドキュメント更新

**実装ステップ1**: 決済API作成
```typescript
/**
 * 決済処理API
 * @route POST /api/payment
 * @param amount - 金額（正の整数）
 * @param paymentMethod - 支払い方法
 * @returns 決済結果
 */
```

**同時実行**: API仕様書自動更新

**実装ステップ2**: テスト作成完了

**同時実行**: アクセプタンス基準チェック更新

## ドキュメント更新失敗時の対応

### 自動生成失敗時
1. **エラー内容分析**: 何が原因で失敗したか特定
2. **手動更新**: 最小限の手動更新で対応
3. **次回改善**: 自動化設定の見直し提案

### 矛盾検出時
1. **既存ドキュメントとの整合性チェック**
2. **ユーザーに確認**: "既存の機能説明と矛盾があります。更新しますか？"
3. **適切な更新**: ユーザー確認後に更新実行

## 品質チェックポイント

### PR作成前の自動確認
- [ ] 全テスト通過
- [ ] README.md更新済み
- [ ] アクセプタンス基準チェック済み
- [ ] API仕様書生成済み（該当する場合）
- [ ] CHANGELOG.md更新済み
- [ ] ドキュメント間の整合性確認

### 継続的改善
- **週次**: ドキュメントの自動生成状況確認
- **月次**: 手動更新が必要だった項目の自動化検討
- **随時**: 新しい自動化ツールの導入検討

## 自動化ツール設定

### 推奨ツール
- **API仕様**: Swagger/OpenAPI Generator
- **型定義**: TypeDoc
- **変更履歴**: conventional-changelog
- **README更新**: カスタムスクリプト（Claude Code実行）

### 設定ファイル例
```json
{
  "scripts": {
    "docs:api": "swagger-jsdoc -d swaggerDef.js src/**/*.js -o docs/api-spec.yml",
    "docs:types": "typedoc src --out docs/types",
    "docs:changelog": "conventional-changelog -p angular -i CHANGELOG.md -s"
  }
}
```