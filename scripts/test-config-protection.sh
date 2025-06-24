#!/bin/bash

# Configuration Protection Test Script
# 設定カスタマイズ保護機能のテストスクリプト

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 色定義
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# テスト結果カウンタ
TESTS_PASSED=0
TESTS_FAILED=0

# テストログ関数
test_pass() {
    echo -e "${GREEN}✅ PASS${NC}: $1"
    ((TESTS_PASSED++))
}

test_fail() {
    echo -e "${RED}❌ FAIL${NC}: $1"
    ((TESTS_FAILED++))
}

test_info() {
    echo -e "${YELLOW}ℹ️  INFO${NC}: $1"
}

# テスト環境のセットアップ
setup_test_environment() {
    local test_dir="$1"
    mkdir -p "$test_dir"
    
    # テスト用の設定ファイルを作成
    cat > "$test_dir/test-config.md" << 'EOF'
# Test Configuration

## Standard Section
This is a standard section that should be updated.

## Custom Section
This is a custom section added by user.

## Shared Section
This section exists in both versions but with different content.
Original content here.
EOF
    
    cat > "$test_dir/test-config-new.md" << 'EOF'
# Test Configuration

## Standard Section
This is an updated standard section with new content.

## New Standard Section
This is a completely new section from the update.

## Shared Section
This section exists in both versions but with different content.
Updated content here.
EOF
    
    # JSON設定ファイルのテスト
    cat > "$test_dir/test-settings.json" << 'EOF'
{
  "standard_setting": "original_value",
  "custom_setting": "user_added_value",
  "shared_setting": "original_shared_value"
}
EOF
    
    cat > "$test_dir/test-settings-new.json" << 'EOF'
{
  "standard_setting": "updated_value",
  "new_standard_setting": "new_value",
  "shared_setting": "updated_shared_value"
}
EOF
}

# ファイルハッシュ計算のテスト
test_file_hash_calculation() {
    local test_dir=$(mktemp -d)
    setup_test_environment "$test_dir"
    
    # config-protection.shが存在するかチェック
    if [[ ! -f "$SCRIPT_DIR/config-protection.sh" ]]; then
        test_fail "config-protection.sh が見つかりません"
        return 1
    fi
    
    # スクリプトを読み込み
    source "$SCRIPT_DIR/config-protection.sh"
    
    # ハッシュ計算テスト
    local hash1=$(calculate_file_hash "$test_dir/test-config.md")
    local hash2=$(calculate_file_hash "$test_dir/test-config.md")
    
    if [[ "$hash1" == "$hash2" && -n "$hash1" ]]; then
        test_pass "ファイルハッシュ計算の一貫性"
    else
        test_fail "ファイルハッシュ計算の一貫性"
    fi
    
    # 異なるファイルで異なるハッシュが生成されることを確認
    local hash3=$(calculate_file_hash "$test_dir/test-config-new.md")
    
    if [[ "$hash1" != "$hash3" ]]; then
        test_pass "異なるファイルで異なるハッシュ生成"
    else
        test_fail "異なるファイルで異なるハッシュ生成"
    fi
    
    rm -rf "$test_dir"
}

# カスタマイズ検出のテスト
test_customization_detection() {
    local test_dir=$(mktemp -d)
    setup_test_environment "$test_dir"
    
    if [[ ! -f "$SCRIPT_DIR/config-protection.sh" ]]; then
        test_fail "config-protection.sh が見つかりません"
        return 1
    fi
    
    source "$SCRIPT_DIR/config-protection.sh"
    
    # 一時的な設定ファイルを使用
    local temp_customization_file="$test_dir/.customizations.json"
    CUSTOMIZATION_FILE="$temp_customization_file"
    
    # カスタマイズファイルの初期化
    init_customization_file
    
    if [[ -f "$temp_customization_file" ]]; then
        test_pass "カスタマイズファイルの初期化"
    else
        test_fail "カスタマイズファイルの初期化"
    fi
    
    # カスタマイズの記録
    record_customization "$test_dir/test-config.md" "test-config.md" "user_modified" "test_modification"
    
    # カスタマイズが記録されているかチェック
    if command -v jq >/dev/null 2>&1; then
        local customizations=$(jq '.customizations | length' "$temp_customization_file")
        if [[ "$customizations" -gt 0 ]]; then
            test_pass "カスタマイズの記録"
        else
            test_fail "カスタマイズの記録"
        fi
    else
        test_info "jqが利用できないため、カスタマイズ記録テストをスキップ"
    fi
    
    rm -rf "$test_dir"
}

