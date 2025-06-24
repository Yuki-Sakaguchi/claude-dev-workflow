#!/bin/bash

# Claude Code Template - Compatibility Check Script
# バージョン互換性チェックとマイグレーション支援機能を提供

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSION_FILE="$PROJECT_ROOT/.claude-version"

# version.shから共通関数を読み込み
source "$SCRIPT_DIR/version.sh"

# 必須ファイル・ディレクトリの定義
REQUIRED_FILES=(
    "CLAUDE.md"
    "README.md"
    "CHANGELOG.md"
    ".claude-version"
)

REQUIRED_DIRS=(
    "scripts"
    "templates"
    "workflow"
    "requirements"
    "commands"
)

REQUIRED_SCRIPTS=(
    "scripts/install.sh"
    "scripts/update.sh"
    "scripts/backup.sh"
    "scripts/version.sh"
    "scripts/check-compatibility.sh"
)

# 互換性チェック結果
COMPATIBILITY_ISSUES=()
MIGRATION_REQUIRED=false
CRITICAL_ISSUES=false

# 互換性問題を記録
add_compatibility_issue() {
    local severity="$1"
    local message="$2"
    
    COMPATIBILITY_ISSUES+=("$severity: $message")
    
    if [[ "$severity" == "CRITICAL" ]]; then
        CRITICAL_ISSUES=true
        MIGRATION_REQUIRED=true
    elif [[ "$severity" == "WARNING" ]]; then
        MIGRATION_REQUIRED=true
    fi
}

# 必須ファイルの存在確認
check_required_files() {
    log_info "必須ファイルの存在確認中..."
    
    for file in "${REQUIRED_FILES[@]}"; do
        if [[ ! -f "$PROJECT_ROOT/$file" ]]; then
            add_compatibility_issue "CRITICAL" "必須ファイルが不足: $file"
        fi
    done
    
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [[ ! -d "$PROJECT_ROOT/$dir" ]]; then
            add_compatibility_issue "CRITICAL" "必須ディレクトリが不足: $dir"
        fi
    done
    
    for script in "${REQUIRED_SCRIPTS[@]}"; do
        if [[ ! -f "$PROJECT_ROOT/$script" ]]; then
            add_compatibility_issue "WARNING" "推奨スクリプトが不足: $script"
        elif [[ ! -x "$PROJECT_ROOT/$script" ]]; then
            add_compatibility_issue "WARNING" "スクリプトに実行権限がありません: $script"
        fi
    done
}

# バージョンファイル形式の互換性確認
check_version_format() {
    log_info "バージョンファイル形式の確認中..."
    
    if ! check_version_file; then
        add_compatibility_issue "CRITICAL" "バージョンファイルが見つかりません"
        return 1
    fi
    
    # 新形式で必要なフィールドを確認
    local required_version_fields=("version" "compatibility" "last_updated" "features")
    
    for field in "${required_version_fields[@]}"; do
        if [[ $(jq -r ".$field" "$VERSION_FILE" 2>/dev/null) == "null" ]]; then
            add_compatibility_issue "WARNING" "バージョンファイルに推奨フィールドが不足: $field"
        fi
    done
    
    # 非推奨フィールドの確認
    local deprecated_fields=("legacy_version" "old_format")
    for field in "${deprecated_fields[@]}"; do
        if [[ $(jq -r ".$field" "$VERSION_FILE" 2>/dev/null) != "null" ]]; then
            add_compatibility_issue "INFO" "非推奨フィールドが検出されました: $field"
        fi
    done
}

# テンプレート形式の互換性確認
check_template_format() {
    log_info "テンプレート形式の確認中..."
    
    # テンプレートファイルの形式確認
    local template_files=(
        "templates/issue-template.md"
        "templates/pr-template.md"
        "templates/commit-message.md"
    )
    
    for template in "${template_files[@]}"; do
        if [[ -f "$PROJECT_ROOT/$template" ]]; then
            # テンプレートの基本的な形式確認
            if ! grep -q "^#" "$PROJECT_ROOT/$template"; then
                add_compatibility_issue "WARNING" "テンプレートにヘッダーがありません: $template"
            fi
        fi
    done
}

# 設定ファイルの互換性確認
check_config_compatibility() {
    log_info "設定ファイルの互換性確認中..."
    
    # settings.jsonの確認
    if [[ -f "$PROJECT_ROOT/settings.json" ]]; then
        if ! jq empty "$PROJECT_ROOT/settings.json" 2>/dev/null; then
            add_compatibility_issue "WARNING" "settings.jsonの形式が不正です"
        fi
    fi
    
    # CLAUDE.mdの確認
    if [[ -f "$PROJECT_ROOT/CLAUDE.md" ]]; then
        # 必要なセクションがあるかチェック
        local required_sections=("## 🎯 このガイドラインについて" "## 📋 新しい調査・分析コマンド")
        
        for section in "${required_sections[@]}"; do
            if ! grep -q "$section" "$PROJECT_ROOT/CLAUDE.md"; then
                add_compatibility_issue "INFO" "CLAUDE.mdに推奨セクションがありません: $section"
            fi
        done
    fi
}

