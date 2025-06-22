#!/bin/bash

#
# Claude Dev Workflow インストールスクリプト
# 
# 使用方法:
#   ./scripts/install.sh
#   curl -s <URL>/install.sh | bash
#
# 機能:
#   - ~/.claude/ ディレクトリに Claude Dev Workflow を設置
#   - 既存ファイルの自動バックアップ
#   - 権限チェックとエラーハンドリング
#   - 進捗表示とユーザーフィードバック
#

set -euo pipefail

# 設定
readonly CLAUDE_DIR="$HOME/.claude"
readonly BACKUP_PREFIX="$HOME/.claude.backup"
readonly TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
readonly GITHUB_REPO="https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main"

# 実行環境判定（ローカル実行 vs curlパイプ実行）
if [[ "${0}" =~ ^/dev/fd/ ]] || [[ "${0}" == "bash" ]] || [[ -z "${BASH_SOURCE[0]:-}" ]]; then
    # curlパイプ実行（stdin経由）
    readonly EXECUTION_MODE="curl"
    readonly SCRIPT_DIR=""
    readonly PROJECT_ROOT=""
else
    # ローカル実行
    readonly EXECUTION_MODE="local"
    readonly SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
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
    log_warning "インストールが中断されました"
    exit 130
}
trap cleanup INT

# 権限チェック
check_permissions() {
    log_info "権限をチェックしています..."
    
    # ホームディレクトリの書き込み権限チェック
    if [[ ! -w "$HOME" ]]; then
        error_exit "ホームディレクトリ ($HOME) への書き込み権限がありません"
    fi
    
    # 必要なコマンドの存在チェック
    local required_commands=("rsync" "cp" "mkdir" "date")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            error_exit "必要なコマンドが見つかりません: $cmd"
        fi
    done
    
    log_success "権限チェック完了"
}

# 既存インストールの検出とバックアップ
backup_existing() {
    if [[ -d "$CLAUDE_DIR" ]]; then
        log_warning "既存の Claude Dev Workflow が検出されました"
        log_info "バックアップを作成しています..."
        
        local backup_path="${BACKUP_PREFIX}.${TIMESTAMP}"
        
        # バックアップ作成
        if cp -r "$CLAUDE_DIR" "$backup_path"; then
            log_success "バックアップ完了: $backup_path"
            
            # 既存ディレクトリを削除
            rm -rf "$CLAUDE_DIR"
            log_info "既存ディレクトリを削除しました"
        else
            error_exit "バックアップの作成に失敗しました"
        fi
    else
        log_info "新規インストールです"
    fi
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

# ディレクトリを再帰的にダウンロード
download_directory() {
    local dir_name="$1"
    local dest_dir="$CLAUDE_DIR/$dir_name"
    
    # ディレクトリ作成
    mkdir -p "$dest_dir"
    
    # 各ディレクトリの主要ファイルを個別にダウンロード
    case "$dir_name" in
        "commands")
            local files=("research.md" "analyze-codebase.md" "competitor-analysis.md" "tech-research.md" "pr-review.md")
            ;;
        "requirements")
            local files=("interview-template.md" "document-structure.md")
            ;;
        "workflow")
            local files=("development-flow.md" "git-workflow.md" "tdd-process.md" "research-process.md" "analysis-methods.md")
            ;;
        "templates")
            local files=("preparation-sheet.md" "automation-setup.md" "issue-template.md" "pr-template.md" "commit-message.md" "research-template.md" "analysis-report.md")
            ;;
        "docs")
            local files=("README.md")
            ;;
        *)
            log_warning "未知のディレクトリ: $dir_name"
            return 1
            ;;
    esac
    
    for file in "${files[@]}"; do
        local file_path="${dir_name}/${file}"
        local dest_file_path="${dest_dir}/${file}"
        
        if download_from_github "$file_path" "$dest_file_path"; then
            log_success "ダウンロード完了: $file_path"
        else
            log_warning "ダウンロード失敗 (スキップ): $file_path"
        fi
    done
}

