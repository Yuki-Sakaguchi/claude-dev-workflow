#!/bin/bash

# Claude Code Template - Customization History Manager
# カスタマイズ履歴の管理と可視化

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
CUSTOMIZATION_FILE="$CLAUDE_DIR/.customizations.json"
HISTORY_FILE="$CLAUDE_DIR/.customization-history.json"

# ログ関数
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

# 履歴ファイルの初期化
init_history_file() {
    if [[ ! -f "$HISTORY_FILE" ]]; then
        mkdir -p "$(dirname "$HISTORY_FILE")"
        cat > "$HISTORY_FILE" << 'EOF'
{
  "version": "1.0.0",
  "created": "",
  "last_updated": "",
  "entries": []
}
EOF
        
        # 現在の日時を設定
        local current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        if command -v jq >/dev/null 2>&1; then
            jq --arg time "$current_time" '.created = $time | .last_updated = $time' "$HISTORY_FILE" > "$HISTORY_FILE.tmp"
            mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
        fi
        
        log_info "カスタマイズ履歴ファイルを初期化しました: $HISTORY_FILE"
    fi
}

# 履歴エントリの追加
add_history_entry() {
    local file_path="$1"
    local action="$2"
    local description="$3"
    local before_hash="${4:-}"
    local after_hash="${5:-}"
    
    init_history_file
    
    local current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local entry_id="$(date +%s)_$(basename "$file_path")"
    
    if command -v jq >/dev/null 2>&1; then
        # jqを使用した場合
        jq --arg id "$entry_id" \
           --arg time "$current_time" \
           --arg file "$file_path" \
           --arg action "$action" \
           --arg desc "$description" \
           --arg before "$before_hash" \
           --arg after "$after_hash" \
           '.entries += [{
             id: $id,
             timestamp: $time,
             file: $file,
             action: $action,
             description: $desc,
             before_hash: $before,
             after_hash: $after,
             user: (env.USER // "unknown")
           }] | .last_updated = $time' "$HISTORY_FILE" > "$HISTORY_FILE.tmp"
        mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
    else
        # jqが使用できない場合の簡易実装
        log_warn "jqが利用できないため、簡易的な履歴記録を行います"
        echo "$(date): $action - $file_path - $description" >> "$CLAUDE_DIR/.customization-history.log"
    fi
    
    log_info "カスタマイズ履歴を記録しました: $action - $(basename "$file_path")"
}

# 履歴の表示
show_history() {
    local file_filter="${1:-}"
    local limit="${2:-20}"
    
    if [[ ! -f "$HISTORY_FILE" ]]; then
        log_info "カスタマイズ履歴がありません"
        return 0
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        # jqが使用できない場合
        if [[ -f "$CLAUDE_DIR/.customization-history.log" ]]; then
            log_header "カスタマイズ履歴 (簡易版)"
            tail -n "$limit" "$CLAUDE_DIR/.customization-history.log"
        else
            log_info "履歴がありません"
        fi
        return 0
    fi
    
    log_header "カスタマイズ履歴"
    echo ""
    
    local query='.entries'
    if [[ -n "$file_filter" ]]; then
        query="$query | map(select(.file | contains(\"$file_filter\")))"
    fi
    query="$query | sort_by(.timestamp) | reverse | .[:$limit]"
    
    local entries=$(jq -r "$query | .[] | \"\(.timestamp)|\(.action)|\(.file)|\(.description)\"" "$HISTORY_FILE")
    
    if [[ -z "$entries" ]]; then
        echo "履歴がありません"
        return 0
    fi
    
    printf "%-20s %-15s %-25s %s\n" "日時" "アクション" "ファイル" "説明"
    echo "$(printf '%.80s' "$(printf '%*s' 80 | tr ' ' '-')")"
    
    while IFS='|' read -r timestamp action file description; do
        local short_timestamp="${timestamp:0:19}"
        local short_file="$(basename "$file")"
        printf "%-20s %-15s %-25s %s\n" "$short_timestamp" "$action" "$short_file" "$description"
    done <<< "$entries"
}

