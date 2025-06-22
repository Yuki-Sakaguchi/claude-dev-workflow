# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- バックアップ管理スクリプト `scripts/backup.sh`
  - タイムスタンプ付きバックアップ作成
  - バックアップ一覧表示機能
  - 30日以上古いバックアップ自動削除
  - ロールバック機能（指定バックアップからの復元）
  - バックアップファイル整合性チェック
  - macOS環境対応

### Changed
- README.md にバックアップ管理セクションを追加
- ファイル数統計を36個から37個に更新

## [1.1.0] - 2024-06-22

### Added
- 動的ファイル取得機能（GitHub API連携）
- curlパイプ実行対応（install.sh・update.sh）
- 自動エラーハンドリング機能
- 進捗表示機能

### Changed
- install.shを大幅改善（動的ファイル取得対応）
- update.shをリモート実行対応
- ファイル取得数を19個から36個に大幅増加

### Fixed
- ハードコーディングされたファイルリストの問題を解決
- curlパイプ実行時のエラーハンドリング改善

## [1.0.0] - 2024-06-20

### Added
- 初回リリース
- Claude Code開発ガイドライン一式
- 14個のカスタムスラッシュコマンド
- 要件定義・ワークフロー・テンプレート集
- 自動インストールスクリプト
- 自動更新スクリプト

### Features
- プロジェクト開始から実装・テストまでの完全自動化
- TDD + 自動テスト + ドキュメント更新の一気通貫
- プロレベルの自動コードレビュー
- 体系的な調査・分析機能
- PRレビュー対応自動化