#!/bin/bash

# Version Management Test Script
# バージョン管理機能のテストスクリプト

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

# バージョンファイルの存在テスト
test_version_file_exists() {
    if [[ -f "$PROJECT_ROOT/.claude-version" ]]; then
        test_pass "バージョンファイルが存在する"
    else
        test_fail "バージョンファイルが存在しない"
    fi
}

# バージョンファイルのJSON形式テスト
test_version_file_format() {
    if command -v jq >/dev/null 2>&1; then
        if jq empty "$PROJECT_ROOT/.claude-version" 2>/dev/null; then
            test_pass "バージョンファイルのJSON形式が正しい"
        else
            test_fail "バージョンファイルのJSON形式が不正"
        fi
    else
        test_info "jqが見つからないため、JSON形式テストをスキップ"
    fi
}

# 必須フィールドの存在テスト
test_required_fields() {
    local required_fields=("version" "compatibility" "last_updated" "features")
    
    for field in "${required_fields[@]}"; do
        if command -v jq >/dev/null 2>&1; then
            local value=$(jq -r ".$field" "$PROJECT_ROOT/.claude-version" 2>/dev/null)
            if [[ "$value" != "null" && -n "$value" ]]; then
                test_pass "必須フィールド '$field' が存在する"
            else
                test_fail "必須フィールド '$field' が不足している"
            fi
        else
            if grep -q "\"$field\"" "$PROJECT_ROOT/.claude-version"; then
                test_pass "必須フィールド '$field' が存在する (grep確認)"
            else
                test_fail "必須フィールド '$field' が不足している (grep確認)"
            fi
        fi
    done
}

# version.shスクリプトの実行テスト
test_version_script() {
    if [[ -x "$PROJECT_ROOT/scripts/version.sh" ]]; then
        test_pass "version.sh スクリプトが実行可能"
        
        # バージョン表示テスト
        if "$PROJECT_ROOT/scripts/version.sh" --version >/dev/null 2>&1; then
            test_pass "バージョン情報の取得が成功"
        else
            test_fail "バージョン情報の取得が失敗"
        fi
        
        # 詳細情報表示テスト
        if "$PROJECT_ROOT/scripts/version.sh" --show >/dev/null 2>&1; then
            test_pass "詳細情報の表示が成功"
        else
            test_fail "詳細情報の表示が失敗"
        fi
        
        # 整合性チェックテスト
        if "$PROJECT_ROOT/scripts/version.sh" --check >/dev/null 2>&1; then
            test_pass "バージョンファイル整合性チェックが成功"
        else
            test_fail "バージョンファイル整合性チェックが失敗"
        fi
    else
        test_fail "version.sh スクリプトが実行できない"
    fi
}

# check-compatibility.shスクリプトの実行テスト
test_compatibility_script() {
    if [[ -x "$PROJECT_ROOT/scripts/check-compatibility.sh" ]]; then
        test_pass "check-compatibility.sh スクリプトが実行可能"
        
        # 互換性チェックテスト
        if "$PROJECT_ROOT/scripts/check-compatibility.sh" --check >/dev/null 2>&1; then
            test_pass "互換性チェックが成功"
        else
            test_fail "互換性チェックが失敗"
        fi
    else
        test_fail "check-compatibility.sh スクリプトが実行できない"
    fi
}

# バージョン比較機能のテスト
test_version_comparison() {
    # version.shを読み込んで比較機能をテスト
    if source "$PROJECT_ROOT/scripts/version.sh" 2>/dev/null; then
        # 同じバージョンの比較
        compare_versions "1.0.0" "1.0.0"
        if [[ $? -eq 0 ]]; then
            test_pass "バージョン比較: 同じバージョン"
        else
            test_fail "バージョン比較: 同じバージョンの判定が不正"
        fi
        
        # より新しいバージョンの比較
        compare_versions "1.0.0" "1.0.1"
        if [[ $? -eq 2 ]]; then
            test_pass "バージョン比較: 新しいバージョンの検出"
        else
            test_fail "バージョン比較: 新しいバージョンの判定が不正"
        fi
        
        # より古いバージョンの比較
        compare_versions "1.0.1" "1.0.0"
        if [[ $? -eq 1 ]]; then
            test_pass "バージョン比較: 古いバージョンの検出"
        else
            test_fail "バージョン比較: 古いバージョンの判定が不正"
        fi
    else
        test_fail "version.sh の読み込みに失敗"
    fi
}

# メイン実行
main() {
    echo "======================================"
    echo "  バージョン管理機能テスト"
    echo "======================================"
    echo ""
    
    test_info "テスト開始..."
    echo ""
    
    test_version_file_exists
    test_version_file_format
    test_required_fields
    test_version_script
    test_compatibility_script
    test_version_comparison
    
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