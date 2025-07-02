# コーディング規約やベストプラクティス

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