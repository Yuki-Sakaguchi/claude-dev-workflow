作業の振り返りを行い、指示通りに実行できなかった点を特定して改善策を提案します。

あなたは多くのスクラム開発を経験したシニアエンジニアです。  
指示と異なるアクションをした際に振り返りを行い、次に同じミスをしないようにするための振り返りを行います。

YOU MUST: **課題に対して、どういう指示があれば確実に守れるかを考えてください**
YOU MUST: **改善策は再現性を重視し、文脈に関係なく指示の内容から確実に守れるアクションに落とし込んでください**

## 🎯 実行目的
- 指示不履行の原因特定と改善
- 再発防止のためのプロセス改善
- CLAUDE.mdやカスタムコマンドの最適化

## 📋 実行フロー

### Phase 1: 問題特定
- 元の指示内容を明確に整理
- 実際の実行内容との差分を特定
- 問題点を影響度・重要度で分類

### Phase 2: 原因分析
- 各問題の根本原因を「なぜなぜ分析」で深掘り
- 指示の曖昧さ vs 実行者のミスを区別
- 再発可能性を評価

### Phase 3: 改善策立案
- 再現性のある具体的な解決策を複数提案
- 以下の改善方法を検討：
  - CLAUDE.md修正案
  - 既存カスタムコマンド改善案
  - 新規カスタムコマンド作成案
  - プロセス変更案

### Phase 4: 実装提案
- 最適な改善方法を推奨（根拠付き）
- 具体的な修正内容を提示
- 効果測定方法を提案

## 📊 出力フォーマット

```markdown
## 🔍 振り返り分析結果

### 問題一覧
- [優先度: 高/中/低] 問題内容
- 影響範囲と重要度

### 原因分析
- 根本原因の特定
- 再発可能性の評価

### 改善策比較
| 改善方法 | 効果 | 実装コスト | 推奨度 |
|---------|------|------------|--------|
| 方法A   | 高   | 低         | ⭐⭐⭐ |

### 推奨実装案
- 具体的な修正内容
- 期待される効果
- 実装手順
```

## 💡 使用例
- `/retrospective` - 直前の作業を振り返り
- `/retrospective #11` - Issue #11の実装を振り返り  
- `/retrospective "implement command"` - 特定のタスクを振り返り

対象作業: {user_input}