# Markdownマージのテスト
test_markdown_merge() {
    local test_dir=$(mktemp -d)
    setup_test_environment "$test_dir"
    
    if [[ ! -f "$SCRIPT_DIR/config-merge.sh" ]]; then
        test_fail "config-merge.sh が見つかりません"
        return 1
    fi
    
    local merged_file="$test_dir/merged.md"
    
    # Markdownマージの実行（非対話的）
    if "$SCRIPT_DIR/config-merge.sh" --smart "$test_dir/test-config.md" "$test_dir/test-config-new.md" "$merged_file" 2>/dev/null; then
        test_pass "Markdownスマートマージの実行"
        
        # マージ結果の確認
        if [[ -f "$merged_file" ]] && [[ -s "$merged_file" ]]; then
            test_pass "マージ結果ファイルの生成"
            
            # カスタムセクションが保持されているかチェック
            if grep -q "Custom Section" "$merged_file"; then
                test_pass "カスタムセクションの保持"
            else
                test_fail "カスタムセクションの保持"
            fi
            
            # 新しいセクションが追加されているかチェック
            if grep -q "New Standard Section" "$merged_file"; then
                test_pass "新規セクションの追加"
            else
                test_fail "新規セクションの追加"
            fi
        else
            test_fail "マージ結果ファイルの生成"
        fi
    else
        test_fail "Markdownスマートマージの実行"
    fi
    
    rm -rf "$test_dir"
}

# JSONマージのテスト
test_json_merge() {
    local test_dir=$(mktemp -d)
    setup_test_environment "$test_dir"
    
    if [[ ! -f "$SCRIPT_DIR/config-merge.sh" ]]; then
        test_fail "config-merge.sh が見つかりません"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        test_info "jqが利用できないため、JSONマージテストをスキップ"
        rm -rf "$test_dir"
        return 0
    fi
    
    local merged_file="$test_dir/merged.json"
    
    # JSONマージの実行
    if "$SCRIPT_DIR/config-merge.sh" --json "$test_dir/test-settings.json" "$test_dir/test-settings-new.json" "$merged_file" 2>/dev/null; then
        test_pass "JSONマージの実行"
        
        # マージ結果の確認
        if [[ -f "$merged_file" ]] && jq empty "$merged_file" 2>/dev/null; then
            test_pass "有効なJSONファイルの生成"
            
            # カスタム設定が保持されているかチェック
            local custom_value=$(jq -r '.custom_setting' "$merged_file")
            if [[ "$custom_value" == "user_added_value" ]]; then
                test_pass "カスタム設定の保持"
            else
                test_fail "カスタム設定の保持"
            fi
            
            # 新しい設定が追加されているかチェック
            local new_value=$(jq -r '.new_standard_setting' "$merged_file")
            if [[ "$new_value" == "new_value" ]]; then
                test_pass "新規設定の追加"
            else
                test_fail "新規設定の追加"
            fi
        else
            test_fail "有効なJSONファイルの生成"
        fi
    else
        test_fail "JSONマージの実行"
    fi
    
    rm -rf "$test_dir"
}

# 履歴管理のテスト
test_history_management() {
    local test_dir=$(mktemp -d)
    
    if [[ ! -f "$SCRIPT_DIR/customization-history.sh" ]]; then
        test_fail "customization-history.sh が見つかりません"
        return 1
    fi
    
    # 一時的な履歴ファイルを使用
    local temp_history_file="$test_dir/.customization-history.json"
    
    # 履歴エントリの追加テスト
    if HISTORY_FILE="$temp_history_file" "$SCRIPT_DIR/customization-history.sh" --add "test-file.md" "test_action" "Test description" 2>/dev/null; then
        test_pass "履歴エントリの追加"
        
        if [[ -f "$temp_history_file" ]]; then
            test_pass "履歴ファイルの生成"
            
            # 履歴エントリが正しく追加されているかチェック
            if command -v jq >/dev/null 2>&1; then
                local entry_count=$(jq '.entries | length' "$temp_history_file")
                if [[ "$entry_count" -gt 0 ]]; then
                    test_pass "履歴エントリの記録"
                else
                    test_fail "履歴エントリの記録"
                fi
            else
                test_info "jqが利用できないため、履歴記録詳細テストをスキップ"
            fi
        else
            test_fail "履歴ファイルの生成"
        fi
    else
        test_fail "履歴エントリの追加"
    fi
    
    rm -rf "$test_dir"
}

