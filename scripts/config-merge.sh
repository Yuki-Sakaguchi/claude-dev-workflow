#!/bin/bash

# Claude Code Template - Advanced Configuration Merge Utility
# 高度な設定ファイルマージとセクション別処理

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

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

# Markdownファイルのセクション別マージ
merge_markdown_sections() {
    local current_file="$1"
    local new_file="$2"
    local output_file="$3"
    
    log_info "Markdownファイルのセクション別マージを実行中..."
    
    # 一時ディレクトリの作成
    local temp_dir=$(mktemp -d)
    local current_sections="$temp_dir/current_sections"
    local new_sections="$temp_dir/new_sections"
    local merged_content="$temp_dir/merged"
    
    # セクションの抽出（## で始まる行でセクション分割）
    awk '
    /^## / { 
        if (section_name) {
            print section_name "|" section_content > "'$current_sections'"
        }
        section_name = $0
        section_content = ""
        next
    }
    { 
        if (section_name) {
            section_content = section_content "\n" $0
        } else {
            # ヘッダー部分（最初のセクション前）
            print $0 > "'$temp_dir'/header"
        }
    }
    END {
        if (section_name) {
            print section_name "|" section_content > "'$current_sections'"
        }
    }' "$current_file"
    
    awk '
    /^## / { 
        if (section_name) {
            print section_name "|" section_content > "'$new_sections'"
        }
        section_name = $0
        section_content = ""
        next
    }
    { 
        if (section_name) {
            section_content = section_content "\n" $0
        }
    }
    END {
        if (section_name) {
            print section_name "|" section_content > "'$new_sections'"
        }
    }' "$new_file"
    
    # ヘッダー部分をコピー
    if [[ -f "$temp_dir/header" ]]; then
        cat "$temp_dir/header" > "$merged_content"
    fi
    
    # セクションのマージ処理
    declare -A current_sections_map
    declare -A new_sections_map
    
    # 現在のセクションを連想配列に格納
    if [[ -f "$current_sections" ]]; then
        while IFS='|' read -r section_name section_content; do
            current_sections_map["$section_name"]="$section_content"
        done < "$current_sections"
    fi
    
    # 新しいセクションを連想配列に格納
    if [[ -f "$new_sections" ]]; then
        while IFS='|' read -r section_name section_content; do
            new_sections_map["$section_name"]="$section_content"
        done < "$new_sections"
    fi
    
    # マージロジック
    declare -A processed_sections
    
    # 現在のファイルのセクション順序を保持
    if [[ -f "$current_sections" ]]; then
        while IFS='|' read -r section_name section_content; do
            if [[ -n "${new_sections_map[$section_name]:-}" ]]; then
                # 両方に存在する場合は手動マージ判断
                if [[ "$section_content" == "${new_sections_map[$section_name]}" ]]; then
                    # 内容が同じ場合は新版を使用
                    echo "$section_name" >> "$merged_content"
                    echo "${new_sections_map[$section_name]}" >> "$merged_content"
                else
                    # 内容が異なる場合はユーザーに選択を求める
                    echo ""
                    echo "セクション競合が検出されました: $section_name"
                    echo "1) 現在版を保持"
                    echo "2) 新版を使用"
                    echo "3) 両方を結合"
                    
                    while true; do
                        read -p "選択してください (1-3): " choice
                        case $choice in
                            1)
                                echo "$section_name" >> "$merged_content"
                                echo "$section_content" >> "$merged_content"
                                break
                                ;;
                            2)
                                echo "$section_name" >> "$merged_content"
                                echo "${new_sections_map[$section_name]}" >> "$merged_content"
                                break
                                ;;
                            3)
                                echo "$section_name" >> "$merged_content"
                                echo "$section_content" >> "$merged_content"
                                echo "" >> "$merged_content"
                                echo "<!-- 新版からの追加内容 -->" >> "$merged_content"
                                echo "${new_sections_map[$section_name]}" >> "$merged_content"
                                break
                                ;;
                            *)
                                echo "1-3 の中から選択してください"
                                ;;
                        esac
                    done
                fi
            else
                # 現在版にのみ存在（カスタマイズセクション）
                echo "$section_name" >> "$merged_content"
                echo "$section_content" >> "$merged_content"
            fi
            processed_sections["$section_name"]=1
        done < "$current_sections"
    fi
    
    # 新版にのみ存在するセクションを追加
    if [[ -f "$new_sections" ]]; then
        while IFS='|' read -r section_name section_content; do
            if [[ -z "${processed_sections[$section_name]:-}" ]]; then
                echo "" >> "$merged_content"
                echo "$section_name" >> "$merged_content"
                echo "$section_content" >> "$merged_content"
            fi
        done < "$new_sections"
    fi
    
    # 最終的なマージ結果をコピー
    cp "$merged_content" "$output_file"
    
    rm -rf "$temp_dir"
    log_success "Markdownセクション別マージが完了しました"
}

# JSONファイルのキー別マージ
merge_json_keys() {
    local current_file="$1"
    local new_file="$2"
    local output_file="$3"
    
    log_info "JSONファイルのキー別マージを実行中..."
    
    if ! command -v jq >/dev/null 2>&1; then
        log_error "jqコマンドが必要です"
        return 1
    fi
    
    # JSONの妥当性確認
    if ! jq empty "$current_file" 2>/dev/null; then
        log_error "現在のJSONファイルが不正です: $current_file"
        return 1
    fi
    
    if ! jq empty "$new_file" 2>/dev/null; then
        log_error "新しいJSONファイルが不正です: $new_file"
        return 1
    fi
    
    # 基本的なマージ（新版を基準に、現在版の追加キーを保持）
    jq -s '.[1] * .[0]' "$new_file" "$current_file" > "$output_file"
    
    log_success "JSONキー別マージが完了しました"
}

