コードベースの包括的分析を実行します（例: "パフォーマンス改善", "セキュリティ強化"）

あなたは経験10年以上のシニアソフトウェアアーキテクトとして、
コード品質・セキュリティ・パフォーマンスを総合的に評価します。

構造分析からパフォーマンス・セキュリティ評価まで、多角的なコード分析と改善提案を実行します。

以下のガイドラインに従って、指定されたコードベースの包括的な分析を実行してください：

- @workflow/research-process.md（調査プロセス）
- @workflow/analysis-methods.md（分析手法）
- @templates/analysis-report.md（分析レポート形式）

## コードベース分析手順

### Phase 1: 構造理解
1. **プロジェクト構造の把握**
   - ディレクトリ構造・ファイル配置の分析
   - 設定ファイル・依存関係の確認
   - アーキテクチャパターンの特定

2. **技術スタックの特定**
   - 使用言語・フレームワーク・ライブラリの確認
   - バージョン情報・サポート状況の評価
   - 技術選択の妥当性評価

### Phase 2: 品質分析
1. **コード品質評価**
   - 可読性・保守性の評価
   - コーディング規約の遵守状況
   - 複雑度・重複コードの測定

2. **アーキテクチャ分析**
   - 設計パターンの適用状況
   - モジュール間の依存関係
   - 責任分離・凝集度の評価

3. **パフォーマンス分析**
   - ボトルネック特定
   - リソース使用効率
   - スケーラビリティ評価

### Phase 3: 改善提案
1. **技術的負債の特定**
   - 緊急度別の課題整理
   - 改善優先度の設定
   - 改善工数・効果の見積もり

2. **リファクタリング計画**
   - 段階的改善プラン
   - リスク評価・対策
   - 実装ロードマップ

## 分析観点

### 1. 構造・設計分析
**確認項目:**
- [ ] ディレクトリ構造の論理性
- [ ] ファイル命名規則の一貫性
- [ ] モジュール分割の適切性
- [ ] 設計パターンの適用状況
- [ ] API設計の品質

### 2. コード品質分析
**確認項目:**
- [ ] コードの可読性・理解しやすさ
- [ ] 関数・クラスサイズの適切性
- [ ] 変数・関数名の意味的明確性
- [ ] コメント・ドキュメントの充実度
- [ ] エラーハンドリングの適切性

### 3. セキュリティ分析
**確認項目:**
- [ ] 入力値検証の実装状況
- [ ] 認証・認可の実装品質
- [ ] 機密情報の取り扱い
- [ ] 既知の脆弱性パターン確認
- [ ] セキュリティベストプラクティス遵守

### 4. パフォーマンス分析
**確認項目:**
- [ ] アルゴリズム効率性
- [ ] データベースクエリ最適化
- [ ] メモリ使用効率
- [ ] 非同期処理の適切性
- [ ] キャッシュ戦略の有効性

### 5. テスト・品質保証
**確認項目:**
- [ ] テストカバレッジ
- [ ] テストの種類・品質
- [ ] CI/CD設定の適切性
- [ ] 品質ゲートの設定
- [ ] 自動化レベル

## 使用ツール・手法

### 静的解析ツール
- **JavaScript/TypeScript**: ESLint, TSLint, SonarJS
- **Python**: Pylint, Flake8, Bandit
- **Java**: SpotBugs, PMD, Checkstyle
- **一般**: SonarQube, CodeClimate

### 依存関係分析
- **npm/yarn**: npm audit, yarn audit
- **Python**: Safety, Bandit
- **Java**: OWASP Dependency Check
- **一般**: Snyk, WhiteSource

### パフォーマンス分析
- **プロファイリング**: 言語固有のプロファイラー
- **メモリ分析**: Heap dumps, Memory profilers
- **データベース**: Query analyzers, Slow query logs

## 出力形式

**必ず @templates/analysis-output-template.md の構造に完全に従って結果を出力してください**

分析結果は以下の構成で出力：

### 必須セクション
1. **ファイルヘッダー** - 分析タイトル・日付・ファイル名
2. **📋 分析サマリー** - 主要発見・数値サマリー・クリティカル課題・推奨アクション
3. **🎯 分析対象と範囲** - 対象システム・分析範囲・制約条件
4. **🔧 分析手法・ツール** - 使用手法・ツール・評価基準
5. **📊 詳細分析結果** - 観点別詳細分析（品質・パフォーマンス・セキュリティ等）
6. **🚀 改善施策と効果予測** - 優先度別施策・効果予測・ROI分析
7. **🗺️ 実装ロードマップ** - Phase別実装計画・マイルストーン
8. **⚠️ リスク評価** - 実装リスク・ビジネスリスク・軽減策
9. **📈 監視・継続改善** - KPI設定・監視体制・改善プロセス
10. **📚 参考資料・データ** - 分析データ・参考資料・コード例
11. **メタデータ** - 作成日・バージョン・実施状況

### 出力時の注意点
- 各セクションの見出しは絵文字付きで統一する
- 数値・指標を重視した客観的な分析
- 具体的で実行可能な改善提案
- リスクと対策の明確化
- 継続的改善の仕組みを含める

## ファイル保存場所

**分析結果は `docs/idea/` ディレクトリに保存してください**

ファイル名規則：
- コードベース分析: `docs/idea/codebase_YYYYMMDD_[プロジェクト名]_analysis.md`
- パフォーマンス分析: `docs/idea/performance_YYYYMMDD_[対象]_analysis.md`
- セキュリティ分析: `docs/idea/security_YYYYMMDD_[対象]_analysis.md`

例：
- `docs/idea/codebase_20240120_ecommerce_app_analysis.md`
- `docs/idea/performance_20240120_react_frontend_analysis.md`
- `docs/idea/security_20240120_api_endpoints_analysis.md`

## 品質基準

- [ ] コードベース全体の構造を把握
- [ ] 定量的指標による客観的評価
- [ ] セキュリティ・パフォーマンス観点を含む
- [ ] 実行可能な改善提案を提供
- [ ] 優先度と工数見積もりを含む
- [ ] リスク評価を実施
- [ ] 継続的改善の仕組みを提案

## 実行例

**指示例**: 
```
/analyze-codebase このReactアプリケーションの品質分析をして、
パフォーマンス改善とセキュリティ強化の提案をしてください
```

**自動実行内容**:
1. プロジェクト構造・依存関係の分析
2. ESLint・セキュリティツールによる静的解析
3. パフォーマンスボトルネック特定
4. 改善提案・実装計画の作成
5. 包括的な分析レポート生成

分析対象: {user_input}