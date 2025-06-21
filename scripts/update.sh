#!/bin/bash

#
# Claude Code Template 更新スクリプト
# 
# 使用方法:
#   ./scripts/update.sh
#
# 機能:
#   - Gitリポジトリの最新化
#   - ローカルカスタマイズの検出・保護
#   - 変更ファイルの差分表示
#   - ユーザー確認プロンプト
#   - 選択的ファイル更新
#   - 更新前バックアップ作成
#   - ロールバック機能
#

set -euo pipefail

# 設定
readonly CLAUDE_DIR="$HOME/.claude"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
readonly BACKUP_PREFIX="$HOME/.claude.backup"
readonly TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
readonly VERSION_FILE="$CLAUDE_DIR/.claude-version"
readonly CUSTOM_FILES_LIST="$CLAUDE_DIR/.custom-files"

# 色定義
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# ログ関数
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

log_header() {
    echo -e "${BOLD}${BLUE}$1${NC}"
}

# エラーハンドリング
error_exit() {
    log_error "エラーが発生しました: $1"
    exit 1
}

# 割り込み処理
cleanup() {
    log_warning "更新が中断されました"
    exit 130
}
trap cleanup INT

# 現在のバージョン確認
get_current_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        grep '"version"' "$VERSION_FILE" | sed 's/.*"version": "\(.*\)".*/\1/'
    else
        echo "unknown"
    fi
}

# Git最新化チェック
check_git_updates() {
    log_info "リモートリポジトリの更新をチェックしています..."
    
    cd "$PROJECT_ROOT"
    
    # リモートリポジトリの最新情報を取得
    if ! git fetch origin; then
        error_exit "リモートリポジトリの情報取得に失敗しました"
    fi
    
    # 現在のブランチとリモートの差分確認
    local current_branch=$(git branch --show-current)
    local behind_count=$(git rev-list --count HEAD..origin/$current_branch 2>/dev/null || echo "0")
    
    if [[ "$behind_count" -eq 0 ]]; then
        log_success "既に最新版です"
        return 1
    else
        log_info "リモートより $behind_count コミット遅れています"
        return 0
    fi
}

