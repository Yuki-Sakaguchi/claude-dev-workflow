#!/bin/bash

#
# Claude Dev Workflow バックアップスクリプト
# 
# 使用方法:
#   ./scripts/backup.sh [OPTIONS]
#
# オプション:
#   backup       - バックアップを作成
#   list         - バックアップ一覧を表示
#   cleanup      - 30日以上古いバックアップを削除
#   restore      - 指定したバックアップから復元
#   help         - ヘルプを表示
#
# 機能:
#   - タイムスタンプ付きバックアップ作成
#   - 圧縮によるサイズ最適化
#   - バックアップ一覧表示
#   - 古いバックアップの自動削除
#   - ロールバック機能
#   - 整合性チェック
#

set -euo pipefail

# 設定
readonly CLAUDE_DIR="$HOME/.claude"
readonly BACKUP_DIR="$HOME/.claude-backups"
readonly BACKUP_PREFIX="claude-backup"
readonly TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
readonly MAX_BACKUP_DAYS=30

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
    log_warning "処理が中断されました"
    exit 130
}
trap cleanup INT

# ディレクトリの初期化
init_backup_dir() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        log_info "バックアップディレクトリを作成しています: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        log_success "バックアップディレクトリを作成しました"
    fi
}

# Claude Dir の存在確認
check_claude_dir() {
    if [[ ! -d "$CLAUDE_DIR" ]]; then
        error_exit "Claude Dev Workflow がインストールされていません: $CLAUDE_DIR"
    fi
}

# バックアップの作成
create_backup() {
    log_header "🔄 バックアップを作成しています..."
    
    check_claude_dir
    init_backup_dir
    
    local backup_file="$BACKUP_DIR/${BACKUP_PREFIX}_${TIMESTAMP}.tar.gz"
    
    log_info "バックアップ対象: $CLAUDE_DIR"
    log_info "バックアップファイル: $backup_file"
    
    # 一時的な作業ディレクトリでバックアップを作成
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Claude Dir の内容をコピー
    if cp -r "$CLAUDE_DIR" "$temp_dir/"; then
        log_success "ファイルコピー完了"
    else
        rm -rf "$temp_dir"
        error_exit "ファイルのコピーに失敗しました"
    fi
    
    # 圧縮してバックアップ作成
    if tar -czf "$backup_file" -C "$temp_dir" "$(basename "$CLAUDE_DIR")"; then
        log_success "バックアップ作成完了: $backup_file"
        
        # ファイルサイズを表示
        local file_size
        file_size=$(du -h "$backup_file" | cut -f1)
        log_info "バックアップサイズ: $file_size"
        
        # 整合性チェック
        if verify_backup "$backup_file"; then
            log_success "整合性チェック完了"
        else
            log_warning "整合性チェックで警告が発生しました"
        fi
    else
        rm -rf "$temp_dir"
        error_exit "バックアップの作成に失敗しました"
    fi
    
    # 一時ディレクトリの削除
    rm -rf "$temp_dir"
    
    log_success "バックアップ処理が完了しました"
}

