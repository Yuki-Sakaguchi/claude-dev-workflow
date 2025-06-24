# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- バージョン管理機能（#4）
  - `.claude-version` ファイルによるセマンティックバージョニング対応
  - `scripts/version.sh` - バージョン情報表示とチェック機能
  - `scripts/check-compatibility.sh` - 互換性チェックとマイグレーション支援
  - バージョン比較機能（セマンティックバージョニング準拠）
  - バージョン履歴表示機能
  - 破壊的変更の事前通知機能
  - マイグレーション要否判定機能
  - 自動修復機能
- テスト機能
  - `scripts/test-version.sh` - バージョン管理機能のテストスイート
- バックアップ管理スクリプト `scripts/backup.sh`
  - タイムスタンプ付きバックアップ作成
  - バックアップ一覧表示機能
  - 30日以上古いバックアップ自動削除
  - ロールバック機能（指定バックアップからの復元）
  - バックアップファイル整合性チェック
  - macOS環境対応

### Changed
- `scripts/install.sh` にバージョン管理機能を統合
- `scripts/update.sh` にバージョン比較とマイグレーション機能を追加
- `.claude-version` ファイル形式の拡張（互換性情報、機能リスト、破壊的変更記録）
- README.md にバックアップ管理セクションを追加
- ファイル数統計を36個から40個に更新

### Enhanced
- バージョンアップ時の自動互換性チェック
- インストール・更新プロセスでのバージョン整合性確認
- Git タグと連携したバージョン自動取得

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