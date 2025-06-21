# claude-code-template

## 要件定義
```bash
claude code "requirements/interview-template.mdの手順で、事前に記入したtemplates/preparation-sheet.mdを元にヒアリングしてください"
```

## 実装
```bash
# 具体的な指示例
claude code "workflow/tdd-process.mdに従ってテストを作成し、
templates/commit-message.mdの規則でコミットしてください"
```

```bash
~/.claude/
├── CLAUDE.md                    # メインインデックス（必読）
├── requirements/
│   ├── interview-template.md    # ヒアリングテンプレート
│   └── document-structure.md    # ドキュメント構造定義
├── workflow/
│   ├── development-flow.md      # 開発フロー全体
│   ├── git-workflow.md         # ブランチ戦略・コミット規則
│   └── tdd-process.md          # TDD具体的手順
├── templates/
│   ├── issue-template.md       # Issue作成テンプレート
│   ├── pr-template.md          # PR作成テンプレート
│   └── commit-message.md       # コミットメッセージ規則
└── examples/
    ├── sample-requirements.md   # 要件定義例
    └── sample-user-story.md    # ユーザーストーリー例
```
