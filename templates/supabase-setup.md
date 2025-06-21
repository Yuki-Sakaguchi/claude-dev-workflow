# Supabase開発環境セットアップガイド

## 概要

Supabaseを使用したフルスタック開発環境の構築手順です。
ローカル開発では Supabase CLI を使用して、DB・Auth・Storage をすべてローカルで実行します。

## 前提条件

### 必要なツール
- Node.js 18+ 
- Docker Desktop
- Git

### アカウント
- Supabase アカウント（本番環境用）

## セットアップ手順

### 1. Supabase CLI 設定

```bash
# npx経由で実行（インストール不要、環境に依存しない）
npx supabase --version

# または、プロジェクト固有でインストール（推奨）
npm install -D supabase
```

**package.json にスクリプト追加**:
```json
{
  "scripts": {
    "supabase": "supabase",
    "db:start": "supabase start",
    "db:stop": "supabase stop",
    "db:reset": "supabase db reset",
    "db:gen-types": "supabase gen types typescript --local > types/database.types.ts"
  }
}
```

### 2. プロジェクト初期化

```bash
# プロジェクトディレクトリで実行
npx create-next-app@latest my-app --typescript --tailwind --eslint
cd my-app

# Supabase初期化
npx supabase init

# ローカルSupabase起動
npx supabase start
```

**npm scriptsを使う場合**:
```bash
# package.jsonにスクリプト追加後
npm run db:start
```

### 3. 必要なパッケージインストール

```bash
npm install @supabase/supabase-js @supabase/auth-ui-react @supabase/auth-ui-shared
npm install -D @types/node
```

### 4. 環境変数設定

**.env.local**:
```env
# ローカル開発用（supabase start後に表示される値を使用）
NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# 本番環境用（Supabaseダッシュボードから取得）
# NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
# NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

**.env.example**:
```env
# Supabase設定
NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key
```

### 5. Supabaseクライアント設定

**lib/supabase.ts**:
```typescript
import { createClient } from '@supabase/supabase-js'
import { Database } from '@/types/database.types'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey)
```

### 6. 型定義生成

```bash
# データベース型定義を自動生成
npx supabase gen types typescript --local > types/database.types.ts

# または npm script使用
npm run db:gen-types
```

## データベース設定

### 1. マイグレーション作成

```bash
# 新しいマイグレーション作成
npx supabase migration new create_users_table
```

### 2. サンプルマイグレーション

**supabase/migrations/20231201000000_create_users_table.sql**:
```sql
-- ユーザープロファイルテーブル
create table public.profiles (
  id uuid references auth.users on delete cascade not null primary key,
  username text unique,
  full_name text,
  avatar_url text,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS（Row Level Security）有効化
alter table public.profiles enable row level security;

-- ポリシー設定
create policy "Public profiles are viewable by everyone." on public.profiles
  for select using (true);

create policy "Users can insert their own profile." on public.profiles
  for insert with check (auth.uid() = id);

create policy "Users can update their own profile." on public.profiles
  for update using (auth.uid() = id);

-- ストレージバケット作成
insert into storage.buckets (id, name) values ('avatars', 'avatars');

-- ストレージポリシー
create policy "Avatar images are publicly accessible." on storage.objects
  for select using (bucket_id = 'avatars');

create policy "Anyone can upload an avatar." on storage.objects
  for insert with check (bucket_id = 'avatars');
```

### 3. マイグレーション実行

```bash
# ローカルDBにマイグレーション適用
npx supabase db reset

# または npm script使用
npm run db:reset

# 本番環境にマイグレーション適用（後で実行）
# npx supabase db push
```

## 認証設定

### 1. Auth UI コンポーネント

**components/auth/AuthForm.tsx**:
```typescript
'use client'

import { Auth } from '@supabase/auth-ui-react'
import { ThemeSupa } from '@supabase/auth-ui-shared'
import { supabase } from '@/lib/supabase'

export default function AuthForm() {
  return (
    <Auth
      supabaseClient={supabase}
      appearance={{ theme: ThemeSupa }}
      providers={['google', 'github']}
      redirectTo={`${location.origin}/auth/callback`}
    />
  )
}
```

### 2. Auth コールバック

**app/auth/callback/route.ts**:
```typescript
import { createRouteHandlerClient } from '@supabase/auth-helpers-nextjs'
import { cookies } from 'next/headers'
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get('code')

  if (code) {
    const supabase = createRouteHandlerClient({ cookies })
    await supabase.auth.exchangeCodeForSession(code)
  }

  return NextResponse.redirect(`${origin}/dashboard`)
}
```

### 3. 認証状態管理

**hooks/useAuth.ts**:
```typescript
'use client'

