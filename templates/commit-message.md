# コミットメッセージ規則

## 概要

Claude CodeがTDDサイクルおよび機能実装時に自動生成するコミットメッセージの規則です。
Conventional Commits形式を採用し、`templates/automation-setup.md`で設定した自動化ツールと連携してCHANGELOG生成を行います。

## 基本形式（Conventional Commits）

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### 必須要素
- **type**: 変更の種類
- **description**: 変更内容の簡潔な説明（50文字以内推奨）

### オプション要素
- **scope**: 変更の影響範囲
- **body**: 詳細な説明（必要な場合のみ）
- **footer**: 破壊的変更やIssue参照

## Type定義

### 主要Type（Claude Code頻用）

#### `test`
**用途**: テスト作成・更新（TDDのRed/Green段階）
```bash
test: add user login validation test
test: update authentication test cases
test: fix failing integration test
```

#### `feat`
**用途**: 新機能実装（TDDのGreen段階）
```bash
feat: implement user login functionality
feat: add password validation logic
feat: integrate third-party payment API
```

#### `refactor`
**用途**: リファクタリング（TDDのRefactor段階）
```bash
refactor: extract validation logic to utils
refactor: simplify authentication flow
refactor: optimize database query performance
```

#### `fix`
**用途**: バグ修正
```bash
fix: resolve login validation error
fix: handle null pointer exception in auth
fix: correct API response format
```

#### `docs`
**用途**: ドキュメント更新
```bash
docs: update API specification
docs: add setup instructions to README
docs: update user story acceptance criteria
```

#### `style`
**用途**: コードフォーマット・スタイル修正
```bash
style: apply prettier formatting
style: fix eslint warnings
style: update component naming convention
```

#### `chore`
**用途**: ビルド・設定・依存関係の変更
```bash
chore: update dependencies
chore: configure CI/CD pipeline
chore: add eslint configuration
```

### 追加Type

#### `perf`
**用途**: パフォーマンス改善
```bash
perf: optimize image loading performance
perf: implement lazy loading for components
```

#### `ci`
**用途**: CI/CD設定変更
```bash
ci: add automated testing workflow
ci: configure deployment pipeline
```

#### `build`
**用途**: ビルドシステム変更
```bash
build: update webpack configuration
build: add TypeScript compilation
```

#### `revert`
**用途**: 変更の取り消し
```bash
revert: "feat: add experimental feature"
```

## Scope定義（オプション）

### 機能別スコープ
```bash
feat(auth): implement login functionality
feat(payment): add credit card processing
feat(ui): create responsive navigation
test(auth): add login validation tests
```

### 技術別スコープ
```bash
feat(api): add user endpoints
feat(db): create user table schema
feat(frontend): implement login form
feat(backend): add authentication middleware
```

## TDDサイクルとコミット戦略

### Red → Green → Refactor パターン

#### 1. Red（失敗テスト作成）
```bash
test: add user login validation test (failing)
test: add password strength validation test
test: add API authentication test cases
```

#### 2. Green（最小実装）
```bash
feat: implement basic user login
feat: add password validation logic
feat: create authentication API endpoint
```

#### 3. Refactor（改善）
```bash
refactor: extract validation logic to utils
refactor: simplify authentication flow
refactor: optimize login response handling
```

### 完全なTDDサイクル例
```bash
# Issue #12: ユーザーログイン機能
1. test: add user login validation test (failing)
2. feat: implement basic user login functionality
3. test: add password strength validation test
4. feat: add password validation logic
5. refactor: extract validation logic to utils
6. test: add login API integration test
7. feat: implement login API endpoint
8. refactor: optimize authentication flow
9. docs: update API specification for login
```

## Claude Code自動生成ルール

### 機能実装時の自動コミット順序

**Phase 1: テスト実装**
```bash
# Claude Code自動生成例
test: add {機能名} {テスト種別} test
# 例: test: add user login validation test
```

**Phase 2: 最小実装**
```bash
feat: implement {機能概要}
# 例: feat: implement user login functionality
```

**Phase 3: リファクタリング**
```bash
refactor: {改善内容}
# 例: refactor: extract validation logic to utils
```

### 自動判断ロジック

**Claude Codeの判断基準**:
```javascript
// 自動type判定の例
function determineCommitType(changes) {
  if (changes.includes('test') && changes.isNewTest) return 'test';
  if (changes.includes('fix') && changes.isBugFix) return 'fix';
  if (changes.includes('refactor') && !changes.hasNewFeatures) return 'refactor';
  if (changes.hasNewFeatures) return 'feat';
  if (changes.isDocumentationOnly) return 'docs';
  return 'chore';
}
```

## コミットメッセージ例

### ✅ 良い例

```bash
# 新機能実装
feat: add user registration with email validation
feat(auth): implement JWT token refresh
feat(payment): integrate Stripe payment gateway

# バグ修正
fix: resolve null pointer in authentication
fix(api): handle malformed request payload
fix: correct responsive layout on mobile

# テスト追加
test: add user login validation test
test(payment): add integration test for Stripe
test: add edge cases for password validation

# リファクタリング
refactor: extract database logic to repository
refactor(auth): simplify token validation flow
refactor: optimize API response formatting

# ドキュメント更新
docs: update API documentation for auth endpoints
docs: add troubleshooting guide to README
docs: update user story acceptance criteria

# 設定・環境
chore: update dependencies to latest versions
ci: add automated test coverage reporting
build: configure TypeScript strict mode
```

### ❌ 悪い例

```bash
# 曖昧すぎる
fix: bug fix
feat: new feature
update: some changes

# 長すぎる（50文字超過）
feat: implement a very comprehensive user authentication system with multiple providers

# type不適切
feat: fix authentication bug  # → fix: resolve authentication issue
test: add new login feature  # → feat: implement login functionality

# 不統一な形式
Fix authentication problem     # → fix: resolve authentication issue
ADD: new user registration     # → feat: add user registration
Updated documentation         # → docs: update API documentation
```

## 特殊ケース

### 破壊的変更（Breaking Changes）
```bash
feat!: change API response format
feat(auth)!: remove deprecated login endpoint

# またはfooterで
feat: update user authentication

BREAKING CHANGE: API response format changed from snake_case to camelCase
```

### Issue参照
```bash
feat: add user dashboard (close #123)
fix: resolve login timeout issue (fix #456)
docs: update setup guide (ref #789)
```

### 複数の変更
```bash
# 小さな関連変更は一つのコミットでOK
feat: add user login with validation and error handling

# 大きな変更は分割
feat: add user login functionality
test: add comprehensive login test cases
docs: update authentication documentation
```


## Claude Code実行例

### 理想的な自動コミット実行

**ユーザー**: "issue #12 のユーザーログイン機能を実装して"

**Claude Code自動コミット順序**:
```bash
# TDDサイクル自動実行
1. test: add user login validation test (failing)
2. feat: implement basic user login functionality  
3. test: add password strength validation test
4. feat: add password validation logic
5. refactor: extract validation logic to utils
6. test: add login API integration test
7. feat: implement login API endpoint
8. refactor: optimize authentication flow
9. docs: update API specification for login endpoint

# 最後にPR作成
```


## 品質チェック

### コミット前自動確認（Claude Code）
- [ ] type が適切に選択されている
- [ ] description が50文字以内
- [ ] 変更内容とメッセージが一致している
- [ ] Conventional Commits形式に準拠
- [ ] Issue番号が必要な場合は含まれている

## 参考資料
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Angular Commit Message Guidelines](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#commit)