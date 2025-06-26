PRのレビューコメントを取得・分析し修正対応します（例: "123", "123 --priority critical"）

あなたは経験10年以上のシニアソフトウェアエンジニアとして、
レビューコメント分析から優先度別修正、品質確認まで、効率的なPRレビュー対応プロセスを実行します。

GitHub PRのレビューコメントを自動で取得・分析し、効率的に修正対応を行うカスタムコマンドです。

## 🚀 使用方法

### 基本コマンド
```
/pr-review <PR番号>
```

### オプション
```
/pr-review <PR番号> --priority <critical|important|minor>
/pr-review <PR番号> --reply-only <true|false>
/pr-review <PR番号> --force <true|false>
```

## 🔧 実行フロー

1. **レビュー分析** → 重要度別分類（🔴Critical/🟡Important/🟢Minor）
2. **修正実装** → 優先度順に修正・テスト・品質チェック
3. **インラインリプライ** → 未対応コメントのみ自動リプライ（重複防止）
4. **完了処理** → コミット・プッシュ・レポート生成

## 🔧 技術仕様

#### レビュー・インラインコメント取得（重複防止付き）
```bash
# 全インラインコメント取得
gh pr view $PR_NUMBER --comments --json reviews,comments
ALL_COMMENTS=$(gh api repos/$OWNER/$REPO/pulls/$PR_NUMBER/comments --jq '.[] | {id, body, path, line, user: .user.login, in_reply_to}')

# Claude Codeの既存リプライを特定
CLAUDE_REPLIES=$(echo "$ALL_COMMENTS" | jq -r '.[] | select(.body | contains("🤖 Claude Codeからの返信")) | .in_reply_to')

# 未対応コメントのみ抽出（Claude Codeがまだリプライしていないもの）
UNHANDLED_COMMENTS=$(echo "$ALL_COMMENTS" | jq -r --argjson replied_to "[$CLAUDE_REPLIES]" '.[] | select(.in_reply_to == null and (.id | tostring | IN($replied_to[]) | not)) | .id')
```

#### 品質チェック
```bash
npm run lint
npm run typecheck  
npm run test
npm run test:coverage
```

#### インラインコメントリプライ（重複防止）
```bash
# 未対応コメントのみにリプライ投稿
echo "対応予定のコメント: $(echo "$UNHANDLED_COMMENTS" | wc -l)件"
echo "対応予定コメントID: $UNHANDLED_COMMENTS"

# 確認後、未対応コメントのみリプライ
for comment_id in $UNHANDLED_COMMENTS; do
  echo "コメントID: $comment_id にリプライ投稿中..."
  gh api repos/$OWNER/$REPO/pulls/$PR_NUMBER/comments \
    --method POST \
    --field body="> [!NOTE]
> 🤖 Claude Codeからの返信 🤖

修正内容: [具体的な修正内容]
理由: [技術的な根拠と背景]
効果: [修正による改善効果]" \
    --field in_reply_to=$comment_id
done

echo "リプライ投稿完了: $(echo "$UNHANDLED_COMMENTS" | wc -l)件"
```

#### コミット・プッシュ
```bash
git add .
git commit -m "fix: レビュー指摘事項の修正

- Critical issues: {count}件修正
- Important issues: {count}件修正  
- Minor issues: {count}件修正
- Tests: {count}件追加/更新
- インラインコメント対応: {count}件

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

### `--reply-only`
コメントリプライのみを実行（修正は行わない）
- `true`: インラインコメントへのリプライのみ
- `false`: 修正とリプライの両方を実行（デフォルト）

### `--force`
重複防止を無視して全コメントに対応
- `true`: 既にリプライ済みでも再度対応
- `false`: 未対応コメントのみ対応（デフォルト）

## 🎯 使用例

### 基本的な使用例
```
/pr-review 123                                    # 全コメント対応
/pr-review 123 --priority critical               # Critical のみ
/pr-review 123 --reply-only true                 # リプライのみ
/pr-review 123 --force true                      # 重複防止を無視
```

## 📋 出力レポート例

```markdown
# PRレビュー対応完了レポート

## 📊 対応サマリー
- **PR番号**: #123
- **レビューコメント総数**: 15件
- **インラインコメント**: 8件
- **既存Claude Codeリプライ**: 3件（スキップ）
- **今回対応コメント**: 5件
- **修正完了**: 15件
- **リプライ投稿**: 5件
- **テスト追加**: 3件
- **実行時間**: 12分30秒

## 🔍 重要度別対応状況
### 🔴 Critical Issues (5件)
- ✅ auth.ts:45 - SQLインジェクション脆弱性修正
- ✅ api.ts:120 - 認証バイパス修正
- ✅ utils.ts:78 - XSS脆弱性修正
- ✅ db.ts:200 - データ漏洩リスク修正
- ✅ validation.ts:55 - 入力検証強化

### 🟡 Important Issues (7件) / 🟢 Minor Issues (3件)
（詳細は実行時に表示）

## 💬 インラインコメント対応状況
- **今回対応**: 5件のリプライ投稿完了
- **既存対応済み**: 3件をスキップ（重複防止）

## 🚀 次のアクション
- [x] 修正内容をコミット・プッシュ完了
- [x] 未対応インラインコメントへのリプライ投稿完了（5件）
- [x] 重複リプライ防止による効率化
- [ ] レビュアーへの完了通知（手動）
- [ ] CI/CDパイプラインの確認（自動）
```


## 🆘 トラブルシューティング

### エラー対応

**よくあるエラー**:
- 認証エラー → `gh auth login`
- PR取得失敗 → PR番号・権限確認
- リプライ失敗 → API制限・コメントID確認
- 重複防止失敗 → `--force true`で強制実行

## 📚 関連ドキュメント

- [Git運用ルール](@workflow/git-workflow.md)  
- [品質管理ガイド](@workflow/tdd-process.md)

---

**効率的なPRレビュー対応で開発速度と品質を両立させましょう！**