import { useEffect, useState } from 'react'
import { User } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase'

export function useAuth() {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const getSession = async () => {
      const { data: { session } } = await supabase.auth.getSession()
      setUser(session?.user ?? null)
      setLoading(false)
    }

    getSession()

    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        setUser(session?.user ?? null)
        setLoading(false)
      }
    )

    return () => subscription.unsubscribe()
  }, [])

  return { user, loading }
}
```

## ストレージ設定

### 1. ファイルアップロード

**components/upload/FileUpload.tsx**:
```typescript
'use client'

import { useState } from 'react'
import { supabase } from '@/lib/supabase'

interface FileUploadProps {
  bucket: string
  onUpload: (filePath: string) => void
}

export default function FileUpload({ bucket, onUpload }: FileUploadProps) {
  const [uploading, setUploading] = useState(false)

  const uploadFile = async (event: React.ChangeEvent<HTMLInputElement>) => {
    try {
      setUploading(true)

      if (!event.target.files || event.target.files.length === 0) {
        throw new Error('You must select an image to upload.')
      }

      const file = event.target.files[0]
      const fileExt = file.name.split('.').pop()
      const fileName = `${Math.random()}.${fileExt}`
      const filePath = `${fileName}`

      const { error: uploadError } = await supabase.storage
        .from(bucket)
        .upload(filePath, file)

      if (uploadError) {
        throw uploadError
      }

      onUpload(filePath)
    } catch (error) {
      alert('Error uploading file!')
      console.log(error)
    } finally {
      setUploading(false)
    }
  }

  return (
    <div>
      <label className="button primary block" htmlFor="single">
        {uploading ? 'Uploading ...' : 'Upload'}
      </label>
      <input
        style={{
          visibility: 'hidden',
          position: 'absolute',
        }}
        type="file"
        id="single"
        accept="image/*"
        onChange={uploadFile}
        disabled={uploading}
      />
    </div>
  )
}
```

### 2. 画像表示

**components/upload/Avatar.tsx**:
```typescript
'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import Image from 'next/image'

interface AvatarProps {
  uid: string
  url: string | null
  size: number
  onUpload: (url: string) => void
}

export default function Avatar({ uid, url, size, onUpload }: AvatarProps) {
  const [avatarUrl, setAvatarUrl] = useState<string | null>(null)
  const [uploading, setUploading] = useState(false)

  useEffect(() => {
    async function downloadImage(path: string) {
      try {
        const { data, error } = await supabase.storage
          .from('avatars')
          .download(path)
        if (error) {
          throw error
        }
        const url = URL.createObjectURL(data)
        setAvatarUrl(url)
      } catch (error) {
        console.log('Error downloading image: ', error)
      }
    }

    if (url) downloadImage(url)
  }, [url])

  const uploadAvatar: React.ChangeEventHandler<HTMLInputElement> = async (event) => {
    try {
      setUploading(true)

      if (!event.target.files || event.target.files.length === 0) {
        throw new Error('You must select an image to upload.')
      }

      const file = event.target.files[0]
      const fileExt = file.name.split('.').pop()
      const filePath = `${uid}-${Math.random()}.${fileExt}`

      const { error: uploadError } = await supabase.storage
        .from('avatars')
        .upload(filePath, file)

      if (uploadError) {
        throw uploadError
      }

      onUpload(filePath)
    } catch (error) {
      alert('Error uploading avatar!')
    } finally {
      setUploading(false)
    }
  }

  return (
    <div>
      {avatarUrl ? (
        <Image
          width={size}
          height={size}
          src={avatarUrl}
          alt="Avatar"
          className="avatar image"
          style={{ height: size, width: size }}
        />
      ) : (
        <div className="avatar no-image" style={{ height: size, width: size }} />
      )}
      <div style={{ width: size }}>
        <label className="button primary block" htmlFor="single">
          {uploading ? 'Uploading ...' : 'Upload'}
        </label>
        <input
          style={{
            visibility: 'hidden',
            position: 'absolute',
        }}
          type="file"
          id="single"
          accept="image/*"
          onChange={uploadAvatar}
          disabled={uploading}
        />
      </div>
    </div>
  )
}
```

## 開発ワークフロー

### 日常的な開発

```bash
# 1. ローカルSupabase起動
npm run db:start

# 2. 開発サーバー起動
npm run dev

# 3. 型定義更新（DB変更時）
npm run db:gen-types
```

### データベース操作

```bash
# マイグレーション作成
npx supabase migration new add_new_table

# マイグレーション適用
npm run db:reset

# データベースダッシュボード確認
npx supabase dashboard db
```

### 本番デプロイ準備

```bash
# 1. 本番環境作成（Supabaseダッシュボード）
# 2. 環境変数更新
# 3. マイグレーション適用
npx supabase db push

# 4. 型定義更新
npx supabase gen types typescript --project-id your-project-id > types/database.types.ts
```

## トラブルシューティング

### よくある問題

**Docker未起動**:
```bash
# Dockerが起動していることを確認
docker --version
```

**ポート競合**:
```bash
# 使用中のポートを確認
npx supabase status
# または特定ポートで起動
npx supabase start --debug
```

**認証エラー**:
```bash
# 認証設定確認
npx supabase dashboard auth
```

**型定義エラー**:
```bash
# 型定義再生成
npm run db:gen-types
```

### ログ確認

```bash
# Supabaseログ確認
npx supabase logs

# 特定サービスのログ
npx supabase logs auth
npx supabase logs storage
npx supabase logs db
```

## セキュリティ設定

### RLS（Row Level Security）

```sql
-- テーブルレベルでRLS有効化
ALTER TABLE your_table ENABLE ROW LEVEL SECURITY;

-- 基本的なポリシー例
CREATE POLICY "Users can view their own data" ON your_table
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own data" ON your_table
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own data" ON your_table
    FOR UPDATE USING (auth.uid() = user_id);
```

### ストレージポリシー

```sql
-- パブリック読み取り
CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'public');

-- 認証ユーザーのみアップロード
CREATE POLICY "Authenticated users can upload" ON storage.objects
    FOR INSERT TO authenticated WITH CHECK (bucket_id = 'private');

-- ユーザー自身のファイルのみアクセス
CREATE POLICY "Users can access own files" ON storage.objects
    FOR ALL USING (auth.uid()::text = (storage.foldername(name))[1]);
```

## パフォーマンス最適化

### データベースインデックス

```sql
-- よく使用される検索条件にインデックス
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);

-- 複合インデックス
CREATE INDEX idx_posts_user_created ON posts(user_id, created_at DESC);
```

### リアルタイム機能

```typescript
// リアルタイム購読
useEffect(() => {
  const subscription = supabase
    .channel('posts')
    .on('postgres_changes', 
      { event: '*', schema: 'public', table: 'posts' },
      (payload) => {
        console.log('Change received!', payload)
        // UI更新ロジック
      }
    )
    .subscribe()

  return () => {
    subscription.unsubscribe()
  }
}, [])
```

## 備考

- ローカル開発では Docker が必要
- `npm run db:start` でローカル環境一式が起動
- 本番環境は Supabase ダッシュボードから設定
- 型安全性のため、定期的な型定義更新を推奨
- `npx` を使用することで環境に依存しない実行が可能