# 特定ファイルの変更履歴
show_file_history() {
    local file_path="$1"
    
    if [[ ! -f "$HISTORY_FILE" ]]; then
        log_info "カスタマイズ履歴がありません"
        return 0
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        log_error "jqコマンドが必要です"
        return 1
    fi
    
    log_header "ファイル変更履歴: $(basename "$file_path")"
    echo ""
    
    local entries=$(jq -r --arg file "$file_path" '
        .entries 
        | map(select(.file == $file or (.file | endswith("/" + $file))))
        | sort_by(.timestamp)
        | reverse
        | .[]
        | "\(.timestamp)|\(.action)|\(.description)|\(.before_hash)|\(.after_hash)"
    ' "$HISTORY_FILE")
    
    if [[ -z "$entries" ]]; then
        echo "このファイルの履歴がありません"
        return 0
    fi
    
    printf "%-20s %-15s %-30s %-10s %s\n" "日時" "アクション" "説明" "変更前" "変更後"
    echo "$(printf '%.85s' "$(printf '%*s' 85 | tr ' ' '-')")"
    
    while IFS='|' read -r timestamp action description before_hash after_hash; do
        local short_timestamp="${timestamp:0:19}"
        local short_before="${before_hash:0:8}"
        local short_after="${after_hash:0:8}"
        printf "%-20s %-15s %-30s %-10s %s\n" "$short_timestamp" "$action" "$description" "$short_before" "$short_after"
    done <<< "$entries"
}

# 統計情報の表示
show_statistics() {
    if [[ ! -f "$HISTORY_FILE" ]]; then
        log_info "カスタマイズ履歴がありません"
        return 0
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        log_error "jqコマンドが必要です"
        return 1
    fi
    
    log_header "カスタマイズ統計情報"
    echo ""
    
    # 総エントリ数
    local total_entries=$(jq '.entries | length' "$HISTORY_FILE")
    echo "総変更回数: $total_entries"
    
    # アクション別統計
    echo ""
    echo "アクション別統計:"
    jq -r '.entries | group_by(.action) | .[] | "\(.[0].action): \(length)回"' "$HISTORY_FILE"
    
    # ファイル別統計
    echo ""
    echo "ファイル別変更回数 (上位10):"
    jq -r '.entries | group_by(.file) | sort_by(length) | reverse | .[:10] | .[] | "\(.[0].file | split("/") | last): \(length)回"' "$HISTORY_FILE"
    
    # 最新の変更
    echo ""
    echo "最近の変更 (最新5件):"
    jq -r '.entries | sort_by(.timestamp) | reverse | .[:5] | .[] | "\(.timestamp | strptime("%Y-%m-%dT%H:%M:%SZ") | strftime("%m/%d %H:%M")) \(.action) \(.file | split("/") | last)"' "$HISTORY_FILE"
}

# 履歴の検索
search_history() {
    local search_term="$1"
    local limit="${2:-10}"
    
    if [[ ! -f "$HISTORY_FILE" ]]; then
        log_info "カスタマイズ履歴がありません"
        return 0
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        log_error "jqコマンドが必要です"
        return 1
    fi
    
    log_header "履歴検索結果: '$search_term'"
    echo ""
    
    local entries=$(jq -r --arg term "$search_term" '
        .entries 
        | map(select(.file | contains($term) or .description | contains($term) or .action | contains($term)))
        | sort_by(.timestamp)
        | reverse
        | .[:'"$limit"']
        | .[]
        | "\(.timestamp)|\(.action)|\(.file)|\(.description)"
    ' "$HISTORY_FILE")
    
    if [[ -z "$entries" ]]; then
        echo "検索結果がありません"
        return 0
    fi
    
    printf "%-20s %-15s %-25s %s\n" "日時" "アクション" "ファイル" "説明"
    echo "$(printf '%.80s' "$(printf '%*s' 80 | tr ' ' '-')")"
    
    while IFS='|' read -r timestamp action file description; do
        local short_timestamp="${timestamp:0:19}"
        local short_file="$(basename "$file")"
        printf "%-20s %-15s %-25s %s\n" "$short_timestamp" "$action" "$short_file" "$description"
    done <<< "$entries"
}

# 履歴のエクスポート
export_history() {
    local output_file="$1"
    local format="${2:-json}"
    
    if [[ ! -f "$HISTORY_FILE" ]]; then
        log_error "カスタマイズ履歴がありません"
        return 1
    fi
    
    case "$format" in
        "json")
            cp "$HISTORY_FILE" "$output_file"
            log_success "履歴をJSONでエクスポートしました: $output_file"
            ;;
        "csv")
            if command -v jq >/dev/null 2>&1; then
                echo "timestamp,action,file,description,user" > "$output_file"
                jq -r '.entries[] | [.timestamp, .action, .file, .description, .user] | @csv' "$HISTORY_FILE" >> "$output_file"
                log_success "履歴をCSVでエクスポートしました: $output_file"
            else
                log_error "CSV出力にはjqコマンドが必要です"
                return 1
            fi
            ;;
        "text")
            if command -v jq >/dev/null 2>&1; then
                jq -r '.entries[] | "\(.timestamp) \(.action) \(.file) - \(.description)"' "$HISTORY_FILE" > "$output_file"
                log_success "履歴をテキストでエクスポートしました: $output_file"
            else
                log_error "テキスト出力にはjqコマンドが必要です"
                return 1
            fi
            ;;
        *)
            log_error "サポートされていない形式: $format (json, csv, text のいずれかを指定)"
            return 1
            ;;
    esac
}

