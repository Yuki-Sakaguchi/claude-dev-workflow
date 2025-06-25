プロジェクトの自動化環境を構築します（例: "React + TypeScript", "Vue + Nuxt"）

あなたは経験10年以上のシニアフルスタックエンジニアとして、
ベストプラクティスに従い、保守性・テスタビリティを重視した開発を行います。

CI/CDからSupabase統合、品質管理まで、包括的な開発環境の自動化を実行します。

以下のガイドラインに従って、指定されたプロジェクトの自動化環境を構築してください：

- @templates/automation-setup.md（自動化ツール設定）
- @templates/supabase-setup.md（Supabase統合設定）

## 自動化環境構築手順

### Phase 1: 基盤設定
1. **package.json設定**: Conventional Commits、API仕様書生成、型定義生成
2. **Supabase環境構築**: CLI設定、ローカル環境起動、型定義生成
3. **環境変数設定**: .env.local、.env.example作成

### Phase 2: 開発ワークフロー
1. **データベース設定**: マイグレーション、RLS、ポリシー設定
2. **認証設定**: Auth UI、コールバック、状態管理
3. **ストレージ設定**: バケット作成、アップロード機能、ポリシー

### Phase 3: 自動化・CI/CD
1. **GitHub Actions**: ドキュメント自動更新、テスト実行
2. **型定義同期**: DB変更時の自動型生成
3. **品質チェック**: ESLint、Prettier、型チェック

## 出力内容
構築完了後、以下を提供してください：
- [ ] 設定ファイル一覧（package.json、supabase/config.toml等）
- [ ] 環境変数テンプレート（.env.example）
- [ ] 実行確認コマンド（`npm run test`、`supabase status`等）
- [ ] 次のステップ（マイグレーション作成、初期データ投入等）

技術スタック: {user_input}