# カスタマイズファイル検出
detect_custom_files() {
    log_info "ローカルカスタマイズを検出しています..."
    
    local custom_files=()
    
    # 既存のカスタムファイルリストを読み込み
    if [[ -f "$CUSTOM_FILES_LIST" ]]; then
        while IFS= read -r line; do
            if [[ -n "$line" && ! "$line" =~ ^# ]]; then
                custom_files+=("$line")
            fi
        done < "$CUSTOM_FILES_LIST"
    fi
    
    # プロジェクトルートの既存ファイルとの差分チェック
    local project_files=(
        "CLAUDE.md"
        "commands"
        "requirements"
        "workflow"
        "templates"
        "docs"
    )
    
    for file in "${project_files[@]}"; do
        local claude_file="$CLAUDE_DIR/$file"
        local project_file="$PROJECT_ROOT/$file"
        
        if [[ -e "$claude_file" && -e "$project_file" ]]; then
            if ! diff -q "$claude_file" "$project_file" &>/dev/null; then
                if [[ ! " ${custom_files[*]} " =~ " ${file} " ]]; then
                    custom_files+=("$file")
                fi
            fi
        fi
    done
    
    # カスタムファイルリストを更新
    if [[ ${#custom_files[@]} -gt 0 ]]; then
        {
            echo "# Claude Code Template - カスタマイズファイル一覧"
            echo "# $(date)"
            echo "#"
            for file in "${custom_files[@]}"; do
                echo "$file"
            done
        } > "$CUSTOM_FILES_LIST"
        
        log_warning "カスタマイズ済みファイルが検出されました:"
        for file in "${custom_files[@]}"; do
            echo "  - $file"
        done
    else
        log_info "カスタマイズファイルは検出されませんでした"
    fi
    
    echo "${custom_files[@]}"
}

# 変更ファイル差分表示
show_changes() {
    log_info "変更内容を確認しています..."
    
    cd "$PROJECT_ROOT"
    
    # リモートとの差分表示
    local current_branch=$(git branch --show-current)
    
    echo
    log_header "📝 変更されるファイル一覧:"
    git diff --name-only HEAD origin/$current_branch | while read -r file; do
        echo "  📄 $file"
    done
    
    echo
    log_header "📊 詳細な変更内容:"
    git log --oneline HEAD..origin/$current_branch | head -5
    
    local total_commits=$(git rev-list --count HEAD..origin/$current_branch)
    if [[ "$total_commits" -gt 5 ]]; then
        echo "  ... および他 $((total_commits - 5)) コミット"
    fi
    echo
}

# バックアップ作成
create_backup() {
    log_info "更新前バックアップを作成しています..."
    
    local backup_path="${BACKUP_PREFIX}.update.${TIMESTAMP}"
    
    if cp -r "$CLAUDE_DIR" "$backup_path"; then
        log_success "バックアップ完了: $backup_path"
        echo "$backup_path" > "$CLAUDE_DIR/.last-backup"
    else
        error_exit "バックアップの作成に失敗しました"
    fi
}

# ユーザー確認プロンプト
confirm_update() {
    local custom_files=($1)
    
    echo
    log_header "🤔 更新を実行しますか？"
    echo
    
    if [[ ${#custom_files[@]} -gt 0 ]]; then
        log_warning "以下のカスタマイズファイルは保護されます:"
        for file in "${custom_files[@]}"; do
            echo "  🔒 $file"
        done
        echo
    fi
    
    echo "選択してください:"
    echo "1) 更新を実行する"
    echo "2) 個別ファイル選択"
    echo "3) キャンセル"
    echo
    
    while true; do
        read -p "選択 (1-3): " choice
        case $choice in
            1)
                return 0
                ;;
            2)
                return 2
                ;;
            3)
                log_info "更新をキャンセルしました"
                exit 0
                ;;
            *)
                echo "1-3 の中から選択してください"
                ;;
        esac
    done
}

# 個別ファイル選択更新
selective_update() {
    local custom_files=($1)
    
    cd "$PROJECT_ROOT"
    
    log_header "📁 個別ファイル選択更新"
    echo
    
    # 変更されたファイル一覧を取得
    local current_branch=$(git branch --show-current)
    local changed_files=($(git diff --name-only HEAD origin/$current_branch))
    
    local selected_files=()
    
    for file in "${changed_files[@]}"; do
        # カスタマイズファイルの場合はスキップ
        if [[ " ${custom_files[*]} " =~ " ${file} " ]]; then
            log_warning "スキップ (カスタマイズ済み): $file"
            continue
        fi
        
        echo "📄 $file"
        echo "   変更内容プレビュー:"
        git diff HEAD origin/$current_branch -- "$file" | head -10
        echo
        
        while true; do
            read -p "このファイルを更新しますか？ (y/n): " choice
            case $choice in
                [Yy]*)
                    selected_files+=("$file")
                    break
                    ;;
                [Nn]*)
                    break
                    ;;
                *)
                    echo "y または n を入力してください"
                    ;;
            esac
        done
        echo
    done
    
    if [[ ${#selected_files[@]} -eq 0 ]]; then
        log_info "更新するファイルが選択されませんでした"
        exit 0
    fi
    
    log_info "選択されたファイル:"
    for file in "${selected_files[@]}"; do
        echo "  ✓ $file"
    done
    echo
    
    read -p "これらのファイルを更新しますか？ (y/n): " final_confirm
    if [[ ! "$final_confirm" =~ ^[Yy] ]]; then
        log_info "更新をキャンセルしました"
        exit 0
    fi
    
    # 選択されたファイルのみ更新
    update_selected_files "${selected_files[@]}"
}

# ファイル更新実行
update_files() {
    local custom_files=($1)
    
    log_info "ファイルを更新しています..."
    
    cd "$PROJECT_ROOT"
    
    # Git pull実行
    if git pull origin $(git branch --show-current); then
        log_success "Gitリポジトリの更新完了"
    else
        error_exit "Gitリポジトリの更新に失敗しました"
    fi
    
    # Claude dirへのファイルコピー
    local update_files=(
        "CLAUDE.md"
        "commands"
        "requirements"
        "workflow"
        "templates"
        "docs"
    )
    
    local updated_count=0
    
    for file in "${update_files[@]}"; do
        # カスタマイズファイルはスキップ
        if [[ " ${custom_files[*]} " =~ " ${file} " ]]; then
            log_warning "スキップ (カスタマイズ済み): $file"
            continue
        fi
        
        local source_path="$PROJECT_ROOT/$file"
        local dest_path="$CLAUDE_DIR/$file"
        
        if [[ -e "$source_path" ]]; then
            if rsync -a "$source_path" "$CLAUDE_DIR/"; then
                log_success "更新完了: $file"
                updated_count=$((updated_count + 1))
            else
                log_error "更新失敗: $file"
            fi
        fi
    done
    
    log_info "更新されたファイル数: $updated_count"
}

# 選択ファイル更新
update_selected_files() {
    local selected_files=("$@")
    
    log_info "選択されたファイルを更新しています..."
    
    cd "$PROJECT_ROOT"
    
    # Git pull実行
    if git pull origin $(git branch --show-current); then
        log_success "Gitリポジトリの更新完了"
    else
        error_exit "Gitリポジトリの更新に失敗しました"
    fi
    
    # 選択されたファイルのみコピー
    for file in "${selected_files[@]}"; do
        local source_path="$PROJECT_ROOT/$file"
        local dest_path="$CLAUDE_DIR/$file"
        
        if [[ -e "$source_path" ]]; then
            # ディレクトリの場合は親ディレクトリを作成
            if [[ -d "$source_path" ]]; then
                mkdir -p "$(dirname "$dest_path")"
                if rsync -a "$source_path/" "$dest_path/"; then
                    log_success "更新完了: $file"
                else
                    log_error "更新失敗: $file"
                fi
            else
                mkdir -p "$(dirname "$dest_path")"
                if cp "$source_path" "$dest_path"; then
                    log_success "更新完了: $file"
                else
                    log_error "更新失敗: $file"
                fi
            fi
        fi
    done
}

# バージョン情報更新
update_version_info() {
    log_info "バージョン情報を更新しています..."
    
    local new_version="1.0.1" # TODO: Gitタグから取得
    
    cat > "$VERSION_FILE" << EOF
{
  "version": "$new_version",
  "updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "updater": "update.sh",
  "previous_backup": "$(cat "$CLAUDE_DIR/.last-backup" 2>/dev/null || echo "")",
  "features": [
    "research",
    "automation", 
    "supabase",
    "static-analysis"
  ]
}
EOF
    
    log_success "バージョン情報を更新しました"
}

# ロールバック機能
rollback() {
    log_header "🔄 ロールバック機能"
    
    if [[ ! -f "$CLAUDE_DIR/.last-backup" ]]; then
        log_error "バックアップファイルが見つかりません"
        return 1
    fi
    
    local backup_path=$(cat "$CLAUDE_DIR/.last-backup")
    
    if [[ ! -d "$backup_path" ]]; then
        log_error "バックアップディレクトリが見つかりません: $backup_path"
        return 1
    fi
    
    echo "バックアップ: $backup_path"
    read -p "このバックアップにロールバックしますか？ (y/n): " confirm
    
    if [[ "$confirm" =~ ^[Yy] ]]; then
        # 現在の状態をバックアップ
        local current_backup="${BACKUP_PREFIX}.before-rollback.${TIMESTAMP}"
        cp -r "$CLAUDE_DIR" "$current_backup"
        
        # ロールバック実行
        rm -rf "$CLAUDE_DIR"
        cp -r "$backup_path" "$CLAUDE_DIR"
        
        log_success "ロールバック完了"
        log_info "現在の状態は以下に保存されました: $current_backup"
    else
        log_info "ロールバックをキャンセルしました"
    fi
}

# 更新完了レポート
show_update_report() {
    echo
    log_header "🎉 Claude Code Template の更新が完了しました！"
    echo
    echo "📍 更新場所: $CLAUDE_DIR"
    echo "📊 現在のバージョン: $(get_current_version)"
    echo
    echo "🔄 次の手順:"
    echo "1. Claude Code を再起動してください"
    echo "2. 以下のコマンドで動作確認:"
    echo "   ${BOLD}/research テスト調査${NC}"
    echo
    
    if [[ -f "$CLAUDE_DIR/.last-backup" ]]; then
        echo "💾 バックアップ: $(cat "$CLAUDE_DIR/.last-backup")"
        echo "🔄 ロールバック: ./scripts/update.sh --rollback"
        echo
    fi
    
    if [[ -f "$CUSTOM_FILES_LIST" ]]; then
        echo "🔒 保護されたカスタマイズファイル:"
        grep -v '^#' "$CUSTOM_FILES_LIST" | sed 's/^/   - /'
        echo
    fi
}

# メイン実行
main() {
    # コマンドライン引数処理
    if [[ "${1:-}" == "--rollback" ]]; then
        rollback
        exit $?
    fi
    
    log_header "🔄 Claude Code Template 更新開始"
    echo
    
    # 現在のバージョン表示
    log_info "現在のバージョン: $(get_current_version)"
    
    # 更新チェック
    if ! check_git_updates; then
        exit 0
    fi
    
    # 変更内容表示
    show_changes
    
    # カスタマイズファイル検出
    local custom_files=($(detect_custom_files))
    
    # ユーザー確認
    confirm_result=$(confirm_update "${custom_files[*]}")
    confirm_code=$?
    
    if [[ $confirm_code -eq 2 ]]; then
        # 個別ファイル選択
        create_backup
        selective_update "${custom_files[*]}"
    else
        # 通常更新
        create_backup
        update_files "${custom_files[*]}"
    fi
    
    # バージョン情報更新
    update_version_info
    
    # 完了レポート
    show_update_report
    
    log_success "更新が正常に完了しました"
}

# スクリプト実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi