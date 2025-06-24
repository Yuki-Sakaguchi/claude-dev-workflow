#!/bin/bash

#
# Claude Dev Workflow 更新スクリプト
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
readonly BACKUP_PREFIX="$HOME/.claude.backup"
readonly TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
readonly VERSION_FILE="$CLAUDE_DIR/.claude-version"
readonly CUSTOM_FILES_LIST="$CLAUDE_DIR/.custom-files"
readonly GITHUB_REPO="https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main"

# 実行環境判定（ローカル実行 vs curlパイプ実行）
if [[ "${0}" == "bash" ]] || [[ "${0}" =~ ^/dev/fd/ ]] || [[ -z "${BASH_SOURCE[0]:-}" ]]; then
    # curlパイプ実行（stdin経由）
    readonly EXECUTION_MODE="curl"
    readonly SCRIPT_DIR=""
    readonly PROJECT_ROOT=""
else
    # ローカル実行
    readonly EXECUTION_MODE="local"
    readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
    readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
fi

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

# 設定保護機能の読み込み
source_config_protection() {
    # 設定保護ツールが利用可能な場合のみ読み込み
    if [[ -f "$CLAUDE_DIR/scripts/config-protection.sh" ]]; then
        source "$CLAUDE_DIR/scripts/config-protection.sh"
        log_info "設定保護ツールを読み込みました"
        return 0
    elif [[ -f "$SCRIPT_DIR/config-protection.sh" ]]; then
        source "$SCRIPT_DIR/config-protection.sh"
        log_info "設定保護ツールを読み込みました (ローカル)"
        return 0
    fi
    return 1
}

# 現在のバージョン確認
get_current_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        if command -v jq >/dev/null 2>&1; then
            jq -r '.version' "$VERSION_FILE" 2>/dev/null || echo "unknown"
        else
            grep '"version"' "$VERSION_FILE" | sed 's/.*"version": "\(.*\)".*/\1/' || echo "unknown"
        fi
    else
        echo "unknown"
    fi
}

# プロジェクトのファイル一覧を動的に取得
get_project_files() {
    local files=()
    
    if [[ "$EXECUTION_MODE" == "local" ]]; then
        # ローカル実行時
        # CLAUDE.md
        if [[ -f "$PROJECT_ROOT/CLAUDE.md" ]]; then
            files+=("CLAUDE.md")
        fi
        
        # settings.json
        if [[ -f "$PROJECT_ROOT/settings.json" ]]; then
            files+=("settings.json")
        fi
        
        # ディレクトリ一覧を動的に取得
        for dir in commands requirements workflow templates docs scripts; do
            if [[ -d "$PROJECT_ROOT/$dir" ]]; then
                files+=("$dir")
            fi
        done
    else
        # curlパイプ実行時は固定リスト
        files=("CLAUDE.md" "settings.json" "commands" "requirements" "workflow" "templates" "docs" "scripts")
    fi
    
    printf '%s\n' "${files[@]}"
}

# GitHubからファイルをダウンロード
download_from_github() {
    local file_path="$1"
    local dest_path="$2"
    local url="${GITHUB_REPO}/${file_path}"
    
    if curl -sf "$url" -o "$dest_path"; then
        return 0
    else
        return 1
    fi
}

