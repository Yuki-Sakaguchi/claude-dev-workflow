#!/bin/bash

# Claude Code Template - Version Management Script
# バージョン情報の表示とチェック機能を提供

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSION_FILE="$PROJECT_ROOT/.claude-version"

# 色付きログ出力用の関数
log_info() {
    echo -e "\033[32m[INFO]\033[0m $1"
}

log_warn() {
    echo -e "\033[33m[WARN]\033[0m $1"
}

log_error() {
    echo -e "\033[31m[ERROR]\033[0m $1"
}

# バージョンファイルの存在確認
check_version_file() {
    if [[ ! -f "$VERSION_FILE" ]]; then
        log_error "バージョンファイルが見つかりません: $VERSION_FILE"
        return 1
    fi
    return 0
}

# バージョン情報の読み込み
load_version() {
    if ! check_version_file; then
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        log_error "jqコマンドが必要です。インストールしてください: brew install jq"
        return 1
    fi
    
    VERSION=$(jq -r '.version' "$VERSION_FILE")
    COMPATIBILITY=$(jq -r '.compatibility' "$VERSION_FILE")
    LAST_UPDATED=$(jq -r '.last_updated' "$VERSION_FILE")
    FEATURES=$(jq -r '.features[]' "$VERSION_FILE")
    
    if [[ "$VERSION" == "null" ]]; then
        log_error "バージョン情報の読み込みに失敗しました"
        return 1
    fi
    
    return 0
}

# バージョン情報の表示
show_version() {
    if ! load_version; then
        return 1
    fi
    
    echo "======================================"
    echo "  Claude Code Template バージョン情報"
    echo "======================================"
    echo "バージョン: $VERSION"
    echo "互換性: $COMPATIBILITY"
    echo "最終更新: $LAST_UPDATED"
    echo ""
    echo "利用可能な機能:"
    echo "$FEATURES" | sed 's/^/  - /'
    echo ""
}

# バージョン比較（セマンティックバージョニング）
compare_versions() {
    local version1="$1"
    local version2="$2"
    
    # バージョンを配列に分割
    IFS='.' read -ra V1 <<< "$version1"
    IFS='.' read -ra V2 <<< "$version2"
    
    # 各要素を数値として比較
    for i in 0 1 2; do
        v1=${V1[$i]:-0}
        v2=${V2[$i]:-0}
        
        if (( v1 > v2 )); then
            return 1  # version1 > version2
        elif (( v1 < v2 )); then
            return 2  # version1 < version2
        fi
    done
    
    return 0  # version1 == version2
}

# 現在のバージョンを取得
get_current_version() {
    if load_version; then
        echo "$VERSION"
    else
        echo "unknown"
    fi
}

# バージョン履歴の表示
show_version_history() {
    if [[ -f "$PROJECT_ROOT/CHANGELOG.md" ]]; then
        log_info "バージョン履歴 (CHANGELOG.md より):"
        echo ""
        head -n 50 "$PROJECT_ROOT/CHANGELOG.md"
    else
        log_warn "CHANGELOG.mdが見つかりません"
    fi
}

# 使用方法の表示
show_usage() {
    echo "使用方法: $0 [オプション]"
    echo ""
    echo "オプション:"
    echo "  -v, --version     現在のバージョンを表示"
    echo "  -s, --show        詳細なバージョン情報を表示"
    echo "  -h, --history     バージョン履歴を表示"
    echo "  -c, --check       バージョンファイルの整合性をチェック"
    echo "  --help            このヘルプを表示"
    echo ""
    echo "例:"
    echo "  $0 --version      # 1.0.0"
    echo "  $0 --show         # 詳細情報表示"
    echo "  $0 --history      # 変更履歴表示"
}

# バージョンファイルの整合性チェック
check_version_integrity() {
    if ! check_version_file; then
        return 1
    fi
    
    log_info "バージョンファイルの整合性をチェック中..."
    
    # JSON形式の検証
    if ! jq empty "$VERSION_FILE" 2>/dev/null; then
        log_error "バージョンファイルのJSON形式が不正です"
        return 1
    fi
    
    # 必須フィールドの確認
    required_fields=("version" "compatibility" "last_updated" "features")
    for field in "${required_fields[@]}"; do
        if [[ $(jq -r ".$field" "$VERSION_FILE") == "null" ]]; then
            log_error "必須フィールドが不足しています: $field"
            return 1
        fi
    done
    
    # バージョン形式の確認（セマンティックバージョニング）
    if ! echo "$VERSION" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' >/dev/null; then
        log_error "バージョン形式が不正です: $VERSION (期待値: x.y.z)"
        return 1
    fi
    
    # 日付形式の確認
    if ! echo "$LAST_UPDATED" | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$' >/dev/null; then
        log_error "日付形式が不正です: $LAST_UPDATED (期待値: YYYY-MM-DDTHH:MM:SSZ)"
        return 1
    fi
    
    log_info "バージョンファイルの整合性チェック完了"
    return 0
}

# メイン処理
main() {
    case "${1:-}" in
        -v|--version)
            get_current_version
            ;;
        -s|--show)
            show_version
            ;;
        -h|--history)
            show_version_history
            ;;
        -c|--check)
            check_version_integrity
            ;;
        --help|"")
            show_usage
            ;;
        *)
            log_error "不正なオプション: $1"
            show_usage
            exit 1
            ;;
    esac
}

# スクリプトが直接実行された場合
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi