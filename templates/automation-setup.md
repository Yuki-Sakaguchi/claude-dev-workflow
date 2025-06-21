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

## Supabase統合設定

### 6. Supabase開発環境構築

#### 目的
DB・Auth・Storage統合、ローカル開発環境構築

#### 設定手順
```bash
# 1. Supabase CLI 設定（npx使用、環境に依存しない）
npm install -D supabase

# 2. package.json スクリプト追加
{
  "scripts": {
    "db:start": "supabase start",
    "db:stop": "supabase stop", 
    "db:reset": "supabase db reset",
    "db:gen-types": "supabase gen types typescript --local > types/database.types.ts"
  }
}

# 3. プロジェクト初期化
npx supabase init
npm run db:start

# 4. 必要パッケージインストール
npm install @supabase/supabase-js @supabase/auth-ui-react @supabase/auth-ui-shared
```

**詳細設定**: `templates/supabase-setup.md` を参照

#### Claude Code実行例
```bash
# 型定義自動更新
npm run db:gen-types

# マイグレーション適用
npm run db:reset
```

### 7. 環境変数テンプレート更新

**.env.local**:
```env
# Supabase設定（ローカル開発）
NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# 本番環境用（コメントアウト）
# NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
# NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key

# その他の環境変数
STRIPE_SECRET_KEY=sk_test_...
SENDGRID_API_KEY=SG...
```

### 8. 推奨技術スタック

**更新された推奨構成**:
```
- 言語: TypeScript
- フロントエンド: Next.js (React)
- バックエンド: Next.js (Server Actions)
- データベース: Supabase (PostgreSQL)
- 認証: Supabase Auth
- ストレージ: Supabase Storage
- ホスティング: Vercel
- 外部API: Stripe, SendGrid
- ローカル開発: Supabase CLI + Docker
- 静的解析: ESLint + Prettier + Husky
```

## コード品質・静的解析設定

### 9. ESLint設定

#### 目的
TypeScript・React・Next.jsに最適化されたリンティング

#### 設定手順
```bash
# ESLint関連パッケージインストール
npm install -D eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin
npm install -D eslint-plugin-react eslint-plugin-react-hooks
npm install -D eslint-plugin-jsx-a11y eslint-plugin-import
npm install -D eslint-config-next
```

**.eslintrc.json**:
```json
{
  "extends": [
    "next/core-web-vitals",
    "@typescript-eslint/recommended",
    "plugin:react/recommended",
    "plugin:react-hooks/recommended",
    "plugin:jsx-a11y/recommended",
    "plugin:import/recommended",
    "plugin:import/typescript"
  ],
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaVersion": "latest",
    "sourceType": "module",
    "ecmaFeatures": {
      "jsx": true
    }
  },
  "plugins": [
    "@typescript-eslint",
    "react",
    "react-hooks",
    "jsx-a11y",
    "import"
  ],
  "rules": {
    "react/react-in-jsx-scope": "off",
    "react/prop-types": "off",
    "@typescript-eslint/no-unused-vars": "error",
    "@typescript-eslint/explicit-function-return-type": "off",
    "@typescript-eslint/explicit-module-boundary-types": "off",
    "@typescript-eslint/no-explicit-any": "warn",
    "import/order": [
      "error",
      {
        "groups": [
          "builtin",
          "external", 
          "internal",
          "parent",
          "sibling",
          "index"
        ],
        "newlines-between": "always"
      }
    ]
  },
  "settings": {
    "react": {
      "version": "detect"
    },
    "import/resolver": {
      "typescript": {}
    }
  }
}
```

**.eslintignore**:
```
node_modules/
.next/
out/
build/
dist/
*.min.js
coverage/
docs/
supabase/
```

### 10. Prettier設定

#### 目的
一貫したコードフォーマット

#### 設定手順
```bash
# Prettierインストール
npm install -D prettier eslint-config-prettier eslint-plugin-prettier
```

**.prettierrc.json**:
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false,
  "quoteProps": "as-needed",
  "jsxSingleQuote": true,
  "bracketSpacing": true,
  "bracketSameLine": false,
  "arrowParens": "avoid",
  "endOfLine": "lf"
}
```

**.prettierignore**:
```
node_modules/
.next/
out/
build/
dist/
*.min.js
coverage/
docs/
supabase/
package-lock.json
yarn.lock
pnpm-lock.yaml
```

### 11. Husky + lint-staged設定

#### 目的
コミット前の自動品質チェック

#### 設定手順
```bash
# Huskyとlint-stagedインストール
npm install -D husky lint-staged

# Husky初期化
npx husky init
```

**package.json更新**:
```json
{
  "scripts": {
    "lint": "eslint . --ext .js,.jsx,.ts,.tsx",
    "lint:fix": "eslint . --ext .js,.jsx,.ts,.tsx --fix",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "type-check": "tsc --noEmit",
    "quality": "npm run lint && npm run format:check && npm run type-check"
  },
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{json,md,mdx,css,html,yml,yaml}": [
      "prettier --write"
    ]
  }
}
```

**.husky/pre-commit**:
```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# lint-staged実行
npx lint-staged