# 競合解決のテスト（自動化された部分のみ）
test_conflict_resolution() {
    local test_dir=$(mktemp -d)
    setup_test_environment "$test_dir"
    
    if [[ ! -f "$SCRIPT_DIR/config-protection.sh" ]]; then
        test_fail "config-protection.sh が見つかりません"
        return 1
    fi
    
    source "$SCRIPT_DIR/config-protection.sh"
    
    # ベースファイル、現在ファイル、新ファイルを作成
    cat > "$test_dir/base.txt" << 'EOF'
line1
line2
line3
EOF
    
    cat > "$test_dir/current.txt" << 'EOF'
line1
modified_line2
line3
custom_line4
EOF
    
    cat > "$test_dir/new.txt" << 'EOF'
line1
updated_line2
line3
new_line5
EOF
    
    local output_file="$test_dir/merged.txt"
    
    # 三方向マージのテスト
    if perform_three_way_merge "$test_dir/base.txt" "$test_dir/current.txt" "$test_dir/new.txt" "$output_file" 2>/dev/null; then
        test_pass "三方向マージの実行（競合なし部分）"
        
        if [[ -f "$output_file" ]]; then
            test_pass "マージ結果ファイルの生成"
        else
            test_fail "マージ結果ファイルの生成"
        fi
    else
        # 競合が発生した場合も正常（手動解決が必要）
        test_info "三方向マージで競合発生（期待される動作）"
        
        if [[ -f "$output_file" ]]; then
            test_pass "競合マーカー付きファイルの生成"
        else
            test_fail "競合マーカー付きファイルの生成"
        fi
    fi
    
    rm -rf "$test_dir"
}

# 統合テスト
test_integration() {
    local test_dir=$(mktemp -d)
    setup_test_environment "$test_dir"
    
    # 一時的な設定ディレクトリ
    local temp_claude_dir="$test_dir/.claude"
    mkdir -p "$temp_claude_dir/scripts"
    
    # スクリプトをコピー
    cp "$SCRIPT_DIR/config-protection.sh" "$temp_claude_dir/scripts/"
    cp "$SCRIPT_DIR/config-merge.sh" "$temp_claude_dir/scripts/"
    cp "$SCRIPT_DIR/customization-history.sh" "$temp_claude_dir/scripts/"
    
    # 環境変数を一時的に変更
    local original_claude_dir="$CLAUDE_DIR"
    CLAUDE_DIR="$temp_claude_dir"
    
    # 統合的なワークフローテスト
    if source "$temp_claude_dir/scripts/config-protection.sh"; then
        # カスタマイズ管理の初期化
        init_customization_file 2>/dev/null
        
        # カスタマイズの記録
        record_customization "$test_dir/test-config.md" "test-config.md" "user_modified" "integration_test" 2>/dev/null
        
        # マージ処理
        if merge_configuration_file "$test_dir/test-config.md" "$test_dir/test-config-new.md" "test-config.md" 2>/dev/null; then
            test_pass "統合ワークフローの実行"
        else
            test_fail "統合ワークフローの実行"
        fi
    else
        test_fail "設定保護機能の読み込み"
    fi
    
    # 環境変数を復元
    CLAUDE_DIR="$original_claude_dir"
    
    rm -rf "$test_dir"
}

# パフォーマンステスト
test_performance() {
    local test_dir=$(mktemp -d)
    
    # 大きなファイルを作成
    local large_file="$test_dir/large-config.md"
    for i in {1..1000}; do
        echo "## Section $i" >> "$large_file"
        echo "Content for section $i" >> "$large_file"
        echo "" >> "$large_file"
    done
    
    # 新バージョンファイル（少し変更）
    cp "$large_file" "$test_dir/large-config-new.md"
    echo "## New Section 1001" >> "$test_dir/large-config-new.md"
    echo "New content" >> "$test_dir/large-config-new.md"
    
    if [[ ! -f "$SCRIPT_DIR/config-merge.sh" ]]; then
        test_fail "config-merge.sh が見つかりません"
        return 1
    fi
    
    local start_time=$(date +%s)
    
    # 大きなファイルのマージテスト
    if "$SCRIPT_DIR/config-merge.sh" --smart "$large_file" "$test_dir/large-config-new.md" "$test_dir/merged-large.md" 2>/dev/null; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        if [[ $duration -lt 10 ]]; then
            test_pass "大きなファイルのマージパフォーマンス（${duration}秒）"
        else
            test_fail "大きなファイルのマージパフォーマンス（${duration}秒、10秒以上）"
        fi
    else
        test_fail "大きなファイルのマージ実行"
    fi
    
    rm -rf "$test_dir"
}

# メイン実行
main() {
    echo "======================================"
    echo "  設定カスタマイズ保護機能テスト"
    echo "======================================"
    echo ""
    
    test_info "テスト開始..."
    echo ""
    
    test_file_hash_calculation
    test_customization_detection
    test_markdown_merge
    test_json_merge
    test_history_management
    test_conflict_resolution
    test_integration
    test_performance
    
    echo ""
    echo "======================================"
    echo "  テスト結果"
    echo "======================================"
    echo ""
    echo "合格: $TESTS_PASSED"
    echo "失敗: $TESTS_FAILED"
    echo "合計: $((TESTS_PASSED + TESTS_FAILED))"
    echo ""
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}✅ 全テストが合格しました！${NC}"
        return 0
    else
        echo -e "${RED}❌ $TESTS_FAILED 個のテストが失敗しました${NC}"
        return 1
    fi
}

# スクリプトが直接実行された場合
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi