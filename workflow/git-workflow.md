# Git ワークフロー（Claude Code自動実行用）

## 基本原則

**Claude Codeは以下を自動実行する：**

1. issue番号を確認してブランチ作成
2. アクセプタンス基準の確認
3. TDDサイクルでの実装
4. 適切なコミットメッセージでの細かいコミット
5. PR作成

## 自動実行フロー

### 新機能実装指示を受けた時

**ユーザー指示例：** "issue #12 のユーザーログイン機能を実装してください"

**Claude Code自動実行手順：**

1. GitHub issue #12 の内容とアクセプタンス基準を確認
2. develop から feature/issue-12-user-login ブランチを作成
3. docs/03_アクセプタンス基準.md の該当部分を確認
4. TDDサイクル開始：
   - テスト作成 → コミット
   - 最小実装 → コミット  
   - リファクタリング → コミット
5. 実装完了後、PR作成

## ブランチ命名規則（自動適用）

**パターン：** `feature/issue-{issue番号}-{機能名を英語で簡潔に}`

**例：**
- issue #12 "ユーザーログイン機能" → `feature/issue-12-user-login`
- issue #25 "決済システム連携" → `feature/issue-25-payment-integration`
- issue #8 "API認証機能" → `feature/issue-8-api-auth`

## TDDサイクル（自動実行）

### Red → Green → Refactor を各ステップでコミット

**テスト作成時：**
```
git commit -m "test: add user login validation test"
```

**最小実装時：**
```
git commit -m "feat: implement basic user login"
```

**リファクタリング時：**
```
git commit -m "refactor: extract login validation logic"
```

## PR作成（自動実行）

### PRタイトル形式
```
feat: {機能概要} (close #{issue番号})
```

### PR説明テンプレート（自動記入）

```
## 概要
issue #{番号} の対応

## 変更内容
- [ ] テスト実装
- [ ] 機能実装
- [ ] ドキュメント更新

## アクセプタンス基準
- [ ] {基準1}
- [ ] {基準2}

## テスト結果
- [ ] 全テスト通過
- [ ] 新規テスト追加
```

## Claude Codeへの期待動作

### 理想的な会話例

**ユーザー：** "issue #8 のAPI認証機能を実装して"

**Claude Code応答例：**

"issue #8 のAPI認証機能の実装を開始します。

1. GitHub issue #8 を確認しました
2. feature/issue-8-api-auth ブランチを作成します
3. アクセプタンス基準に基づいてTDDで実装します
4. 完了後、PR作成します

実装を開始しますね。"

*（その後、自動的に上記フローを実行）*

## 重要な自動判断ポイント

- **ブランチ名：** issue内容から適切な英語名を生成
- **テスト範囲：** アクセプタンス基準から必要なテストを判断
- **コミット粒度：** TDDの各ステップで適切にコミット
- **PR説明：** issue内容を元に自動生成

## エラー時の自動対応

- **ブランチ作成失敗** → develop の最新状態を確認して再試行
- **テスト失敗** → 原因分析して修正
- **コンフリクト発生** → develop をマージして解決