# 型チェック
npm run type-check
```

**.husky/commit-msg**:
```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Conventional Commits形式チェック
npx commitlint --edit $1
```

### 12. commitlint設定

#### 目的
Conventional Commits形式の強制

#### 設定手順
```bash
# commitlintインストール
npm install -D @commitlint/cli @commitlint/config-conventional
```

**commitlint.config.js**:
```javascript
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',     // 新機能
        'fix',      // バグ修正
        'docs',     // ドキュメント
        'style',    // コードスタイル
        'refactor', // リファクタリング
        'test',     // テスト
        'chore',    // その他
        'perf',     // パフォーマンス
        'ci',       // CI/CD
        'build',    // ビルド
        'revert'    // リバート
      ]
    ],
    'subject-case': [2, 'never', ['pascal-case', 'upper-case']],
    'subject-max-length': [2, 'always', 100],
    'body-max-line-length': [2, 'always', 100]
  }
}
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

#### 1. ドキュメント自動更新
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

#### 2. 静的解析・品質チェック
**.github/workflows/quality.yml**:
```yaml
name: Code Quality Check

on:
  push:
    branches: [ develop, main ]
  pull_request:
    branches: [ develop, main ]

jobs:
  quality-check:
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
    
    - name: ESLint Check
      run: npm run lint
    
    - name: Prettier Check
      run: npm run format:check
    
    - name: TypeScript Check
      run: npm run type-check
    
    - name: Run Tests
      run: npm run test
    
    - name: Test Coverage
      run: npm run test:coverage
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage/lcov.info
        fail_ci_if_error: true

  security-check:
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
    
    - name: Security Audit
      run: npm audit --audit-level moderate
    
    - name: Dependency Check
      run: npx audit-ci --moderate
```

## Claude Code向け設定確認

### VS Code ワークスペース設定

#### 1. 設定ファイル
**.vscode/settings.json**:
```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true,
    "source.organizeImports": true
  },
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.rulers": [80],
  "files.associations": {
    "*.tsx": "typescriptreact",
    "*.ts": "typescript"
  },
  "typescript.preferences.importModuleSpecifier": "relative",
  "typescript.updateImportsOnFileMove.enabled": "always",
  "eslint.workingDirectories": ["./"],
  "prettier.requireConfig": true,
  "files.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/.next": true,
    "**/coverage": true,
    "**/.husky/_": true
  },
  "search.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/.next": true,
    "**/coverage": true
  }
}
```

**.vscode/extensions.json**:
```json
{
  "recommendations": [
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-typescript-next",
    "formulahendry.auto-rename-tag",
    "christian-kohler.path-intellisense",
    "ms-vscode.vscode-json"
  ]
}
```

### 導入確認スクリプト

**scripts/check-automation.js**:
```javascript
// Claude Codeが自動化環境をチェックするスクリプト
const fs = require('fs');

function checkAutomationSetup() {
  const checks = [
    { name: 'package.json scripts', path: 'package.json' },
    { name: 'ESLint config', path: '.eslintrc.json' },
    { name: 'Prettier config', path: '.prettierrc.json' },
    { name: 'Husky pre-commit', path: '.husky/pre-commit' },
    { name: 'commitlint config', path: 'commitlint.config.js' },
    { name: 'TypeDoc config', path: 'typedoc.json' },
    { name: 'GitHub Actions - docs', path: '.github/workflows/docs.yml' },
    { name: 'GitHub Actions - quality', path: '.github/workflows/quality.yml' },
    { name: 'VS Code settings', path: '.vscode/settings.json' },
    { name: 'VS Code extensions', path: '.vscode/extensions.json' }
  ];

  console.log('🔍 自動化設定チェック結果:');
  console.log('================================================');
  
  let passCount = 0;
  checks.forEach(check => {
    const exists = fs.existsSync(check.path);
    console.log(`${exists ? '✅' : '❌'} ${check.name.padEnd(30)} ${check.path}`);
    if (exists) passCount++;
  });
  
  console.log('================================================');
  console.log(`✅ 成功: ${passCount}/${checks.length} 項目`);
  
  if (passCount === checks.length) {
    console.log('🎉 すべての自動化設定が完了しています！');
  } else {
    console.log('⚠️  不足している設定があります。上記を確認してください。');
  }
}

checkAutomationSetup();
```

### Claude Code実行テンプレート

**新規プロジェクトでの指示例**:
```bash
"templates/automation-setup.mdに従って、以下の自動化を設定してください：
1. ESLint・Prettier・Husky設定
2. Conventional Commits対応
3. API仕様書自動生成
4. 型定義ドキュメント生成
5. GitHub Actions設定（品質チェック・ドキュメント更新）
6. VS Code ワークスペース設定

設定完了後、scripts/check-automation.jsで確認してください。"
```

### クイックセットアップコマンド

**package.json への一括追加スクリプト**:
```json
{
  "scripts": {
    "setup:lint": "npm install -D eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin eslint-plugin-react eslint-plugin-react-hooks eslint-plugin-jsx-a11y eslint-plugin-import eslint-config-next",
    "setup:prettier": "npm install -D prettier eslint-config-prettier eslint-plugin-prettier",
    "setup:husky": "npm install -D husky lint-staged && npx husky init",
    "setup:commitlint": "npm install -D @commitlint/cli @commitlint/config-conventional",
    "setup:docs": "npm install -D conventional-changelog-cli typedoc swagger-jsdoc swagger-ui-express @types/swagger-jsdoc @types/swagger-ui-express",
    "setup:all": "npm run setup:lint && npm run setup:prettier && npm run setup:husky && npm run setup:commitlint && npm run setup:docs",
    "check:setup": "node scripts/check-automation.js"
  }
}
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