# 履歴のクリーンアップ
cleanup_history() {
    local days_to_keep="${1:-90}"
    
    if [[ ! -f "$HISTORY_FILE" ]]; then
        log_info "カスタマイズ履歴がありません"
        return 0
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        log_error "jqコマンドが必要です"
        return 1
    fi
    
    log_info "古い履歴エントリをクリーンアップしています ($days_to_keep 日以上前)..."
    
    # 指定日数前の日時を計算
    local cutoff_date
    if command -v gdate >/dev/null 2>&1; then
        # GNU date (macOS with coreutils)
        cutoff_date=$(gdate -d "$days_to_keep days ago" -u +"%Y-%m-%dT%H:%M:%SZ")
    elif date -v -${days_to_keep}d >/dev/null 2>&1; then
        # BSD date (macOS default)
        cutoff_date=$(date -v -${days_to_keep}d -u +"%Y-%m-%dT%H:%M:%SZ")
    else
        # Linux date
        cutoff_date=$(date -d "$days_to_keep days ago" -u +"%Y-%m-%dT%H:%M:%SZ")
    fi
    
    local original_count=$(jq '.entries | length' "$HISTORY_FILE")
    
    jq --arg cutoff "$cutoff_date" '
        .entries = (.entries | map(select(.timestamp >= $cutoff)))
        | .last_updated = now | strftime("%Y-%m-%dT%H:%M:%SZ")
    ' "$HISTORY_FILE" > "$HISTORY_FILE.tmp"
    
    mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
    
    local new_count=$(jq '.entries | length' "$HISTORY_FILE")
    local deleted_count=$((original_count - new_count))
    
    log_info "古い履歴エントリを削除しました: $deleted_count 個 (残り: $new_count 個)"
}

# 使用方法の表示
show_usage() {
    echo "使用方法: $0 [オプション]"
    echo ""
    echo "オプション:"
    echo "  --add <file> <action> <description> [before_hash] [after_hash]"
    echo "                              履歴エントリを追加"
    echo "  --show [file_filter] [limit]  履歴を表示"
    echo "  --file <file_path>          特定ファイルの履歴表示"
    echo "  --stats                     統計情報表示"
    echo "  --search <term> [limit]     履歴検索"
    echo "  --export <file> [format]    履歴エクスポート (json|csv|text)"
    echo "  --cleanup [days]            古い履歴のクリーンアップ"
    echo "  --help                      このヘルプを表示"
    echo ""
    echo "例:"
    echo "  $0 --add CLAUDE.md modify 'セクション追加'"
    echo "  $0 --show                   # 全履歴表示"
    echo "  $0 --show CLAUDE 10         # CLAUDE関連の最新10件"
    echo "  $0 --file CLAUDE.md         # 特定ファイルの履歴"
    echo "  $0 --search 'merge'         # マージ関連の履歴検索"
    echo "  $0 --export history.csv csv # CSV形式でエクスポート"
    echo "  $0 --cleanup 60             # 60日以上前の履歴を削除"
}

# メイン処理
main() {
    case "${1:-}" in
        --add)
            if [[ -z "${2:-}" ]] || [[ -z "${3:-}" ]] || [[ -z "${4:-}" ]]; then
                log_error "ファイル、アクション、説明を指定してください"
                exit 1
            fi
            add_history_entry "$2" "$3" "$4" "${5:-}" "${6:-}"
            ;;
        --show)
            show_history "${2:-}" "${3:-20}"
            ;;
        --file)
            if [[ -z "${2:-}" ]]; then
                log_error "ファイルパスを指定してください"
                exit 1
            fi
            show_file_history "$2"
            ;;
        --stats)
            show_statistics
            ;;
        --search)
            if [[ -z "${2:-}" ]]; then
                log_error "検索語を指定してください"
                exit 1
            fi
            search_history "$2" "${3:-10}"
            ;;
        --export)
            if [[ -z "${2:-}" ]]; then
                log_error "出力ファイル名を指定してください"
                exit 1
            fi
            export_history "$2" "${3:-json}"
            ;;
        --cleanup)
            cleanup_history "${2:-90}"
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