# ファイルコピー（ローカル実行）またはダウンロード（curl実行）
copy_files() {
    log_info "ファイルを取得しています..."
    
    # ディレクトリ作成
    if ! mkdir -p "$CLAUDE_DIR"; then
        error_exit "ディレクトリの作成に失敗しました: $CLAUDE_DIR"
    fi
    
    # コピー対象の確認
    local source_files=(
        "CLAUDE.md"
        "commands"
        "requirements" 
        "workflow"
        "templates"
        "docs"
    )
    
    local total_files=${#source_files[@]}
    local current=0
    
    if [[ "$EXECUTION_MODE" == "local" ]]; then
        # ローカル実行時
        for file in "${source_files[@]}"; do
            current=$((current + 1))
            local source_path="$PROJECT_ROOT/$file"
            
            if [[ -e "$source_path" ]]; then
                log_info "[$current/$total_files] コピー中: $file"
                
                if rsync -a "$source_path" "$CLAUDE_DIR/"; then
                    log_success "コピー完了: $file"
                else
                    error_exit "ファイルのコピーに失敗しました: $file"
                fi
            else
                log_warning "ファイルが見つかりません (スキップ): $file"
            fi
        done
    else
        # curl実行時
        for file in "${source_files[@]}"; do
            current=$((current + 1))
            log_info "[$current/$total_files] ダウンロード中: $file"
            
            if [[ "$file" == "CLAUDE.md" ]]; then
                # 単一ファイルの場合
                local dest_path="$CLAUDE_DIR/$file"
                if download_from_github "$file" "$dest_path"; then
                    log_success "ダウンロード完了: $file"
                else
                    error_exit "ファイルのダウンロードに失敗しました: $file"
                fi
            else
                # ディレクトリの場合
                if download_directory "$file"; then
                    log_success "ディレクトリダウンロード完了: $file"
                else
                    log_warning "ディレクトリダウンロード失敗 (一部ファイルのみ): $file"
                fi
            fi
        done
    fi
}

# インストール検証
verify_installation() {
    log_info "インストールを検証しています..."
    
    # 必須ファイルの存在確認
    local required_files=(
        "$CLAUDE_DIR/CLAUDE.md"
        "$CLAUDE_DIR/commands"
        "$CLAUDE_DIR/templates"
        "$CLAUDE_DIR/workflow"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -e "$file" ]]; then
            error_exit "必須ファイルが見つかりません: $file"
        fi
    done
    
    # 権限確認
    if [[ ! -r "$CLAUDE_DIR/CLAUDE.md" ]]; then
        error_exit "CLAUDE.md が読み取り不可です"
    fi
    
    log_success "インストール検証完了"
}

# 使用方法の表示
show_usage() {
    echo
    log_header "🎉 Claude Dev Workflow のセットアップが完了しました！"
    echo
    echo "📍 インストール場所: $CLAUDE_DIR"
    echo
    echo "🚀 次の手順:"
    echo "1. Claude Code で以下のコマンドを実行してください:"
    echo "   ${BOLD}~/.claude/CLAUDE.md の内容を読み込んで、今後このガイドラインに従って動作してください${NC}"
    echo
    echo "2. 動作確認:"
    echo "   ${BOLD}/start-project テストプロジェクト${NC}"
    echo
    echo "📚 利用可能なコマンド:"
    echo "   /start-project, /implement, /auto-review, /research など"
    echo
    echo "📖 詳細な使用方法: ~/.claude/README.md"
    echo
    
    if [[ -f "${BACKUP_PREFIX}.${TIMESTAMP}" ]]; then
        echo "💾 バックアップ: ${BACKUP_PREFIX}.${TIMESTAMP}"
        echo
    fi
}

# バージョン情報作成
create_version_info() {
    local version_file="$CLAUDE_DIR/.claude-version"
    
    cat > "$version_file" << EOF
{
  "version": "1.0.0",
  "installed": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "installer": "install.sh",
  "features": [
    "research",
    "automation", 
    "supabase",
    "static-analysis"
  ]
}
EOF
    
    log_success "バージョン情報を作成しました"
}

# メイン実行
main() {
    log_header "🚀 Claude Dev Workflow セットアップ開始"
    echo
    
    # 実行環境の情報表示
    log_info "実行環境: $EXECUTION_MODE"
    if [[ "$EXECUTION_MODE" == "curl" ]]; then
        log_info "GitHubからファイルをダウンロードします"
    else
        log_info "ローカルファイルからコピーします"
    fi
    echo
    
    # 事前チェック
    check_permissions
    
    # 既存インストールの処理
    backup_existing
    
    # ファイルコピー
    copy_files
    
    # バージョン情報作成
    create_version_info
    
    # インストール検証
    verify_installation
    
    # 使用方法表示
    show_usage
    
    log_success "セットアップが正常に完了しました"
}

# スクリプト実行
main "$@"