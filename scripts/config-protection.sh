#!/bin/bash

# Claude Code Template - Configuration Customization Protection Script
# ユーザーカスタマイズの保護とマージ機能を提供

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
CUSTOMIZATION_FILE="$CLAUDE_DIR/.customizations.json"
CUSTOMIZATION_BACKUP_DIR="$CLAUDE_DIR/.customization-backups"

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

log_success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}

log_header() {
    echo -e "\033[1;34m$1\033[0m"
}

# エラーハンドリング
error_exit() {
    log_error "エラーが発生しました: $1"
    exit 1
}

# 必要なコマンドの確認
check_dependencies() {
    local required_commands=("sha256sum" "jq" "diff3")
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            # macOS環境での代替コマンド確認
            case "$cmd" in
                "sha256sum")
                    if command -v "shasum" >/dev/null 2>&1; then
                        log_info "sha256sumの代わりにshasumを使用します"
                        continue
                    fi
                    ;;
                "diff3")
                    if command -v "git" >/dev/null 2>&1; then
                        log_info "diff3の代わりにgit merge-fileを使用します"
                        continue
                    fi
                    ;;
            esac
            
            error_exit "必要なコマンドがインストールされていません: $cmd"
        fi
    done
}

# ファイルハッシュの計算
calculate_file_hash() {
    local file_path="$1"
    
    if [[ ! -f "$file_path" ]]; then
        echo ""
        return 1
    fi
    
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$file_path" | cut -d' ' -f1
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$file_path" | cut -d' ' -f1
    else
        error_exit "ハッシュ計算コマンドが見つかりません"
    fi
}

# カスタマイズファイルの初期化
init_customization_file() {
    if [[ ! -f "$CUSTOMIZATION_FILE" ]]; then
        mkdir -p "$(dirname "$CUSTOMIZATION_FILE")"
        cat > "$CUSTOMIZATION_FILE" << 'EOF'
{
  "version": "1.0.0",
  "created": "",
  "last_updated": "",
  "customizations": []
}
EOF
        
        # 現在の日時を設定
        local current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        jq --arg time "$current_time" '.created = $time | .last_updated = $time' "$CUSTOMIZATION_FILE" > "$CUSTOMIZATION_FILE.tmp"
        mv "$CUSTOMIZATION_FILE.tmp" "$CUSTOMIZATION_FILE"
        
        log_info "カスタマイズファイルを初期化しました: $CUSTOMIZATION_FILE"
    fi
    
    # バックアップディレクトリの作成
    mkdir -p "$CUSTOMIZATION_BACKUP_DIR"
}

# カスタマイズの検出
detect_customizations() {
    local file_path="$1"
    local original_hash="$2"
    
    if [[ ! -f "$file_path" ]]; then
        return 1
    fi
    
    local current_hash=$(calculate_file_hash "$file_path")
    
    if [[ "$current_hash" != "$original_hash" ]]; then
        return 0  # カスタマイズ検出
    else
        return 1  # カスタマイズなし
    fi
}

# カスタマイズ情報の記録
record_customization() {
    local file_path="$1"
    local relative_path="$2"
    local customization_type="$3"
    local reason="${4:-user_modification}"
    
    local current_hash=$(calculate_file_hash "$file_path")
    local current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # 既存のカスタマイズ情報を確認
    local existing_entry=$(jq --arg file "$relative_path" '.customizations[] | select(.file == $file)' "$CUSTOMIZATION_FILE")
    
    if [[ -n "$existing_entry" ]]; then
        # 既存エントリを更新
        jq --arg file "$relative_path" \
           --arg hash "$current_hash" \
           --arg time "$current_time" \
           --arg type "$customization_type" \
           --arg reason "$reason" \
           '(.customizations[] | select(.file == $file)) |= {
             file: $file,
             hash: $hash,
             modified: $time,
             type: $type,
             reason: $reason,
             sections: (.sections // []),
             backup_count: ((.backup_count // 0) + 1)
           } | .last_updated = $time' "$CUSTOMIZATION_FILE" > "$CUSTOMIZATION_FILE.tmp"
    else
        # 新規エントリを追加
        jq --arg file "$relative_path" \
           --arg hash "$current_hash" \
           --arg time "$current_time" \
           --arg type "$customization_type" \
           --arg reason "$reason" \
           '.customizations += [{
             file: $file,
             hash: $hash,
             modified: $time,
             type: $type,
             reason: $reason,
             sections: [],
             backup_count: 1
           }] | .last_updated = $time' "$CUSTOMIZATION_FILE" > "$CUSTOMIZATION_FILE.tmp"
    fi
    
    mv "$CUSTOMIZATION_FILE.tmp" "$CUSTOMIZATION_FILE"
    log_info "カスタマイズを記録しました: $relative_path"
}

