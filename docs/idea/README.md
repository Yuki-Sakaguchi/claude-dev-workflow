# 調査・分析結果アーカイブ

このディレクトリには、Claude Codeによる各種調査・分析結果を保存します。

## ディレクトリ構造

```
docs/idea/
├── README.md                    # このファイル
├── research_YYYYMMDD_*.md      # 一般調査結果
├── tech_YYYYMMDD_*.md          # 技術調査・比較結果
├── competitor_YYYYMMDD_*.md    # 競合分析結果
├── codebase_YYYYMMDD_*.md      # コードベース分析結果
├── performance_YYYYMMDD_*.md   # パフォーマンス分析結果
└── market_YYYYMMDD_*.md        # 市場分析結果
```

## ファイル命名規則

### 一般調査
- `research_YYYYMMDD_[調査テーマ].md`
- 例: `research_20240120_pwa_feasibility.md`

### 技術調査
- `tech_YYYYMMDD_[技術A]_vs_[技術B].md` (比較)
- `tech_YYYYMMDD_[技術名]_evaluation.md` (評価)
- `tool_YYYYMMDD_[分野]_research.md` (ツール調査)
- 例: `tech_20240120_nextjs_vs_nuxtjs.md`

### 競合分析
- `competitor_YYYYMMDD_[分野]_analysis.md`
- `market_YYYYMMDD_[業界]_analysis.md`
- `positioning_YYYYMMDD_[カテゴリ]_analysis.md`
- 例: `competitor_20240120_note_apps_analysis.md`

### コードベース分析
- `codebase_YYYYMMDD_[プロジェクト名]_analysis.md`
- `performance_YYYYMMDD_[対象]_analysis.md`
- `security_YYYYMMDD_[対象]_analysis.md`
- 例: `codebase_20240120_ecommerce_app_analysis.md`

## 使用方法

### 調査実行
```bash
# 一般調査
/research [調査内容]

# 技術調査
/tech-research [技術比較内容]

# 競合分析
/competitor-analysis [競合分析対象]

# コードベース分析
/analyze-codebase [分析対象]
```

### 結果の活用
1. **意思決定支援**: 技術選定・戦略決定の根拠として活用
2. **ナレッジ蓄積**: チーム・個人の知識資産として蓄積
3. **継続監視**: 定期的な更新・見直しの基準として活用
4. **学習促進**: 分析手法・調査技術の向上に活用

## 品質管理

### レビュー・更新
- **月次レビュー**: 重要な調査結果の見直し・更新
- **四半期見直し**: 市場動向・技術トレンドの変化確認
- **年次アーカイブ**: 古い調査結果の整理・アーカイブ

### 品質基準
- [ ] 信頼できる情報源の使用
- [ ] 複数観点での分析実施
- [ ] 実行可能な提案の提供
- [ ] 適切なリスク評価の実施
- [ ] 更新・継続監視の計画

## 参考リンク

- [調査プロセス](../workflow/research-process.md)
- [分析手法](../workflow/analysis-methods.md)
- [調査結果テンプレート](../templates/research-template.md)
- [分析レポートテンプレート](../templates/analysis-report.md)