# GitHub APIからディレクトリ内のファイル一覧を取得（再帰的）
get_directory_files() {
    local dir_name="$1"
    local api_url="https://api.github.com/repos/Yuki-Sakaguchi/claude-dev-workflow/contents/${dir_name}"
    
    # GitHub APIからレスポンスを取得
    local response
    response=$(curl -sf "$api_url")
    
    if [[ -z "$response" ]]; then
        return 1
    fi
    
    # ファイルとディレクトリを分別して処理
    local files=()
    local dirs=()
    
    # .mdファイルと.shファイルを抽出
    while IFS= read -r line; do
        if [[ "$line" =~ \"name\":\ \"([^\"]+\.(md|sh))\" ]]; then
            files+=("${BASH_REMATCH[1]}")
        fi
    done <<< "$response"
    
    # サブディレクトリを抽出
    while IFS= read -r line; do
        if [[ "$line" =~ \"type\":\ \"dir\" ]]; then
            # 同じエントリブロック内でディレクトリ名を探す
            local dir_block
            dir_block=$(echo "$response" | grep -A5 -B5 "$line")
            if [[ "$dir_block" =~ \"name\":\ \"([^\"]+)\" ]]; then
                dirs+=("${BASH_REMATCH[1]}")
            fi
        fi
    done <<< "$response"
    
    # 直接のファイルを出力
    if [[ ${#files[@]} -gt 0 ]]; then
        for file in "${files[@]}"; do
            echo "$file"
        done
    fi
    
    # サブディレクトリ内のファイルを再帰的に取得
    if [[ ${#dirs[@]} -gt 0 ]]; then
        for dir in "${dirs[@]}"; do
            local subdir_files
            subdir_files=$(get_directory_files "${dir_name}/${dir}")
            while IFS= read -r subfile; do
                [[ -n "$subfile" ]] && echo "${dir}/${subfile}"
            done <<< "$subdir_files"
        done
    fi
}

# ディレクトリを再帰的にダウンロード
download_directory() {
    local dir_name="$1"
    local dest_dir="$CLAUDE_DIR/$dir_name"
    
    # ディレクトリ作成
    mkdir -p "$dest_dir"
    
    # GitHub APIからファイル一覧を動的に取得
    log_info "  GitHubからファイル一覧を取得中..."
    local files_list
    files_list=$(get_directory_files "$dir_name")
    
    if [[ -z "$files_list" ]]; then
        log_warning "  ファイル一覧の取得に失敗: $dir_name"
        return 1
    fi
    
    # 取得したファイルを配列に変換
    local files=()
    while IFS= read -r file; do
        [[ -n "$file" ]] && files+=("$file")
    done <<< "$files_list"
    
    if [[ ${#files[@]} -eq 0 ]]; then
        log_warning "  対象ファイルが見つかりません: $dir_name"
        return 1
    fi
    
    log_info "  ${#files[@]}個のファイルを発見: $dir_name"
    
    # 各ファイルをダウンロード
    local success_count=0
    for file in "${files[@]}"; do
        local file_path="${dir_name}/${file}"
        local dest_file_path="${dest_dir}/${file}"
        
        # サブディレクトリが含まれている場合、ディレクトリ構造を作成
        local dest_file_dir
        dest_file_dir=$(dirname "$dest_file_path")
        mkdir -p "$dest_file_dir"
        
        if download_from_github "$file_path" "$dest_file_path"; then
            log_success "  ダウンロード完了: $file"
            ((success_count++))
        else
            log_warning "  ダウンロード失敗 (スキップ): $file"
        fi
    done
    
    log_info "  ${success_count}/${#files[@]} ファイルのダウンロードが完了"
    return 0
}

# Git最新化チェック
check_git_updates() {
    log_info "リモートリポジトリの更新をチェックしています..."
    
    # curlパイプ実行時はスキップ
    if [[ "$EXECUTION_MODE" == "curl" ]]; then
        log_info "リモート実行のため更新チェックをスキップします"
        return 0
    fi
    
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

# カスタマイズファイル検出（設定保護機能使用）
detect_custom_files() {
    log_info "ローカルカスタマイズを検出しています..."
    
    local custom_files=()
    
    # 設定保護機能を使用してカスタマイズ検出
    if source_config_protection; then
        # 設定保護機能を初期化
        init_customization_file 2>/dev/null || true
        
        # カスタマイズファイル一覧を取得
        if [[ -f "$CLAUDE_DIR/.customizations.json" ]] && command -v jq >/dev/null 2>&1; then
            while IFS= read -r file; do
                [[ -n "$file" ]] && custom_files+=("$file")
            done < <(jq -r '.customizations[].file' "$CLAUDE_DIR/.customizations.json" 2>/dev/null)
        fi
    fi
    
    # 既存のカスタムファイルリストを読み込み（フォールバック）
    if [[ -f "$CUSTOM_FILES_LIST" ]]; then
        while IFS= read -r line; do
            if [[ -n "$line" && ! "$line" =~ ^# ]]; then
                if [[ ! " ${custom_files[*]} " =~ " ${line} " ]]; then
                    custom_files+=("$line")
                fi
            fi
        done < "$CUSTOM_FILES_LIST"
    fi
    
    # プロジェクトルートの既存ファイルとの差分チェック（動的取得）
    local project_files=()
    while IFS= read -r file; do
        project_files+=("$file")
    done < <(get_project_files)
    
    for file in "${project_files[@]}"; do
        local claude_file="$CLAUDE_DIR/$file"
        local project_file="$PROJECT_ROOT/$file"
        
        if [[ -e "$claude_file" && -e "$project_file" ]]; then
            if ! diff -q "$claude_file" "$project_file" &>/dev/null; then
                if [[ ! " ${custom_files[*]} " =~ " ${file} " ]]; then
                    custom_files+=("$file")
                    
                    # 設定保護機能でカスタマイズを記録
                    if command -v record_customization >/dev/null 2>&1; then
                        record_customization "$claude_file" "$file" "detected" "update_process_detection" 2>/dev/null || true
                    fi
                fi
            fi
        fi
    done
    
    # カスタムファイルリストを更新
    if [[ ${#custom_files[@]} -gt 0 ]]; then
        {
            echo "# Claude Dev Workflow - カスタマイズファイル一覧"
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
    
    # curlパイプ実行時はスキップ
    if [[ "$EXECUTION_MODE" == "curl" ]]; then
        log_info "リモート実行のため変更内容表示をスキップします"
        return 0
    fi
    
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
    local custom_files=()
    if [[ -n "$1" ]]; then
        custom_files=($1)
    fi
    
    log_info "ファイルを更新しています..."
    
    if [[ "$EXECUTION_MODE" == "local" ]]; then
        # ローカル実行時: Git pullして通常の更新
        cd "$PROJECT_ROOT"
        
        # Git pull実行
        if git pull origin $(git branch --show-current); then
            log_success "Gitリポジトリの更新完了"
        else
            error_exit "Gitリポジトリの更新に失敗しました"
        fi
        
        # Claude dirへのファイルコピー（動的取得）
        local update_files=()
        while IFS= read -r file; do
            update_files+=("$file")
        done < <(get_project_files)
        
        local updated_count=0
        
        for file in "${update_files[@]}"; do
            local source_path="$PROJECT_ROOT/$file"
            local dest_path="$CLAUDE_DIR/$file"
            
            if [[ ! -e "$source_path" ]]; then
                continue
            fi
            
            # カスタマイズファイルの場合は設定保護機能でマージ
            if [[ ${#custom_files[@]} -gt 0 ]] && [[ " ${custom_files[*]} " =~ " ${file} " ]]; then
                log_info "カスタマイズファイルのマージ処理: $file"
                
                # 設定保護機能を使用してマージ
                if command -v merge_configuration_file >/dev/null 2>&1; then
                    if merge_configuration_file "$dest_path" "$source_path" "$file" 2>/dev/null; then
                        log_success "インテリジェントマージ完了: $file"
                        updated_count=$((updated_count + 1))
                    else
                        log_warning "マージ処理をスキップ: $file"
                    fi
                elif [[ -f "$SCRIPT_DIR/config-merge.sh" ]]; then
                    # config-merge.shを使用してスマートマージ
                    local temp_merged=$(mktemp)
                    if "$SCRIPT_DIR/config-merge.sh" --smart "$dest_path" "$source_path" "$temp_merged" 2>/dev/null; then
                        mv "$temp_merged" "$dest_path"
                        log_success "スマートマージ完了: $file"
                        updated_count=$((updated_count + 1))
                        
                        # 履歴記録
                        if [[ -f "$SCRIPT_DIR/customization-history.sh" ]]; then
                            "$SCRIPT_DIR/customization-history.sh" --add "$dest_path" "smart_merge" "Update merge with customization preservation" 2>/dev/null || true
                        fi
                    else
                        log_warning "スマートマージ失敗、スキップ: $file"
                        rm -f "$temp_merged"
                    fi
                else
                    log_warning "マージ機能が利用できません、スキップ: $file"
                fi
            else
                # 通常ファイルの場合は直接更新
                if rsync -a "$source_path" "$CLAUDE_DIR/"; then
                    log_success "更新完了: $file"
                    updated_count=$((updated_count + 1))
                else
                    log_error "更新失敗: $file"
                fi
            fi
        done
        
        log_info "更新されたファイル数: $updated_count"
    else
        # curlパイプ実行時: GitHubから直接ダウンロード
        local update_files=()
        while IFS= read -r file; do
            update_files+=("$file")
        done < <(get_project_files)
        
        local total_files=${#update_files[@]}
        local current=0
        local updated_count=0
        
        for file in "${update_files[@]}"; do
            current=$((current + 1))
            
            # カスタマイズファイルはスキップ
            if [[ ${#custom_files[@]} -gt 0 ]] && [[ " ${custom_files[*]} " =~ " ${file} " ]]; then
                log_warning "[$current/$total_files] スキップ (カスタマイズ済み): $file"
                continue
            fi
            
            log_info "[$current/$total_files] 更新中: $file"
            
            if [[ "$file" == "CLAUDE.md" ]] || [[ "$file" == "settings.json" ]]; then
                # 単一ファイルの場合
                local dest_path="$CLAUDE_DIR/$file"
                if download_from_github "$file" "$dest_path"; then
                    log_success "更新完了: $file"
                    ((updated_count++))
                else
                    log_error "更新失敗: $file"
                fi
            else
                # ディレクトリの場合
                if download_directory "$file"; then
                    log_success "ディレクトリ更新完了: $file"
                    ((updated_count++))
                else
                    log_warning "ディレクトリ更新失敗 (一部ファイルのみ): $file"
                fi
            fi
        done
        
        log_info "更新されたファイル数: $updated_count"
    fi
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

# 新しいバージョンを取得（Git tagから）
get_latest_version() {
    local latest_version="1.0.1"  # デフォルト値
    
    if [[ "$EXECUTION_MODE" == "local" ]] && command -v git >/dev/null 2>&1; then
        cd "$PROJECT_ROOT"
        # 最新のGitタグを取得
        local git_version=$(git describe --tags --abbrev=0 2>/dev/null)
        if [[ -n "$git_version" ]]; then
            latest_version="$git_version"
        fi
    fi
    
    echo "$latest_version"
}

# バージョン情報更新
update_version_info() {
    log_info "バージョン情報を更新しています..."
    
    local current_version=$(get_current_version)
    local new_version=$(get_latest_version)
    
    # バージョン比較機能を使用（利用可能な場合）
    if source_version_tools && command -v compare_versions >/dev/null 2>&1; then
        compare_versions "$current_version" "$new_version"
        local comparison_result=$?
        
        if [[ $comparison_result -eq 0 ]]; then
            log_info "バージョンに変更はありません: $current_version"
        elif [[ $comparison_result -eq 2 ]]; then
            log_info "バージョンアップ: $current_version → $new_version"
        fi
    fi
    
    # 既存のバージョンファイルから互換性情報を保持
    local compatibility="1.0.0"
    local features='["research", "automation", "templates", "workflow", "commands"]'
    local breaking_changes='[]'
    local migration_required="false"
    
    if [[ -f "$VERSION_FILE" ]] && command -v jq >/dev/null 2>&1; then
        compatibility=$(jq -r '.compatibility // "1.0.0"' "$VERSION_FILE")
        features=$(jq -c '.features // ["research", "automation", "templates", "workflow", "commands"]' "$VERSION_FILE")
        breaking_changes=$(jq -c '.breaking_changes // []' "$VERSION_FILE")
        migration_required=$(jq -r '.migration_required // false' "$VERSION_FILE")
    fi
    
    cat > "$VERSION_FILE" << EOF
{
  "version": "$new_version",
  "compatibility": "$compatibility",
  "last_updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "features": $features,
  "breaking_changes": $breaking_changes,
  "migration_required": $migration_required,
  "updater": "update.sh",
  "previous_version": "$current_version",
  "previous_backup": "$(cat "$CLAUDE_DIR/.last-backup" 2>/dev/null || echo "")",
  "description": "Updated via update.sh"
}
EOF
    
    log_success "バージョン情報を更新しました: $current_version → $new_version"
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
    log_header "🎉 Claude Dev Workflow の更新が完了しました！"
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
    
    log_header "🔄 Claude Dev Workflow 更新開始"
    echo
    
    # 実行環境の情報表示
    if [[ "$EXECUTION_MODE" == "curl" ]]; then
        log_info "実行環境: リモート (GitHub経由)"
        log_info "GitHubから最新ファイルを直接ダウンロードします"
        echo
    else
        log_info "実行環境: ローカル"
        log_info "Gitリポジトリから更新します"
        echo
    fi
    
    # 現在のバージョン表示
    log_info "現在のバージョン: $(get_current_version)"
    
    if [[ "$EXECUTION_MODE" == "local" ]]; then
        # ローカル実行時のみGit更新チェック
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
    else
        # curlパイプ実行時: シンプルな更新プロセス
        log_info "リモート実行では強制的に全ファイルを更新します"
        log_info "確認プロンプトをスキップして自動実行します"
        echo
        
        # バックアップ作成
        create_backup
        
        # カスタマイズファイル検出（最小限）
        local custom_files=()
        if [[ -f "$CUSTOM_FILES_LIST" ]]; then
            while IFS= read -r line; do
                if [[ -n "$line" && ! "$line" =~ ^# ]]; then
                    custom_files+=("$line")
                fi
            done < "$CUSTOM_FILES_LIST"
        fi
        
        # GitHubから直接更新
        if [[ ${#custom_files[@]} -gt 0 ]]; then
            update_files "${custom_files[*]}"
        else
            update_files ""
        fi
    fi
    
    # バージョン情報更新
    update_version_info
    
    # 更新後の互換性チェック
    if [[ -f "$CLAUDE_DIR/scripts/check-compatibility.sh" ]]; then
        log_info "更新後の互換性チェックを実行中..."
        if "$CLAUDE_DIR/scripts/check-compatibility.sh" --check; then
            log_success "互換性チェック完了"
        else
            log_warning "互換性チェックで問題が検出されました"
        fi
    fi
    
    # 完了レポート
    show_update_report
    
    log_success "更新が正常に完了しました"
}

# スクリプト実行
if [[ "${BASH_SOURCE[0]:-$0}" == "${0}" ]]; then
    main "$@"
fi