# カスタマイズバックアップの作成
create_customization_backup() {
    local file_path="$1"
    local relative_path="$2"
    
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_dir="$CUSTOMIZATION_BACKUP_DIR/$(dirname "$relative_path")"
    local backup_file="$backup_dir/$(basename "$relative_path").backup.$timestamp"
    
    mkdir -p "$backup_dir"
    
    if cp "$file_path" "$backup_file"; then
        log_info "カスタマイズバックアップを作成: $backup_file"
        echo "$backup_file"
    else
        log_error "バックアップの作成に失敗: $file_path"
        return 1
    fi
}

# 三方向マージの実行
perform_three_way_merge() {
    local base_file="$1"      # 元のファイル（共通祖先）
    local current_file="$2"   # 現在のファイル（ユーザーカスタマイズ）
    local new_file="$3"       # 新しいファイル（更新版）
    local output_file="$4"    # マージ結果出力
    
    local temp_dir=$(mktemp -d)
    local merge_result=0
    
    # 一時ファイルの準備
    cp "$base_file" "$temp_dir/base"
    cp "$current_file" "$temp_dir/current"
    cp "$new_file" "$temp_dir/new"
    
    # マージの実行
    if command -v diff3 >/dev/null 2>&1; then
        # diff3を使用した三方向マージ
        if diff3 -m "$temp_dir/current" "$temp_dir/base" "$temp_dir/new" > "$output_file"; then
            merge_result=0
        else
            merge_result=$?
        fi
    elif command -v git >/dev/null 2>&1; then
        # git merge-fileを使用した三方向マージ
        cp "$temp_dir/current" "$output_file"
        if git merge-file "$output_file" "$temp_dir/base" "$temp_dir/new"; then
            merge_result=0
        else
            merge_result=$?
        fi
    else
        error_exit "マージツールが見つかりません（diff3またはgitが必要）"
    fi
    
    rm -rf "$temp_dir"
    return $merge_result
}

# 競合解決のインタラクティブ処理
resolve_conflicts_interactive() {
    local conflicted_file="$1"
    local current_file="$2"
    local new_file="$3"
    local output_file="$4"
    
    log_header "競合解決が必要です: $(basename "$conflicted_file")"
    echo ""
    
    echo "競合が発生したファイル: $conflicted_file"
    echo ""
    echo "選択肢:"
    echo "1) 現在のカスタマイズ版を保持"
    echo "2) 新しい標準版を使用"
    echo "3) マージ結果を編集"
    echo "4) 差分を表示して判断"
    echo "5) スキップ（後で手動対応）"
    echo ""
    
    while true; do
        read -p "選択してください (1-5): " choice
        
        case $choice in
            1)
                cp "$current_file" "$output_file"
                log_info "現在のカスタマイズ版を保持しました"
                return 0
                ;;
            2)
                cp "$new_file" "$output_file"
                log_info "新しい標準版を使用しました"
                return 0
                ;;
            3)
                if command -v "${EDITOR:-nano}" >/dev/null 2>&1; then
                    cp "$conflicted_file" "$output_file"
                    "${EDITOR:-nano}" "$output_file"
                    log_info "マージ結果を編集しました"
                    return 0
                else
                    log_error "エディタが見つかりません"
                fi
                ;;
            4)
                echo ""
                echo "=== 現在版 vs 新版の差分 ==="
                diff -u "$current_file" "$new_file" || true
                echo ""
                ;;
            5)
                log_warn "スキップしました。後で手動で対応してください: $conflicted_file"
                return 1
                ;;
            *)
                echo "1-5 の中から選択してください"
                ;;
        esac
    done
}

