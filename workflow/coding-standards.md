# コーディング規約やベストプラクティス

## 命名規則

Next.js + React + TypeScript の命名規則整理

### 📁 ディレクトリ命名規則

#### Next.js App Router（公式規則）

```
app/
├── page.tsx              # 固定名（公式）
├── layout.tsx            # 固定名（公式）
├── loading.tsx           # 固定名（公式）
├── error.tsx             # 固定名（公式）
├── not-found.tsx         # 固定名（公式）
├── route.tsx             # 固定名（公式）
├── template.tsx          # 固定名（公式）
├── [id]/                 # 動的ルート
├── (group)/              # ルートグループ
└── user-profile/         # kebab-case推奨
```

#### 一般的なディレクトリ構造

```
src/
├── app/                  # Next.js App Router
├── components/           # kebab-case
│   ├── ui/              # 共通UI
│   ├── layout/          # レイアウト
│   └── feature-name/    # 機能別
├── lib/                 # ユーティリティ
├── hooks/               # カスタムフック
├── types/               # 型定義
├── utils/               # ヘルパー関数
└── actions/             # Server Actions
```

#### 📄 ファイル命名規則

1. Reactコンポーネント

```
// PascalCase.tsx
UserProfile.tsx          # コンポーネントファイル
SubmitButton.tsx         # UIコンポーネント
AuthProvider.tsx         # Providerコンポーネント
```

2. 通常のTypeScriptファイル

```
// camelCase.ts
userActions.ts           # アクション
authHelpers.ts           # ヘルパー関数
databaseClient.ts        # クライアント
```

3. カスタムフック

```
// useXxxxx.ts
useAuth.ts               # 認証フック
useLocalStorage.ts       # ローカルストレージフック
useApiCall.ts           # API呼び出しフック
```

4. 型定義ファイル

```
// camelCase.ts or types.ts
userTypes.ts             # ユーザー関連型
apiTypes.ts              # API関連型
index.ts                 # 型のエクスポート
```

#### 🏗️ 内部の命名規則

TypeScript

```typescript
// インターフェース - PascalCase
interface UserProps {}
interface ApiResponse {}

// 型 - PascalCase
type AuthState = 'loading' | 'authenticated' | 'unauthenticated';
type ButtonVariant = 'primary' | 'secondary';

// 変数・関数 - camelCase  
const userName = 'john';
const handleSubmit = () => {};
```

React

```typescript
// コンポーネント - PascalCase
const UserProfile = () => {};
const SubmitButton = () => {};

// Props - camelCase
interface ButtonProps {
  onClick: () => void;
  isLoading: boolean;
  variant: 'primary' | 'secondary';
}
```

## 型定義ドキュメント
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
- [Supabase](https://supabase.com/) - BaaS（DB・Auth・Storage統合）
- [Supabase CLI](https://supabase.com/docs/guides/cli) - ローカル開発環境