# 高度な使用例

Claude Dev Workflow スクリプトの高度な活用方法とカスタマイズ例を紹介します。

## 🚀 高度な活用シナリオ

### 1. 企業環境での展開

**状況**: チーム全体でClaude Dev Workflowを標準化

#### チーム用カスタマイズ

```bash
# 1. チーム用リポジトリの作成
git clone https://github.com/yourcompany/claude-dev-workflow.git
cd claude-dev-workflow

# 2. 会社固有の設定をカスタマイズ
# CLAUDE.md に企業のコーディング規約を追加
# templates/ に会社固有のテンプレートを追加
# workflow/ にチーム固有のプロセスを定義

# 3. 社内用インストールスクリプト作成
cat > scripts/company-install.sh << 'EOF'
#!/bin/bash
# 企業内専用インストールスクリプト

# プロキシ設定
export http_proxy="http://proxy.company.com:8080"
export https_proxy="http://proxy.company.com:8080"

# 社内GitLabからインストール
GITLAB_REPO="https://gitlab.company.com/devtools/claude-dev-workflow"
curl -H "Private-Token: ${GITLAB_TOKEN}" -s "${GITLAB_REPO}/-/raw/main/scripts/install.sh" | bash

# 会社固有の後処理
source ~/.claude/scripts/company-postinstall.sh
EOF

# 4. チームメンバーへの配布
# Slackやメールで以下を共有:
# "curl -s https://gitlab.company.com/devtools/claude-dev-workflow/-/raw/main/scripts/company-install.sh | bash"
```

#### セキュアな設定管理

```bash
# 1. 機密設定の暗号化
# 重要な設定ファイルを暗号化して管理
gpg --symmetric --cipher-algo AES256 ~/.claude/CLAUDE.md
mv ~/.claude/CLAUDE.md.gpg ~/.claude-secure/

# 2. 復号化スクリプト
cat > ~/.claude/scripts/secure-setup.sh << 'EOF'
#!/bin/bash
# セキュア設定の復号化・適用

read -s -p "暗号化パスワードを入力: " password
echo

# 設定ファイルを復号化
echo "$password" | gpg --batch --yes --passphrase-fd 0 --decrypt ~/.claude-secure/CLAUDE.md.gpg > ~/.claude/CLAUDE.md

if [[ $? -eq 0 ]]; then
    echo "✅ セキュア設定の適用完了"
else
    echo "❌ 復号化に失敗しました"
    exit 1
fi
EOF

# 3. 定期的なセキュリティローテーション
# crontabで月次で暗号化パスワードの更新を促す
```

### 2. CI/CD統合

#### GitHub Actions統合

