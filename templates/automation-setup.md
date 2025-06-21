# 自動化ツール設定手順

## 概要

プロジェクト開始時に一度だけ設定する自動化ツールの導入手順です。
Claude Codeが `workflow/development-flow.md` で定義されたドキュメント自動更新を実行するために必要な環境を構築します。

## 基本方針

- **個人開発に最適化**: 設定が簡単で保守負担が少ないツールを選択
- **段階的導入**: 必須ツール → 推奨ツール → オプションの順序
- **Claude Code対応**: 自動実行しやすい設定

## 必須ツール（プロジェクト開始時）

### 1. Conventional Commits対応

#### 目的
コミットメッセージからCHANGELOG自動生成

#### 設定手順
```bash
# 1. conventional-changelog-cli インストール
npm install -D conventional-changelog-cli

# 2. package.json にスクリプト追加
```

**package.json**:
```json
{
  "scripts": {
    "changelog": "conventional-changelog -p angular -i CHANGELOG.md -s",
    "changelog:first": "conventional-changelog -p angular -i CHANGELOG.md -s -r 0"
  }
}
```

#### Claude Code実行例
```bash
# PR作成時に自動実行
npm run changelog
```

### 2. API仕様書自動生成

#### 目的
TypeScript/JSDocコメントからOpenAPI仕様書生成

#### 設定手順（TypeScript）
```bash
# 1. swagger-jsdoc, swagger-ui-express インストール
npm install -D swagger-jsdoc swagger-ui-express
npm install -D @types/swagger-jsdoc @types/swagger-ui-express
```

**swagger.config.js**:
```javascript
const swaggerJSDoc = require('swagger-jsdoc');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'API Documentation',
      version: '1.0.0',
      description: 'Auto-generated API documentation'
    },
    servers: [
      {
        url: 'http://localhost:3000',
        description: 'Development server'
      }
    ]
  },
  apis: ['./src/**/*.ts', './src/**/*.js'], // Claude Codeが実装するファイル
};

module.exports = swaggerJSDoc(options);
```

**package.json**:
```json
{
  "scripts": {
    "docs:api": "node scripts/generate-api-docs.js",
    "docs:serve": "swagger-ui-serve docs/api-spec.json"
  }
}
```

### 3. 型定義ドキュメント生成

#### 目的
TypeScript型定義から開発者向けドキュメント生成

#### 設定手順
```bash
# TypeDoc インストール
npm install -D typedoc
```

**typedoc.json**:
```json
{
  "entryPoints": ["src/index.ts"],
  "out": "docs/types",
  "theme": "default",
  "excludePrivate": true,
  "excludeProtected": true,
  "excludeExternals": true,
  "readme": "README.md",
  "name": "プロジェクト名 API Documentation"
}
```

**package.json**:
```json
{
  "scripts": {
    "docs:types": "typedoc",
    "docs:types:serve": "cd docs/types && python -m http.server 8080"
  }
}
```

## 推奨ツール（余裕があれば）

### 4. README.md自動更新

#### 目的
機能一覧やAPIエンドポイント一覧の自動更新

#### 設定手順
```bash
# readme-md-generator (オプション)
npm install -D readme-md-generator
```

**カスタムスクリプト例（scripts/update-readme.js）**:
```javascript
const fs = require('fs');
const path = require('path');

// Claude Codeが実行する README更新スクリプト
function updateFeatureList(newFeature) {
  const readmePath = path.join(__dirname, '../README.md');
  let content = fs.readFileSync(readmePath, 'utf8');
  
  // 機能一覧セクションを更新
  const featureSection = content.match(/## 機能一覧([\s\S]*?)(?=##|$)/);
  if (featureSection) {
    const updatedSection = featureSection[0] + `- [x] ${newFeature}\n`;
    content = content.replace(featureSection[0], updatedSection);
    fs.writeFileSync(readmePath, content);
  }
}

module.exports = { updateFeatureList };
```

### 5. テストカバレッジレポート

#### 目的
Vitestテストカバレッジの可視化

#### 設定手順
```bash
# Vitest設定（既存）
npm install -D @vitest/coverage-c8
```

**vitest.config.ts**:
```typescript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    coverage: {
      reporter: ['text', 'html', 'json'],
      reportsDirectory: './docs/coverage'
    }
  }
});
```

**package.json**:
```json
{
  "scripts": {
    "test:coverage": "vitest run --coverage",
    "docs:coverage": "open docs/coverage/index.html"
  }
}
```

## CI/CD自動化設定

### GitHub Actions設定

**.github/workflows/docs.yml**:
```yaml
name: Auto Documentation Update

on:
  push:
    branches: [ develop, main ]
  pull_request:
    branches: [ develop ]

jobs:
  update-docs:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Generate API docs
      run: npm run docs:api
    
    - name: Generate type docs
      run: npm run docs:types
    
    - name: Run tests with coverage
      run: npm run test:coverage
    
    - name: Update changelog
      run: npm run changelog
      
    - name: Commit updated docs
      run: |
        git config --local user.email "action@github.com"
        git config --local user.name "GitHub Action"
        git add docs/
        git diff --staged --quiet || git commit -m "docs: auto-update documentation"
        git push
```

## Claude Code向け設定確認

### 導入確認スクリプト

**scripts/check-automation.js**:
```javascript
// Claude Codeが自動化環境をチェックするスクリプト
const fs = require('fs');

function checkAutomationSetup() {
  const checks = [
    { name: 'package.json scripts', path: 'package.json' },
    { name: 'Swagger config', path: 'swagger.config.js' },
    { name: 'TypeDoc config', path: 'typedoc.json' },
    { name: 'GitHub Actions', path: '.github/workflows/docs.yml' }
  ];

  console.log('🔍 自動化設定チェック結果:');
  checks.forEach(check => {
    const exists = fs.existsSync(check.path);
    console.log(`${exists ? '✅' : '❌'} ${check.name}`);
  });
}

checkAutomationSetup();
```

### Claude Code実行テンプレート

**新規プロジェクトでの指示例**:
```bash
"templates/automation-setup.mdに従って、以下の自動化を設定してください：
1. Conventional Commits対応
2. API仕様書自動生成
3. 型定義ドキュメント生成
4. GitHub Actions設定

設定完了後、scripts/check-automation.jsで確認してください。"
```

## トラブルシューティング

### よくある問題と解決方法

#### 1. API仕様書生成失敗
**原因**: JSDocコメントの形式不正
**解決**: 正しいJSDoc形式に修正

#### 2. TypeDoc生成失敗
**原因**: TypeScript設定問題
**解決**: tsconfig.jsonの"declaration": trueを確認

#### 3. CHANGELOG生成されない
**原因**: Conventional Commits形式でない
**解決**: コミットメッセージ形式確認

#### 4. GitHub Actions失敗
**原因**: 権限設定問題
**解決**: Repository Settings > Actions > Workflow permissionsを確認

## メンテナンス

### 定期確認項目（月次）
- [ ] 自動生成されたドキュメントの品質確認
- [ ] 新しい自動化ツールの調査
- [ ] 不要になったツールの削除検討
- [ ] CI/CD実行時間の最適化

### 更新が必要な場合
- 新しいAPIエンドポイント追加時 → swagger.config.js更新
- 新しいTypeScript型追加時 → typedoc.json確認
- 新しい機能カテゴリ追加時 → README更新スクリプト修正