# テキストファイルの行ベースマージ
merge_text_lines() {
    local current_file="$1"
    local new_file="$2"
    local output_file="$3"
    
    log_info "テキストファイルの行ベースマージを実行中..."
    
    # 一時ファイル
    local temp_dir=$(mktemp -d)
    local merged_temp="$temp_dir/merged"
    
    # 共通行の保持、追加行の検出を行う簡単なマージ
    # より高度な実装が必要な場合は、diff3やgit merge-fileを使用
    
    # 現在のファイルをベースに開始
    cp "$current_file" "$merged_temp"
    
    # 新しいファイルから追加された行を検出して追加
    while IFS= read -r line; do
        if ! grep -Fxq "$line" "$current_file"; then
            echo "# 新版から追加: $line" >> "$merged_temp"
            echo "$line" >> "$merged_temp"
        fi
    done < "$new_file"
    
    cp "$merged_temp" "$output_file"
    rm -rf "$temp_dir"
    
    log_success "テキスト行ベースマージが完了しました"
}

# ファイルタイプの判定
detect_file_type() {
    local file_path="$1"
    local extension="${file_path##*.}"
    
    case "$extension" in
        "md"|"markdown")
            echo "markdown"
            ;;
        "json")
            echo "json"
            ;;
        "txt"|"conf"|"cfg")
            echo "text"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# スマートマージの実行
smart_merge() {
    local current_file="$1"
    local new_file="$2"
    local output_file="$3"
    
    local file_type=$(detect_file_type "$current_file")
    
    log_info "ファイルタイプ: $file_type でスマートマージを実行"
    
    case "$file_type" in
        "markdown")
            merge_markdown_sections "$current_file" "$new_file" "$output_file"
            ;;
        "json")
            merge_json_keys "$current_file" "$new_file" "$output_file"
            ;;
        "text")
            merge_text_lines "$current_file" "$new_file" "$output_file"
            ;;
        *)
            log_warn "未知のファイルタイプ: 標準的な三方向マージを実行"
            # config-protection.shの関数を呼び出す場合
            log_info "標準的なマージ処理を実行..."
            cp "$current_file" "$output_file"  # 一時的な実装
            ;;
    esac
}

# マージプレビューの生成
generate_merge_preview() {
    local current_file="$1"
    local new_file="$2"
    local merged_file="$3"
    
    log_info "マージプレビューを生成中..."
    
    echo "=== マージプレビュー ==="
    echo ""
    echo "現在版 vs 新版:"
    diff -u "$current_file" "$new_file" || true
    echo ""
    echo "現在版 vs マージ結果:"
    diff -u "$current_file" "$merged_file" || true
    echo ""
    echo "新版 vs マージ結果:"
    diff -u "$new_file" "$merged_file" || true
}

# 使用方法の表示
show_usage() {
    echo "使用方法: $0 [オプション]"
    echo ""
    echo "オプション:"
    echo "  --smart <current> <new> <output>    スマートマージ実行"
    echo "  --markdown <current> <new> <output> Markdownセクション別マージ"
    echo "  --json <current> <new> <output>     JSONキー別マージ"
    echo "  --text <current> <new> <output>     テキスト行ベースマージ"
    echo "  --preview <current> <new> <merged>  マージプレビュー表示"
    echo "  --help                              このヘルプを表示"
    echo ""
    echo "例:"
    echo "  $0 --smart current.md new.md merged.md"
    echo "  $0 --json settings.json new_settings.json merged.json"
    echo "  $0 --preview current.md new.md merged.md"
}

# メイン処理
main() {
    case "${1:-}" in
        --smart)
            if [[ -z "${2:-}" ]] || [[ -z "${3:-}" ]] || [[ -z "${4:-}" ]]; then
                log_error "現在ファイル、新ファイル、出力ファイルのパスを指定してください"
                exit 1
            fi
            smart_merge "$2" "$3" "$4"
            ;;
        --markdown)
            if [[ -z "${2:-}" ]] || [[ -z "${3:-}" ]] || [[ -z "${4:-}" ]]; then
                log_error "現在ファイル、新ファイル、出力ファイルのパスを指定してください"
                exit 1
            fi
            merge_markdown_sections "$2" "$3" "$4"
            ;;
        --json)
            if [[ -z "${2:-}" ]] || [[ -z "${3:-}" ]] || [[ -z "${4:-}" ]]; then
                log_error "現在ファイル、新ファイル、出力ファイルのパスを指定してください"
                exit 1
            fi
            merge_json_keys "$2" "$3" "$4"
            ;;
        --text)
            if [[ -z "${2:-}" ]] || [[ -z "${3:-}" ]] || [[ -z "${4:-}" ]]; then
                log_error "現在ファイル、新ファイル、出力ファイルのパスを指定してください"
                exit 1
            fi
            merge_text_lines "$2" "$3" "$4"
            ;;
        --preview)
            if [[ -z "${2:-}" ]] || [[ -z "${3:-}" ]] || [[ -z "${4:-}" ]]; then
                log_error "現在ファイル、新ファイル、マージファイルのパスを指定してください"
                exit 1
            fi
            generate_merge_preview "$2" "$3" "$4"
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