# 設定ファイルのマージ処理
merge_configuration_file() {
    local file_path="$1"
    local new_file_path="$2"
    local relative_path="$3"
    
    log_info "設定ファイルのマージを開始: $relative_path"
    
    # カスタマイズ情報の取得
    local customization_info=$(jq --arg file "$relative_path" '.customizations[] | select(.file == $file)' "$CUSTOMIZATION_FILE")
    
    if [[ -z "$customization_info" ]]; then
        # カスタマイズ情報がない場合は単純に上書き
        cp "$new_file_path" "$file_path"
        log_info "カスタマイズなし: 新版で上書きしました"
        return 0
    fi
    
    # バックアップの作成
    local backup_file=$(create_customization_backup "$file_path" "$relative_path")
    
    # 三方向マージの準備
    local temp_dir=$(mktemp -d)
    local base_file="$temp_dir/base"
    local merge_output="$temp_dir/merged"
    
    # ベースファイル（元のファイル）を復元または推定
    # 実際の実装では、Gitリポジトリやバックアップから取得
    if [[ -f "$PROJECT_ROOT/$relative_path" ]]; then
        cp "$PROJECT_ROOT/$relative_path" "$base_file"
    else
        # ベースファイルが見つからない場合は現在のファイルをベースとして使用
        cp "$file_path" "$base_file"
    fi
    
    # 三方向マージの実行
    if perform_three_way_merge "$base_file" "$file_path" "$new_file_path" "$merge_output"; then
        # マージ成功
        cp "$merge_output" "$file_path"
        log_success "自動マージが完了しました: $relative_path"
        
        # カスタマイズ情報の更新
        record_customization "$file_path" "$relative_path" "auto_merged" "successful_merge"
    else
        # マージ競合が発生
        log_warn "マージ競合が発生しました: $relative_path"
        
        if resolve_conflicts_interactive "$merge_output" "$file_path" "$new_file_path" "$file_path"; then
            # 競合解決成功
            record_customization "$file_path" "$relative_path" "manual_merged" "conflict_resolved"
        else
            # 競合解決スキップ
            record_customization "$file_path" "$relative_path" "merge_skipped" "user_skipped"
        fi
    fi
    
    rm -rf "$temp_dir"
}

# カスタマイズされたファイルの一覧表示
list_customizations() {
    if [[ ! -f "$CUSTOMIZATION_FILE" ]]; then
        log_info "カスタマイズ情報がありません"
        return 0
    fi
    
    log_header "カスタマイズされたファイル一覧"
    echo ""
    
    local customizations=$(jq -r '.customizations[] | "\(.file)|\(.type)|\(.modified)|\(.reason)"' "$CUSTOMIZATION_FILE")
    
    if [[ -z "$customizations" ]]; then
        echo "カスタマイズされたファイルはありません"
        return 0
    fi
    
    printf "%-30s %-15s %-20s %s\n" "ファイル" "タイプ" "更新日時" "理由"
    echo "$(printf '%.80s' "$(printf '%*s' 80 | tr ' ' '-')")"
    
    while IFS='|' read -r file type modified reason; do
        printf "%-30s %-15s %-20s %s\n" "$file" "$type" "${modified:0:19}" "$reason"
    done <<< "$customizations"
}