# バックアップ一覧の表示
list_backups() {
    log_header "📋 バックアップ一覧"
    
    if [[ ! -d "$BACKUP_DIR" ]] || [[ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
        log_info "バックアップが見つかりません"
        return 0
    fi
    
    echo
    printf "%-3s %-20s %-10s %-15s %s\n" "No." "ファイル名" "サイズ" "作成日時" "経過日数"
    printf "%-3s %-20s %-10s %-15s %s\n" "---" "--------------------" "----------" "---------------" "---------"
    
    local count=1
    local total_size=0
    
    # バックアップファイルを新しい順にソート
    while IFS= read -r -d '' file; do
        if [[ "$file" =~ ${BACKUP_PREFIX}_([0-9]{8}_[0-9]{6})\.tar\.gz$ ]]; then
            local timestamp="${BASH_REMATCH[1]}"
            local filename
            filename=$(basename "$file")
            
            # ファイルサイズ
            local size
            size=$(du -h "$file" | cut -f1)
            
            # 作成日時の計算
            local year month day hour min sec
            year="${timestamp:0:4}"
            month="${timestamp:4:2}"
            day="${timestamp:6:2}"
            hour="${timestamp:9:2}"
            min="${timestamp:11:2}"
            sec="${timestamp:13:2}"
            
            local formatted_date="${year}-${month}-${day} ${hour}:${min}:${sec}"
            
            # 経過日数の計算
            local backup_epoch file_epoch current_epoch days_ago
            backup_epoch=$(date -j -f "%Y%m%d_%H%M%S" "$timestamp" "+%s" 2>/dev/null || echo "0")
            current_epoch=$(date "+%s")
            
            if [[ "$backup_epoch" -gt 0 ]]; then
                days_ago=$(( (current_epoch - backup_epoch) / 86400 ))
                printf "%-3d %-20s %-10s %-15s %d日前\n" "$count" "$filename" "$size" "$formatted_date" "$days_ago"
            else
                printf "%-3d %-20s %-10s %-15s %s\n" "$count" "$filename" "$size" "$formatted_date" "不明"
            fi
            
            # 総サイズの計算（macOS対応）
            local size_bytes
            if [[ "$(uname)" == "Darwin" ]]; then
                size_bytes=$(stat -f%z "$file")
            else
                size_bytes=$(du -b "$file" | cut -f1)
            fi
            total_size=$((total_size + size_bytes))
            
            count=$((count + 1))
        fi
    done < <(find "$BACKUP_DIR" -name "${BACKUP_PREFIX}_*.tar.gz" -print0 | sort -zr)
    
    echo
    
    # 統計情報
    if [[ $count -gt 1 ]]; then
        local total_size_human
        total_size_human=$(echo "$total_size" | awk '{
            if ($1 >= 1024*1024*1024) printf "%.1fGB", $1/(1024*1024*1024)
            else if ($1 >= 1024*1024) printf "%.1fMB", $1/(1024*1024)
            else if ($1 >= 1024) printf "%.1fKB", $1/1024
            else printf "%dB", $1
        }')
        
        log_info "合計: $((count - 1))個のバックアップ, 総サイズ: $total_size_human"
    fi
}

# 古いバックアップの削除
cleanup_old_backups() {
    log_header "🧹 古いバックアップを削除しています..."
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        log_info "バックアップディレクトリが存在しません"
        return 0
    fi
    
    local deleted_count=0
    local current_epoch
    current_epoch=$(date "+%s")
    local cutoff_epoch=$((current_epoch - MAX_BACKUP_DAYS * 86400))
    
    while IFS= read -r -d '' file; do
        if [[ "$file" =~ ${BACKUP_PREFIX}_([0-9]{8}_[0-9]{6})\.tar\.gz$ ]]; then
            local timestamp="${BASH_REMATCH[1]}"
            local backup_epoch
            backup_epoch=$(date -j -f "%Y%m%d_%H%M%S" "$timestamp" "+%s" 2>/dev/null || echo "0")
            
            if [[ "$backup_epoch" -gt 0 ]] && [[ "$backup_epoch" -lt "$cutoff_epoch" ]]; then
                local filename
                filename=$(basename "$file")
                
                if rm "$file"; then
                    log_success "削除しました: $filename"
                    deleted_count=$((deleted_count + 1))
                else
                    log_warning "削除に失敗しました: $filename"
                fi
            fi
        fi
    done < <(find "$BACKUP_DIR" -name "${BACKUP_PREFIX}_*.tar.gz" -print0)
    
    if [[ $deleted_count -eq 0 ]]; then
        log_info "${MAX_BACKUP_DAYS}日以上古いバックアップは見つかりませんでした"
    else
        log_success "$deleted_count 個の古いバックアップを削除しました"
    fi
}

# バックアップの整合性チェック
verify_backup() {
    local backup_file="$1"
    
    if [[ ! -f "$backup_file" ]]; then
        log_error "バックアップファイルが見つかりません: $backup_file"
        return 1
    fi
    
    # tar ファイルの整合性チェック
    if tar -tzf "$backup_file" &>/dev/null; then
        log_success "バックアップファイルの整合性OK: $(basename "$backup_file")"
        return 0
    else
        log_error "バックアップファイルが破損しています: $(basename "$backup_file")"
        return 1
    fi
}

# ロールバック機能
restore_backup() {
    local backup_number="$1"
    
    log_header "🔄 バックアップからの復元"
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        error_exit "バックアップディレクトリが存在しません"
    fi
    
    # バックアップ一覧から指定番号のファイルを取得
    local count=1
    local target_file=""
    
    while IFS= read -r -d '' file; do
        if [[ "$file" =~ ${BACKUP_PREFIX}_([0-9]{8}_[0-9]{6})\.tar\.gz$ ]]; then
            if [[ $count -eq $backup_number ]]; then
                target_file="$file"
                break
            fi
            count=$((count + 1))
        fi
    done < <(find "$BACKUP_DIR" -name "${BACKUP_PREFIX}_*.tar.gz" -print0 | sort -zr)
    
    if [[ -z "$target_file" ]]; then
        error_exit "指定されたバックアップが見つかりません: #$backup_number"
    fi
    
    local filename
    filename=$(basename "$target_file")
    log_info "復元対象: $filename"
    
    # 整合性チェック
    if ! verify_backup "$target_file"; then
        error_exit "バックアップファイルが破損しています"
    fi
    
    # 現在の設定をバックアップ
    if [[ -d "$CLAUDE_DIR" ]]; then
        local current_backup="$BACKUP_DIR/${BACKUP_PREFIX}_before_restore_${TIMESTAMP}.tar.gz"
        log_info "現在の設定をバックアップしています: $(basename "$current_backup")"
        
        local temp_dir
        temp_dir=$(mktemp -d)
        
        if cp -r "$CLAUDE_DIR" "$temp_dir/" && tar -czf "$current_backup" -C "$temp_dir" "$(basename "$CLAUDE_DIR")"; then
            log_success "現在の設定のバックアップ完了"
        else
            rm -rf "$temp_dir"
            log_warning "現在の設定のバックアップに失敗しました（処理を続行します）"
        fi
        
        rm -rf "$temp_dir"
    fi
    
    # 既存のClaude Dirを削除
    if [[ -d "$CLAUDE_DIR" ]]; then
        log_info "既存の設定を削除しています..."
        rm -rf "$CLAUDE_DIR"
    fi
    
    # バックアップから復元
    log_info "バックアップから復元しています..."
    
    local temp_restore_dir
    temp_restore_dir=$(mktemp -d)
    
    if tar -xzf "$target_file" -C "$temp_restore_dir"; then
        # 復元されたディレクトリを正しい場所に移動
        if mv "$temp_restore_dir/$(basename "$CLAUDE_DIR")" "$CLAUDE_DIR"; then
            log_success "復元完了: $CLAUDE_DIR"
        else
            rm -rf "$temp_restore_dir"
            error_exit "復元に失敗しました"
        fi
    else
        rm -rf "$temp_restore_dir"
        error_exit "バックアップファイルの展開に失敗しました"
    fi
    
    rm -rf "$temp_restore_dir"
    
    log_success "ロールバック処理が完了しました"
}

# ヘルプの表示
show_help() {
    echo
    log_header "Claude Dev Workflow バックアップスクリプト"
    echo
    echo "使用方法:"
    echo "  $0 [COMMAND]"
    echo
    echo "コマンド:"
    echo "  backup       バックアップを作成"
    echo "  list         バックアップ一覧を表示"
    echo "  cleanup      30日以上古いバックアップを削除"
    echo "  restore <N>  指定したバックアップ（番号）から復元"
    echo "  help         このヘルプを表示"
    echo
    echo "例:"
    echo "  $0 backup                    # バックアップを作成"
    echo "  $0 list                      # バックアップ一覧を表示"
    echo "  $0 restore 1                 # 1番目のバックアップから復元"
    echo "  $0 cleanup                   # 古いバックアップを削除"
    echo
}

# メイン処理
main() {
    local command="${1:-help}"
    
    case "$command" in
        "backup")
            create_backup
            ;;
        "list")
            list_backups
            ;;
        "cleanup")
            cleanup_old_backups
            ;;
        "restore")
            if [[ $# -lt 2 ]]; then
                error_exit "復元するバックアップ番号を指定してください"
            fi
            restore_backup "$2"
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            log_error "不明なコマンド: $command"
            show_help
            exit 1
            ;;
    esac
}

# スクリプト実行
# HTTPS経由実行時の引数対応
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # 直接実行の場合
    main "$@"
else
    # curl | bash 実行の場合、環境変数から引数を取得
    if [[ -n "${BACKUP_COMMAND:-}" ]]; then
        main "$BACKUP_COMMAND" "${BACKUP_ARG:-}"
    else
        main "$@"
    fi
fi