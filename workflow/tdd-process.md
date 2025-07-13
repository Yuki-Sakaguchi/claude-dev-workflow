# TDD・テスト戦略

## 基本方針

- YOU MUST: **開発環境にテスト用の環境が構築されていない場合はテストは実装しないでください。環境を勝手に作らないでください。**
- YOU MUST: **開発環境にテスト用の環境が構築されている場合は必ずテストを実装してください**
- YOU MUST: **テストを実装する場合はt-wadaさんに習ってTDDで実装をしてください**
- YOU MUST: **実装するのは単体テストと統合テストのみです。E2Eテストは作成しないでください。**

## 個人開発に最適化した3層テスト戦略

1. **単体テスト（TDD）**: 全機能で必須実行
2. **統合テスト**: API・DB連携部分のみ
3. **E2Eテスト**: 主要なユーザーシナリオのみ

## TDDサイクル（自動実行）

### Red → Green → Refactor

**Claude Codeの実行順序：**

1. **Red**: 失敗する単体テストを作成
2. **Green**: 最小限の実装でテスト通過
3. **Refactor**: コード品質向上（テスト結果は変更しない）

### 各段階のコミット例

```bash
# Red: 失敗テスト作成
git commit -m "test: add user login validation test (failing)"

# Green: 最小実装
git commit -m "feat: implement basic user login"

# Refactor: リファクタリング
git commit -m "refactor: extract validation logic"
```