# カスタマイズの復元
restore_customization() {
    local file_path="$1"
    local backup_pattern="$2"
    
    local backup_dir="$CUSTOMIZATION_BACKUP_DIR/$(dirname "$file_path")"
    
    if [[ ! -d "$backup_dir" ]]; then
        log_error "バックアップディレクトリが見つかりません: $backup_dir"
        return 1
    fi
    
    # バックアップファイルの一覧表示
    log_header "利用可能なバックアップ: $file_path"
    echo ""
    
    local backups=($(ls -t "$backup_dir"/$(basename "$file_path").backup.* 2>/dev/null))
    
    if [[ ${#backups[@]} -eq 0 ]]; then
        log_error "バックアップファイルが見つかりません"
        return 1
    fi
    
    echo "バックアップ一覧:"
    for i in "${!backups[@]}"; do
        local backup_file="${backups[$i]}"
        local timestamp=$(basename "$backup_file" | sed 's/.*backup\.//')
        echo "$((i+1))) $timestamp ($(basename "$backup_file"))"
    done
    echo ""
    
    while true; do
        read -p "復元するバックアップを選択してください (1-${#backups[@]}): " choice
        
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#backups[@]} ]]; then
            local selected_backup="${backups[$((choice-1))]}"
            
            if cp "$selected_backup" "$file_path"; then
                log_success "バックアップから復元しました: $(basename "$selected_backup")"
                return 0
            else
                log_error "復元に失敗しました"
                return 1
            fi
        else
            echo "1-${#backups[@]} の中から選択してください"
        fi
    done
}

# カスタマイズのクリーンアップ
cleanup_customizations() {
    local days_to_keep="${1:-30}"
    
    log_info "古いカスタマイズバックアップをクリーンアップしています..."
    
    if [[ ! -d "$CUSTOMIZATION_BACKUP_DIR" ]]; then
        log_info "バックアップディレクトリが存在しません"
        return 0
    fi
    
    # 指定日数より古いバックアップファイルを削除
    local deleted_count=0
    
    while IFS= read -r -d '' backup_file; do
        if [[ -f "$backup_file" ]]; then
            rm "$backup_file"
            ((deleted_count++))
        fi
    done < <(find "$CUSTOMIZATION_BACKUP_DIR" -name "*.backup.*" -mtime +$days_to_keep -print0 2>/dev/null)
    
    log_info "古いバックアップファイルを削除しました: $deleted_count 個"
    
    # 空のディレクトリを削除
    find "$CUSTOMIZATION_BACKUP_DIR" -type d -empty -delete 2>/dev/null || true
}

# 使用方法の表示
show_usage() {
    echo "使用方法: $0 [オプション]"
    echo ""
    echo "オプション:"
    echo "  --init                    カスタマイズ管理の初期化"
    echo "  --detect <file>           ファイルのカスタマイズ検出"
    echo "  --merge <current> <new>   ファイルのマージ実行"
    echo "  --list                    カスタマイズ一覧表示"
    echo "  --restore <file>          バックアップからの復元"
    echo "  --cleanup [days]          古いバックアップのクリーンアップ"
    echo "  --help                    このヘルプを表示"
    echo ""
    echo "例:"
    echo "  $0 --init                 # 初期化"
    echo "  $0 --list                 # カスタマイズ一覧"
    echo "  $0 --merge current.md new.md  # ファイルマージ"
    echo "  $0 --cleanup 30           # 30日以上古いバックアップを削除"
}

# メイン処理
main() {
    # 依存関係チェック
    check_dependencies
    
    case "${1:-}" in
        --init)
            init_customization_file
            ;;
        --detect)
            if [[ -z "${2:-}" ]]; then
                error_exit "ファイルパスを指定してください"
            fi
            # ここでは簡単な実装
            log_info "カスタマイズ検出機能（実装中）"
            ;;
        --merge)
            if [[ -z "${2:-}" ]] || [[ -z "${3:-}" ]]; then
                error_exit "現在のファイルと新しいファイルのパスを指定してください"
            fi
            init_customization_file
            merge_configuration_file "${2}" "${3}" "$(basename "${2}")"
            ;;
        --list)
            list_customizations
            ;;
        --restore)
            if [[ -z "${2:-}" ]]; then
                error_exit "復元するファイルパスを指定してください"
            fi
            restore_customization "${2}" ""
            ;;
        --cleanup)
            local days="${2:-30}"
            cleanup_customizations "$days"
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