# 破壊的変更の確認
check_breaking_changes() {
    log_info "破壊的変更の確認中..."
    
    if ! load_version; then
        return 1
    fi
    
    # 破壊的変更がある場合の処理
    local breaking_changes=$(jq -r '.breaking_changes[]?' "$VERSION_FILE" 2>/dev/null)
    
    if [[ -n "$breaking_changes" ]]; then
        while IFS= read -r change; do
            add_compatibility_issue "CRITICAL" "破壊的変更: $change"
        done <<< "$breaking_changes"
    fi
    
    # マイグレーション要求の確認
    local migration_required=$(jq -r '.migration_required' "$VERSION_FILE" 2>/dev/null)
    if [[ "$migration_required" == "true" ]]; then
        MIGRATION_REQUIRED=true
        add_compatibility_issue "WARNING" "マイグレーションが必要です"
    fi
}

# 依存関係の確認
check_dependencies() {
    log_info "依存関係の確認中..."
    
    # 必要なコマンドの確認
    local required_commands=("git" "jq")
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            add_compatibility_issue "CRITICAL" "必要なコマンドがインストールされていません: $cmd"
        fi
    done
    
    # 推奨コマンドの確認
    local recommended_commands=("gh" "curl" "rsync")
    
    for cmd in "${recommended_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            add_compatibility_issue "INFO" "推奨コマンドがインストールされていません: $cmd"
        fi
    done
}

# マイグレーション支援情報の表示
show_migration_guide() {
    if [[ "$MIGRATION_REQUIRED" == "true" ]]; then
        echo ""
        echo "======================================"
        echo "  マイグレーションガイド"
        echo "======================================"
        echo ""
        echo "以下の手順でマイグレーションを実行してください："
        echo ""
        echo "1. データバックアップ:"
        echo "   ./scripts/backup.sh"
        echo ""
        echo "2. 互換性確認:"
        echo "   ./scripts/check-compatibility.sh"
        echo ""
        echo "3. 更新実行:"
        echo "   ./scripts/update.sh"
        echo ""
        echo "4. 動作確認:"
        echo "   ./scripts/version.sh --check"
        echo ""
        
        if [[ "$CRITICAL_ISSUES" == "true" ]]; then
            log_error "クリティカルな問題が検出されました。手動での対応が必要です。"
        fi
    fi
}

# 互換性チェック結果の表示
show_compatibility_results() {
    echo ""
    echo "======================================"
    echo "  互換性チェック結果"
    echo "======================================"
    echo ""
    
    if [[ ${#COMPATIBILITY_ISSUES[@]} -eq 0 ]]; then
        log_info "互換性チェック完了: 問題は検出されませんでした"
        return 0
    fi
    
    local critical_count=0
    local warning_count=0
    local info_count=0
    
    for issue in "${COMPATIBILITY_ISSUES[@]}"; do
        echo "$issue"
        
        if [[ "$issue" =~ ^CRITICAL: ]]; then
            ((critical_count++))
        elif [[ "$issue" =~ ^WARNING: ]]; then
            ((warning_count++))
        elif [[ "$issue" =~ ^INFO: ]]; then
            ((info_count++))
        fi
    done
    
    echo ""
    echo "サマリー:"
    echo "  CRITICAL: $critical_count"
    echo "  WARNING: $warning_count"
    echo "  INFO: $info_count"
    echo ""
    
    if [[ "$critical_count" -gt 0 ]]; then
        log_error "クリティカルな問題が $critical_count 件検出されました"
        return 1
    elif [[ "$warning_count" -gt 0 ]]; then
        log_warn "警告が $warning_count 件検出されました"
        return 2
    else
        log_info "軽微な情報が $info_count 件あります"
        return 0
    fi
}

# 自動修復機能
auto_fix_issues() {
    log_info "自動修復を試行中..."
    
    # 実行権限の修復
    for script in "${REQUIRED_SCRIPTS[@]}"; do
        if [[ -f "$PROJECT_ROOT/$script" && ! -x "$PROJECT_ROOT/$script" ]]; then
            chmod +x "$PROJECT_ROOT/$script"
            log_info "実行権限を修復: $script"
        fi
    done
    
    # 必須ディレクトリの作成
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [[ ! -d "$PROJECT_ROOT/$dir" ]]; then
            mkdir -p "$PROJECT_ROOT/$dir"
            log_info "ディレクトリを作成: $dir"
        fi
    done
    
    log_info "自動修復完了"
}

# 使用方法の表示
show_usage() {
    echo "使用方法: $0 [オプション]"
    echo ""
    echo "オプション:"
    echo "  -c, --check       互換性チェックを実行"
    echo "  -f, --fix         自動修復を試行"
    echo "  -m, --migration   マイグレーションガイドを表示"
    echo "  -v, --verbose     詳細な出力"
    echo "  --help            このヘルプを表示"
    echo ""
    echo "例:"
    echo "  $0 --check       # 互換性チェック実行"
    echo "  $0 --fix         # 問題の自動修復"
    echo "  $0 --migration   # マイグレーションガイド表示"
}

# 包括的な互換性チェックの実行
run_compatibility_check() {
    local verbose="${1:-false}"
    
    if [[ "$verbose" == "true" ]]; then
        set -x
    fi
    
    check_required_files
    check_version_format
    check_template_format
    check_config_compatibility
    check_breaking_changes
    check_dependencies
    
    show_compatibility_results
    local exit_code=$?
    
    show_migration_guide
    
    return $exit_code
}

# メイン処理
main() {
    case "${1:-}" in
        -c|--check)
            run_compatibility_check
            ;;
        -f|--fix)
            auto_fix_issues
            run_compatibility_check
            ;;
        -m|--migration)
            show_migration_guide
            ;;
        -v|--verbose)
            run_compatibility_check true
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