```yaml
# .github/workflows/claude-dev-workflow.yml
name: Claude Dev Workflow Sync

on:
  schedule:
    - cron: '0 2 * * 1'  # 毎週月曜日 午前2時
  workflow_dispatch:

jobs:
  sync-workflow:
    runs-on: ubuntu-latest
    steps:
      - name: Setup Claude Dev Workflow
        run: |
          curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/install.sh | bash
      
      - name: Validate Installation
        run: |
          ~/.claude/scripts/check-compatibility.sh --check
          ~/.claude/scripts/version.sh --info
      
      - name: Create Backup
        run: |
          ~/.claude/scripts/backup.sh backup
      
      - name: Upload Backup to Artifacts
        uses: actions/upload-artifact@v3
        with:
          name: claude-workflow-backup
          path: ~/.claude-backups/*.tar.gz
          retention-days: 30
      
      - name: Slack Notification
        if: failure()
        uses: 8398a7/action-slack@v3
        with:
          status: failure
          text: "Claude Dev Workflow sync failed"
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

#### Docker環境対応

```dockerfile
# Dockerfile.claude-dev
FROM ubuntu:22.04

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    rsync \
    tar \
    && rm -rf /var/lib/apt/lists/*

# Claude Dev Workflowユーザー作成
RUN useradd -m -s /bin/bash claude

# ユーザー切り替え
USER claude
WORKDIR /home/claude

# Claude Dev Workflowインストール
RUN curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/install.sh | bash

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD ~/.claude/scripts/check-compatibility.sh --check || exit 1

# エントリーポイント
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
```

```bash
# docker-entrypoint.sh
#!/bin/bash
set -e

# Claude Dev Workflowの健全性チェック
echo "🔍 Claude Dev Workflow ヘルスチェック..."
if ~/.claude/scripts/check-compatibility.sh --check; then
    echo "✅ ヘルスチェック完了"
else
    echo "❌ ヘルスチェック失敗"
    exit 1
fi

# 最新版確認・更新
echo "🔄 最新版チェック..."
~/.claude/scripts/update.sh

# メインプロセス実行
exec "$@"
```

### 3. 高度なカスタマイズ

#### プロジェクト自動検出システム

```bash
# scripts/smart-setup.sh
#!/bin/bash
# プロジェクトタイプを自動検出して適切な設定を適用

detect_project_type() {
    local project_dir="$1"
    
    if [[ -f "$project_dir/package.json" ]]; then
        if grep -q "next" "$project_dir/package.json"; then
            echo "nextjs"
        elif grep -q "react" "$project_dir/package.json"; then
            echo "react"
        elif grep -q "vue" "$project_dir/package.json"; then
            echo "vue"
        else
            echo "nodejs"
        fi
    elif [[ -f "$project_dir/requirements.txt" ]] || [[ -f "$project_dir/pyproject.toml" ]]; then
        if [[ -f "$project_dir/manage.py" ]]; then
            echo "django"
        elif grep -q "fastapi\|flask" "$project_dir/requirements.txt" 2>/dev/null; then
            echo "fastapi"
        else
            echo "python"
        fi
    elif [[ -f "$project_dir/go.mod" ]]; then
        echo "golang"
    elif [[ -f "$project_dir/Cargo.toml" ]]; then
        echo "rust"
    else
        echo "unknown"
    fi
}

apply_project_config() {
    local project_type="$1"
    local config_dir="$HOME/.claude/configs"
    
    case "$project_type" in
        "nextjs")
            echo "📱 Next.js プロジェクト用設定を適用"
            cp "$config_dir/nextjs-CLAUDE.md" ~/.claude/CLAUDE.md
            cp "$config_dir/nextjs-workflow/"* ~/.claude/workflow/
            ;;
        "django")
            echo "🐍 Django プロジェクト用設定を適用"
            cp "$config_dir/django-CLAUDE.md" ~/.claude/CLAUDE.md
            cp "$config_dir/django-templates/"* ~/.claude/templates/
            ;;
        "golang")
            echo "🐹 Go プロジェクト用設定を適用"
            cp "$config_dir/golang-CLAUDE.md" ~/.claude/CLAUDE.md
            ;;
        *)
            echo "❓ 汎用設定を維持"
            ;;
    esac
}

# メイン処理
main() {
    local current_dir="${1:-$(pwd)}"
    
    echo "🔍 プロジェクトタイプを検出中: $current_dir"
    local project_type=$(detect_project_type "$current_dir")
    
    echo "📋 検出結果: $project_type"
    apply_project_config "$project_type"
    
    # カスタマイズ履歴に記録
    ~/.claude/scripts/customization-history.sh --add ~/.claude/CLAUDE.md "auto_detect" "プロジェクトタイプ自動検出: $project_type"
    
    echo "✅ プロジェクト用設定の適用完了"
}

main "$@"
```

#### 多環境同期システム

```bash
# scripts/multi-env-sync.sh
#!/bin/bash
# 複数環境間でのClaude Dev Workflow同期

# 設定ファイル: ~/.claude-sync-config.json
# {
#   "environments": {
#     "dev": {
#       "host": "dev-server.company.com",
#       "user": "developer",
#       "ssh_key": "~/.ssh/dev-key"
#     },
#     "staging": {
#       "host": "staging-server.company.com", 
#       "user": "deploy",
#       "ssh_key": "~/.ssh/staging-key"
#     },
#     "prod": {
#       "host": "prod-server.company.com",
#       "user": "deploy",
#       "ssh_key": "~/.ssh/prod-key"
#     }
#   }
# }

sync_to_environment() {
    local env_name="$1"
    local config_file="$HOME/.claude-sync-config.json"
    
    if [[ ! -f "$config_file" ]]; then
        echo "❌ 設定ファイルが見つかりません: $config_file"
        return 1
    fi
    
    # jqで設定を読み取り
    local host=$(jq -r ".environments.${env_name}.host" "$config_file")
    local user=$(jq -r ".environments.${env_name}.user" "$config_file")
    local ssh_key=$(jq -r ".environments.${env_name}.ssh_key" "$config_file")
    
    if [[ "$host" == "null" ]]; then
        echo "❌ 環境 '$env_name' が見つかりません"
        return 1
    fi
    
    echo "🔄 環境 '$env_name' に同期中..."
    
    # バックアップ作成
    echo "📦 ローカルバックアップ作成中..."
    ~/.claude/scripts/backup.sh backup
    
    local latest_backup=$(ls -t ~/.claude-backups/*.tar.gz | head -1)
    
    # リモート環境に転送
    echo "🚀 $host に転送中..."
    scp -i "$ssh_key" "$latest_backup" "${user}@${host}:~/claude-sync-backup.tar.gz"
    
    # リモートで復元実行
    echo "📥 リモート環境で復元中..."
    ssh -i "$ssh_key" "${user}@${host}" << 'EOF'
        # バックアップディレクトリ作成
        mkdir -p ~/.claude-backups
        mv ~/claude-sync-backup.tar.gz ~/.claude-backups/
        
        # Claude Dev Workflowインストール（未インストールの場合）
        if [[ ! -d ~/.claude ]]; then
            curl -s https://raw.githubusercontent.com/Yuki-Sakaguchi/claude-dev-workflow/main/scripts/install.sh | bash
        fi
        
        # 復元実行
        ~/.claude/scripts/backup.sh restore 1
        
        # 動作確認
        ~/.claude/scripts/check-compatibility.sh --check
EOF
    
    if [[ $? -eq 0 ]]; then
        echo "✅ 環境 '$env_name' への同期完了"
    else
        echo "❌ 環境 '$env_name' への同期失敗"
        return 1
    fi
}

# 全環境への一括同期
sync_all_environments() {
    local config_file="$HOME/.claude-sync-config.json"
    local environments=$(jq -r '.environments | keys[]' "$config_file")
    
    echo "🌐 全環境への同期を開始..."
    
    for env in $environments; do
        echo ""
        echo "--- 環境: $env ---"
        sync_to_environment "$env"
    done
    
    echo ""
    echo "🎉 全環境への同期完了"
}

# メイン処理
case "${1:-all}" in
    "all")
        sync_all_environments
        ;;
    *)
        sync_to_environment "$1"
        ;;
esac
```

### 4. モニタリング・アラート

#### ヘルスモニタリングシステム

```bash
# scripts/health-monitor.sh
#!/bin/bash
# Claude Dev Workflowの健全性を定期監視

# 設定
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
EMAIL_TO="${EMAIL_TO:-admin@company.com}"
LOG_FILE="$HOME/.claude/logs/health-monitor.log"

# ログディレクトリ作成
mkdir -p "$(dirname "$LOG_FILE")"

# ログ関数
log_with_timestamp() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Slack通知
send_slack_notification() {
    local message="$1"
    local color="${2:-danger}"
    
    if [[ -n "$SLACK_WEBHOOK_URL" ]]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"attachments\":[{\"color\":\"$color\",\"text\":\"$message\"}]}" \
            "$SLACK_WEBHOOK_URL"
    fi
}

# メール通知
send_email_notification() {
    local subject="$1"
    local body="$2"
    
    if command -v mail >/dev/null 2>&1; then
        echo "$body" | mail -s "$subject" "$EMAIL_TO"
    fi
}

# 健全性チェック関数群
check_claude_directory() {
    if [[ ! -d ~/.claude ]]; then
        return 1
    fi
    
    local required_files=(
        "~/.claude/CLAUDE.md"
        "~/.claude/.claude-version"
        "~/.claude/scripts/backup.sh"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            echo "Missing file: $file"
            return 1
        fi
    done
    
    return 0
}

check_script_permissions() {
    local script_errors=0
    
    for script in ~/.claude/scripts/*.sh; do
        if [[ ! -x "$script" ]]; then
            echo "No execute permission: $script"
            script_errors=$((script_errors + 1))
        fi
    done
    
    return $script_errors
}

check_backup_integrity() {
    local backup_errors=0
    
    for backup in ~/.claude-backups/*.tar.gz; do
        if [[ -f "$backup" ]]; then
            if ! tar -tzf "$backup" >/dev/null 2>&1; then
                echo "Corrupted backup: $backup"
                backup_errors=$((backup_errors + 1))
            fi
        fi
    done
    
    return $backup_errors
}

check_disk_space() {
    local available_space=$(df ~ | tail -1 | awk '{print $4}')
    local threshold=1048576  # 1GB in KB
    
    if [[ $available_space -lt $threshold ]]; then
        echo "Low disk space: ${available_space}KB available"
        return 1
    fi
    
    return 0
}

check_version_staleness() {
    local version_file="$HOME/.claude/.claude-version"
    
    if [[ -f "$version_file" ]]; then
        local last_updated=$(jq -r '.last_updated' "$version_file" 2>/dev/null)
        
        if [[ "$last_updated" != "null" && -n "$last_updated" ]]; then
            local last_epoch=$(date -d "$last_updated" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$last_updated" +%s 2>/dev/null)
            local current_epoch=$(date +%s)
            local days_old=$(( (current_epoch - last_epoch) / 86400 ))
            
            if [[ $days_old -gt 30 ]]; then
                echo "Version is $days_old days old"
                return 1
            fi
        fi
    fi
    
    return 0
}

# メイン健全性チェック
run_health_checks() {
    local errors=0
    local warnings=0
    local error_messages=()
    local warning_messages=()
    
    log_with_timestamp "健全性チェック開始"
    
    # 必須ディレクトリ・ファイルチェック
    if ! check_claude_directory; then
        error_messages+=("Claude Dev Workflowディレクトリ/ファイルに問題があります")
        errors=$((errors + 1))
    fi
    
    # スクリプト権限チェック
    local perm_errors
    if ! perm_errors=$(check_script_permissions); then
        warning_messages+=("スクリプトの実行権限に問題があります: $perm_errors個のファイル")
        warnings=$((warnings + 1))
    fi
    
    # バックアップ整合性チェック
    local backup_errors
    if ! backup_errors=$(check_backup_integrity); then
        warning_messages+=("バックアップファイルに破損があります: $backup_errors個のファイル")
        warnings=$((warnings + 1))
    fi
    
    # ディスク容量チェック
    local disk_message
    if ! disk_message=$(check_disk_space); then
        warning_messages+=("$disk_message")
        warnings=$((warnings + 1))
    fi
    
    # バージョン古さチェック
    local version_message
    if ! version_message=$(check_version_staleness); then
        warning_messages+=("$version_message")
        warnings=$((warnings + 1))
    fi
    
    # 結果レポート
    local status="OK"
    local color="good"
    local report="Claude Dev Workflow 健全性チェック結果\n"
    report+="ホスト: $(hostname)\n"
    report+="日時: $(date)\n\n"
    
    if [[ $errors -gt 0 ]]; then
        status="ERROR"
        color="danger"
        report+="❌ エラー: $errors 件\n"
        for msg in "${error_messages[@]}"; do
            report+="  - $msg\n"
        done
        report+="\n"
    fi
    
    if [[ $warnings -gt 0 ]]; then
        if [[ "$status" == "OK" ]]; then
            status="WARNING"
            color="warning"
        fi
        report+="⚠️ 警告: $warnings 件\n"
        for msg in "${warning_messages[@]}"; do
            report+="  - $msg\n"
        done
        report+="\n"
    fi
    
    if [[ $errors -eq 0 && $warnings -eq 0 ]]; then
        report+="✅ すべてのチェックをパス\n"
    fi
    
    log_with_timestamp "$status: Errors=$errors, Warnings=$warnings"
    
    # 通知送信（エラーまたは警告がある場合）
    if [[ $errors -gt 0 || $warnings -gt 0 ]]; then
        send_slack_notification "$report" "$color"
        send_email_notification "Claude Dev Workflow 健全性チェック: $status" "$report"
    fi
    
    # 終了コード
    if [[ $errors -gt 0 ]]; then
        return 2
    elif [[ $warnings -gt 0 ]]; then
        return 1
    else
        return 0
    fi
}

# 自動修復機能
auto_repair() {
    log_with_timestamp "自動修復開始"
    
    # スクリプト権限修復
    find ~/.claude/scripts -name "*.sh" -exec chmod +x {} \;
    
    # 破損バックアップ削除
    for backup in ~/.claude-backups/*.tar.gz; do
        if [[ -f "$backup" ]] && ! tar -tzf "$backup" >/dev/null 2>&1; then
            log_with_timestamp "破損バックアップを削除: $backup"
            rm -f "$backup"
        fi
    done
    
    # 緊急バックアップ作成
    if [[ -d ~/.claude ]]; then
        log_with_timestamp "緊急バックアップ作成中"
        ~/.claude/scripts/backup.sh backup
    fi
    
    log_with_timestamp "自動修復完了"
}

# メイン処理
case "${1:-check}" in
    "check")
        run_health_checks
        ;;
    "repair")
        auto_repair
        ;;
    "monitor")
        # 継続監視モード
        while true; do
            run_health_checks
            sleep 3600  # 1時間間隔
        done
        ;;
    *)
        echo "使用法: $0 [check|repair|monitor]"
        exit 1
        ;;
esac
```

#### 使用状況分析

```bash
# scripts/usage-analytics.sh
#!/bin/bash
# Claude Dev Workflowの使用状況分析

generate_usage_report() {
    local report_file="$HOME/.claude/reports/usage-$(date +%Y%m%d).md"
    mkdir -p "$(dirname "$report_file")"
    
    cat > "$report_file" << EOF
# Claude Dev Workflow 使用状況レポート

**生成日時**: $(date)
**ホスト**: $(hostname)
**ユーザー**: $(whoami)

## 📊 基本統計

### インストール情報
- インストール日: $(stat -f "%SB" ~/.claude 2>/dev/null || stat -c "%y" ~/.claude 2>/dev/null)
- 現在のバージョン: $(cat ~/.claude/.claude-version | jq -r '.version' 2>/dev/null || echo "不明")
- 最終更新日: $(cat ~/.claude/.claude-version | jq -r '.last_updated' 2>/dev/null || echo "不明")

### ディスク使用量
- Claude設定: $(du -sh ~/.claude | cut -f1)
- バックアップ: $(du -sh ~/.claude-backups 2>/dev/null | cut -f1 || echo "0B")
- 合計: $(du -sh ~/.claude ~/.claude-backups 2>/dev/null | awk '{sum+=\$1} END {print sum"B"}' || echo "不明")

### バックアップ統計
- バックアップ数: $(ls ~/.claude-backups/*.tar.gz 2>/dev/null | wc -l || echo "0")
- 最新バックアップ: $(ls -t ~/.claude-backups/*.tar.gz 2>/dev/null | head -1 | xargs basename || echo "なし")
- 最古バックアップ: $(ls -t ~/.claude-backups/*.tar.gz 2>/dev/null | tail -1 | xargs basename || echo "なし")

## 🔧 カスタマイズ状況

### 変更されたファイル
EOF

    # カスタマイズファイル一覧
    if [[ -f ~/.claude/.customizations.json ]]; then
        echo "$(jq -r '.customizations[].file' ~/.claude/.customizations.json 2>/dev/null)" >> "$report_file"
    else
        echo "カスタマイズなし" >> "$report_file"
    fi
    
    cat >> "$report_file" << EOF

### カスタマイズ履歴（最新5件）
EOF

    if [[ -f ~/.claude/scripts/customization-history.sh ]]; then
        ~/.claude/scripts/customization-history.sh --list | head -5 >> "$report_file" 2>/dev/null || echo "履歴なし" >> "$report_file"
    else
        echo "履歴機能なし" >> "$report_file"
    fi

    cat >> "$report_file" << EOF

## 📈 アクティビティ

### スクリプト実行履歴（最新10件）
EOF

    # ログファイルから実行履歴を抽出
    if [[ -f ~/.claude/logs/health-monitor.log ]]; then
        tail -10 ~/.claude/logs/health-monitor.log >> "$report_file"
    else
        echo "実行ログなし" >> "$report_file"
    fi

    cat >> "$report_file" << EOF

## 🚨 問題・推奨事項

### 健全性チェック結果
EOF

    # 健全性チェック実行
    ~/.claude/scripts/health-monitor.sh check >> "$report_file" 2>&1

    cat >> "$report_file" << EOF

### 推奨アクション
EOF

    # 推奨事項の生成
    local recommendations=()
    
    # バックアップが古い場合
    local latest_backup=$(ls -t ~/.claude-backups/*.tar.gz 2>/dev/null | head -1)
    if [[ -n "$latest_backup" ]]; then
        local backup_age=$(( ($(date +%s) - $(stat -f %m "$latest_backup" 2>/dev/null || stat -c %Y "$latest_backup")) / 86400 ))
        if [[ $backup_age -gt 7 ]]; then
            recommendations+=("🔄 バックアップが${backup_age}日前と古いため、新しいバックアップを作成することを推奨")
        fi
    else
        recommendations+=("📦 バックアップが存在しないため、バックアップを作成することを推奨")
    fi
    
    # バージョンが古い場合
    local version_file="$HOME/.claude/.claude-version"
    if [[ -f "$version_file" ]]; then
        local last_updated=$(jq -r '.last_updated' "$version_file" 2>/dev/null)
        if [[ "$last_updated" != "null" && -n "$last_updated" ]]; then
            local last_epoch=$(date -d "$last_updated" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$last_updated" +%s 2>/dev/null)
            local current_epoch=$(date +%s)
            local days_old=$(( (current_epoch - last_epoch) / 86400 ))
            
            if [[ $days_old -gt 30 ]]; then
                recommendations+=("🔄 バージョンが${days_old}日前と古いため、更新を推奨")
            fi
        fi
    fi
    
    # ディスク容量チェック
    local available_space=$(df ~ | tail -1 | awk '{print $4}')
    local threshold=1048576  # 1GB in KB
    if [[ $available_space -lt $threshold ]]; then
        recommendations+=("💾 ディスク容量が不足気味です。不要なバックアップの削除を推奨")
    fi
    
    # 推奨事項を出力
    if [[ ${#recommendations[@]} -eq 0 ]]; then
        echo "✅ 特に問題はありません" >> "$report_file"
    else
        for rec in "${recommendations[@]}"; do
            echo "- $rec" >> "$report_file"
        done
    fi

    cat >> "$report_file" << EOF

---
*このレポートは自動生成されました*
EOF

    echo "📊 レポート生成完了: $report_file"
    return 0
}

# メイン処理
generate_usage_report
```

---

これらの高度な使用例を参考に、組織やプロジェクトの要件に合わせて Claude Dev Workflow をカスタマイズしてください。セキュリティやコンプライアンス要件がある場合は、適切な設定や手順を追加することを推奨します。