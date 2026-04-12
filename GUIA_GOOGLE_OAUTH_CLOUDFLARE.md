# Guia Completo: Login e Cadastro Social via Google com Nuxt 3 + Cloudflare Workers

> **Objetivo:** Implementar autenticação social com Google (login e cadastro automático) em aplicações Cloudflare Workers usando Nuxt 3, nuxt-auth-utils, D1 (banco SQL) e KV (chave-valor).
>
> **Versão testada:** Nuxt 3.21.2 + nuxt-auth-utils 0.5.29 + Wrangler 4.81.1

---

## Sumário

1. [Visão Geral da Arquitetura](#1-visão-geral-da-arquitetura)
2. [Pré-requisitos](#2-pré-requisitos)
3. [Configuração no Google Cloud Console](#3-configuração-no-google-cloud-console)
4. [Estrutura do Projeto](#4-estrutura-do-projeto)
5. [Configuração do Nuxt 3](#5-configuração-do-nuxt-3)
6. [Preset Nitro Cloudflare Module (Crítico)](#6-preset-nitro-cloudflare-module-crítico)
7. [Configuração do Cloudflare (wrangler.toml)](#7-configuração-do-cloudflare-wranglertoml)
8. [Tipos TypeScript para Autenticação](#8-tipos-typescript-para-autenticação)
9. [OAuth — Handlers Google](#9-oauth--handlers-google)
10. [Utilitários D1 — Banco de Dados SQL](#10-utilitários-d1--banco-de-dados-sql)
11. [Utilitários KV — Armazenamento Chave-Valor](#11-utilitários-kv--armazenamento-chave-valor)
12. [API Endpoints](#12-api-endpoints)
13. [Frontend — Páginas Nuxt](#13-frontend--páginas-nuxt)
14. [Desenvolvimento Local (Mocks)](#14-desenvolvimento-local-mocks)
15. [Deploy Seguro para Cloudflare](#15-deploy-seguro-para-cloudflare)
16. [Configuração de Secrets no Cloudflare](#16-configuração-de-secrets-no-cloudflare)
17. [Criação de Banco D1 em Produção](#17-criação-de-banco-d1-em-produção)
18. [Solução de Problemas](#18-solução-de-problemas)
19. [Checklist de Segurança](#19-checklist-de-segurança)
20. [Referências](#20-referências)

---

## 1. Visão Geral da Arquitetura

```
┌─────────────────────────────────────────────────────────────────┐
│                        NAVEGADOR DO USUÁRIO                      │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│              CLOUDFLARE WORKER (Nuxt 3.21.2 SPA)                │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Rotas de Autenticação Manual                             │  │
│  │  ├── GET /auth/google          → Redireciona p/ Google    │  │
│  │  ├── GET /auth/google/callback → Troca código p/ token    │  │
│  │  └── Sessão (cookies criptografados)                       │  │
│  │                                                           │  │
│  │  API Endpoints:                                           │  │
│  │  ├── GET  /api/me          → dados do usuário             │  │
│  │  ├── POST /api/set-balance → atualiza D1                  │  │
│  │  ├── POST /api/set-counter → atualiza KV                  │  │
│  │  └── POST /api/logout      → destrói sessão               │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  D1 Database (SQLite edge)                                │  │
│  │  ├── users (id, google_sub, email, name, timestamps)      │  │
│  │  └── d1_state (user_id, balance)                          │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  KV Namespace                                             │  │
│  │  └── user:{sub}:counter → valor                           │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                             ▲
                             │
┌────────────────────────────┴────────────────────────────────────┐
│                    GOOGLE OAUTH 2.0                              │
│  └── accounts.google.com → troca de código por token            │
└─────────────────────────────────────────────────────────────────┘
```

### Fluxo de Autenticação

1. **Usuário clica** em "Entrar com Google" na landing page
2. **Worker redireciona** para `accounts.google.com/oauth/authorize` com `redirect_uri=https://...`
3. **Google** autentica o usuário e retorna um `code` para `/auth/google/callback`
4. **Handler callback** troca o `code` por dados do usuário (`sub`, `email`, `name`)
5. **Handler** salva/atualiza o usuário no D1 e inicia counter no KV
6. **Worker** cria sessão com cookie criptografado (`setUserSession`)
7. **Usuário** é redirecionado para `/app` (área logada)

---

## 2. Pré-requisitos

| Ferramenta | Versão | Comando de Verificação |
|-----------|--------|------------------------|
| Node.js | 20+ | `node -v` |
| npm | 10+ | `npm -v` |
| Wrangler | 4+ | `npx wrangler --version` |

### Dependências do Projeto

```json
{
  "dependencies": {
    "nuxt": "^3.21.2",
    "nuxt-auth-utils": "^0.5.29",
    "oslo": "^1.2.1",
    "vue": "^3.5.13",
    "vue-router": "^4.5.0"
  },
  "devDependencies": {
    "@cloudflare/workers-types": "^4.20260411.1",
    "@eslint/js": "^9.22.0",
    "@nuxt/eslint": "^0.7.5",
    "@nuxtjs/tailwindcss": "^6.12.0",
    "autoprefixer": "^10.4.19",
    "eslint": "^9.18.0",
    "postcss": "^8.4.38",
    "tailwindcss": "^3.4.3",
    "typescript": "^5.7.3",
    "typescript-eslint": "^8.58.1",
    "vitest": "^2.1.8",
    "wrangler": "^4.81.1"
  }
}
```

### Instalação Inicial

```bash
# Criar projeto Nuxt
npx nuxi init meu-projeto
cd meu-projeto

# Instalar todas as dependências de uma vez
npm install nuxt-auth-utils
npm install -D @cloudflare/workers-types wrangler typescript eslint @eslint/js @nuxt/eslint @nuxtjs/tailwindcss tailwindcss autoprefixer postcss typescript-eslint vitest
```

---

## 3. Configuração no Google Cloud Console

### Passo 1: Criar Projeto

1. Acesse [console.cloud.google.com](https://console.cloud.google.com)
2. Crie um novo projeto ou selecione um existente
3. Ative a **Google People API** (necessária para OAuth)

### Passo 2: Criar Credenciais OAuth

1. Vá em **APIs e Serviços → Credenciais**
2. Clique em **Criar credenciais → ID do cliente OAuth**
3. Tipo de aplicativo: **Aplicativo da Web**
4. Dê um nome ao cliente (ex: `meu-app-google-login`)

### Passo 3: Configurar URIs de Redirecionamento

Adicione os seguintes **URIs de redirecionamento autorizados**:

| Ambiente | URI |
|----------|-----|
| Produção | `https://seu-worker.workers.dev/auth/google/callback` |
| Dev local (npm) | `http://localhost:3000/auth/google/callback` |
| Dev local (wrangler) | `http://localhost:8787/auth/google/callback` |

> **⚠️ CRÍTICO:** O Google exige **HTTPS** para URIs de redirecionamento. O Cloudflare Workers recebe internamente `http://` mesmo quando o tráfego do cliente é `https://`. Por isso, você **deve forçar HTTPS manualmente** no handler OAuth. Veja a [Seção 18](#18-solução-de-problemas) para detalhes.

### Passo 4: Anotar Credenciais

Após criar, anote:
- **Client ID** (ex: `123456789-abc123.apps.googleusercontent.com`)
- **Client Secret** (ex: `GOCSPX-xxxxxxxxxxxxxxx`)

---

## 4. Estrutura do Projeto

```
meu-projeto/
├── server/
│   ├── routes/
│   │   └── auth/
│   │       └── google/
│   │           ├── index.get.ts      # Inicia OAuth → redireciona p/ Google
│   │           └── callback.get.ts   # Processa callback do Google
│   ├── api/
│   │   ├── me.get.ts                 # Dados do usuário logado
│   │   ├── set-balance.post.ts       # Atualizar balance no D1
│   │   ├── set-counter.post.ts       # Atualizar counter no KV
│   │   └── logout.post.ts            # Destruir sessão
│   ├── utils/
│   │   ├── db.ts                     # Utilitários D1 (produção)
│   │   ├── kv.ts                     # Utilitários KV (produção)
│   │   ├── db-local.ts               # Mock JSON (dev local)
│   │   ├── kv-local.ts               # Mock JSON (dev local)
│   │   └── logger.ts                 # Sistema de logging
│   └── migrations/
│       └── 001_create_tables.sql     # Migrações D1
├── assets/
│   └── css/
│       └── main.css                  # Tailwind CSS entry point
├── pages/
│   ├── index.vue                     # Landing page (botão Google Login)
│   └── app.vue                       # Área logada (dados do usuário)
├── auth.d.ts                         # Tipos para nuxt-auth-utils
├── nuxt.config.ts                    # Configuração Nuxt
├── tailwind.config.js                # Configuração Tailwind CSS
├── postcss.config.js                 # Configuração PostCSS
├── wrangler.toml                     # Configuração Cloudflare
├── .env.example                      # Template de variáveis
├── .env                              # Variáveis locais (NÃO commitar)
├── .env.production                   # Referência para produção
├── package.json
└── tsconfig.json
```

> **⚠️ IMPORTANTE:** As rotas de OAuth devem ser nomeadas como `google/index.get.ts` e `google/callback.get.ts` (não `google.get.ts`) para que o Google receba o callback correto em `/auth/google/callback`.

---

## 5. Configuração do Nuxt 3

### `nuxt.config.ts`

```ts
export default defineNuxtConfig({
  compatibilityDate: '2025-04-01',
  devtools: { enabled: true },

  modules: ['nuxt-auth-utils', '@nuxtjs/tailwindcss'],

  experimental: { appManifest: false },

  css: ['~/assets/css/main.css'],

  runtimeConfig: {
    oauth: {
      google: {
        clientId: process.env.NUXT_OAUTH_GOOGLE_CLIENT_ID || '',
        clientSecret: process.env.NUXT_OAUTH_GOOGLE_CLIENT_SECRET || '',
        redirectUri: process.env.NUXT_OAUTH_GOOGLE_REDIRECT_URI || '',
      },
    },
    public: {
      oauthGoogleEnabled: true,
      appUrl: process.env.NUXT_PUBLIC_APP_URL || '',
    },
  },

  nitro: {
    preset: 'cloudflare-module',
    envPrefix: 'NUXT_',
  },

  ssr: false,  // SPA mode
})
```

### Pontos Importantes

| Configuração | Por que usar |
|-------------|-------------|
| `preset: 'cloudflare-module'` | Gera ES Module — **obrigatório** para D1/KV |
| `ssr: false` | SPA simplificado — worker serve HTML estático |
| `runtimeConfig.oauth.google` | Estrutura esperada pelo nuxt-auth-utils |
| `experimental.appManifest: false` | Remove warnings de `#app-manifest` |
| `envPrefix: 'NUXT_'` | Permite prefixo `NUXT_` para variáveis de ambiente |
| `modules: ['@nuxtjs/tailwindcss']` | Habilita Tailwind CSS automaticamente |

### Arquivos Adicionais Necessários

#### `tailwind.config.js`

```js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './components/**/*.{js,vue,ts}',
    './layouts/**/*.vue',
    './pages/**/*.vue',
    './plugins/**/*.{js,ts}',
    './app.vue',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

#### `postcss.config.js`

```js
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
```

#### `assets/css/main.css`

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

---

## 6. Preset Nitro Cloudflare Module (Crítico)

### ⚠️ Configuração Crítica

O preset do Nitro **deve** ser `cloudflare-module` (não `cloudflare`) para que D1 e KV funcionem:

```ts
// nuxt.config.ts
nitro: {
  preset: 'cloudflare-module',  // ← OBRIGATÓRIO para D1/KV
},
```

### Por que `cloudflare-module` e não `cloudflare`?

| Preset | Formato Gerado | D1/KV | Comportamento |
|--------|---------------|-------|--------------|
| `cloudflare` | Service Worker | ❌ **Falha** | Erro: `Binding 'DB' requires ES module format` |
| `cloudflare-module` | ES Module | ✅ Funciona | Exporta `export default { fetch }` |
| `cloudflare-pages` | ES Module | ✅ Funciona | Para Cloudflare Pages (não Workers) |

### O Erro que Você Vai Encontrar

Se usar o preset errado (`cloudflare`), o deploy falhará com:

```
X [ERROR] Binding 'DB' of type 'd1' requires a Worker
written in ES module format. [code: 100329]
```

### Como Verificar o Preset no Build

```bash
npm run build
# Procure no output: ● Nitro preset: cloudflare-module
```

### Estrutura do ES Module Gerado

```js
// .output/server/index.mjs (simplificado)
export default {
  async fetch(request, env, ctx) {
    return nitroApp.fetch(request, env, ctx)
  }
}
```

O preset `cloudflare` gera um Service Worker (`addEventListener('fetch', ...)`) que não é compatível com D1/KV.

---

## 7. Configuração do Cloudflare (wrangler.toml)

```toml
name = "meu-worker"
main = "./.output/server/index.mjs"
compatibility_date = "2025-06-01"

# D1 Database (SQL edge)
[[d1_databases]]
binding = "DB"
database_name = "meu-db"
database_id = "SUA_DATABASE_ID_AQUI"

# KV Namespace (chave-valor)
[[kv_namespaces]]
binding = "KV"
id = "SUA_KV_ID_AQUI"

# Variáveis de ambiente (públicas - não são secrets)
[vars]
NUXT_PUBLIC_APP_URL = "https://meu-worker.workers.dev"
NUXT_OAUTH_GOOGLE_REDIRECT_URI = "https://meu-worker.workers.dev/auth/google/callback"
```

### Obter IDs de D1 e KV

```bash
# Criar D1
npx wrangler d1 create meu-db
# Output: database_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Criar KV
npx wrangler kv:namespace create "meu-kv"
# Output: id = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

---

## 8. Tipos TypeScript para Autenticação

### `auth.d.ts`

```ts
declare module '#auth-utils' {
  interface User {
    googleSub: string    // ID único do Google
    email: string        // Email do usuário
    name: string         // Nome do usuário
  }

  interface UserSession {
    loggedInAt: number   // Timestamp de login
  }

  interface SecureSessionData {}
}

export {}
```

### Por que o `googleSub`?

O `sub` (subject) é o identificador **único e imutável** do usuário no Google OAuth 2.0. **Nunca muda**, mesmo que o usuário altere email ou nome. É o campo ideal para chaves primárias e sessões.

---

## 9. OAuth — Handlers Google

### ⚠️ AVISO IMPORTANTE SOBRE nuxt-auth-utils

O nuxt-auth-utils possui um **bug conhecido** com Cloudflare Workers: a função interna `getOAuthRedirectURL()` usa `getRequestURL(event)` do h3, que retorna `http://` internamente nos Workers (mesmo quando o tráfego do cliente é `https://`).

Isso causa o erro **`redirect_uri_mismatch`** porque o Google rejeita URIs `http://` para produção.

**Solução:** Implemente handlers OAuth **manuais** (sem `defineOAuthGoogleEventHandler`) para forçar HTTPS explícito no `redirect_uri`.

### `server/routes/auth/google/index.get.ts` — Inicia o OAuth

```ts
import { sendRedirect } from 'h3'
import { withQuery } from 'ufo'

// Esta rota redireciona o usuário para o Google
export default eventHandler(async (event) => {
  const config = useRuntimeConfig(event)
  const clientId = config.oauth?.google?.clientId

  // Forçar HTTPS explícito (Cloudflare Workers recebe http:// internamente)
  const redirectUri = 'https://meu-worker.workers.dev/auth/google/callback'

  if (!clientId) {
    return sendRedirect(event, '/?error=missing_oauth_config')
  }

  const authUrl = withQuery('https://accounts.google.com/o/oauth2/v2/auth', {
    response_type: 'code',
    client_id: clientId,
    redirect_uri: redirectUri,
    scope: 'openid email profile',
  })

  return sendRedirect(event, authUrl)
})
```

### `server/routes/auth/google/callback.get.ts` — Processa o Callback

```ts
import { sendRedirect, getQuery } from 'h3'

const SUPER_ADMIN_EMAIL = 'alexbreno2005@gmail.com'

export default eventHandler(async (event) => {
  const query = getQuery(event)
  const env = event.context.cloudflare?.env
  const config = useRuntimeConfig(event)

  const clientId = config.oauth?.google?.clientId
  const clientSecret = config.oauth?.google?.clientSecret
  const redirectUri = 'https://meu-worker.workers.dev/auth/google/callback'

  if (!clientId || !clientSecret) {
    return sendRedirect(event, '/?error=missing_oauth_config')
  }

  if (!query.code) {
    return sendRedirect(event, '/?error=no_code')
  }

  try {
    // 1. Trocar código por token
    const tokenResponse = await $fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        code: query.code as string,
        client_id: clientId,
        client_secret: clientSecret,
        redirect_uri: redirectUri,
      }),
    })

    if (tokenResponse.error) {
      console.error('[OAUTH] Token error:', tokenResponse)
      return sendRedirect(event, '/?error=auth_failed')
    }

    // 2. Obter dados do usuário
    const user = await $fetch('https://www.googleapis.com/oauth2/v3/userinfo', {
      headers: { Authorization: `Bearer ${tokenResponse.access_token}` },
    })

    const { sub: googleSub, email, name } = user

    // 3. Salvar no D1/KV
    if (env) {
      const { findOrCreateUser } = await import('~/server/utils/db')
      const { getCounter } = await import('~/server/utils/kv')
      await findOrCreateUser(env.DB, googleSub, email, name)
      await getCounter(env.KV, googleSub)
    }

    // 4. Criar sessão
    const isSuperAdmin = email === SUPER_ADMIN_EMAIL

    await setUserSession(event, {
      user: {
        googleSub,
        email,
        name,
        role: isSuperAdmin ? 'superadmin' : 'user',
        plan: 'google',
      },
      loggedInAt: Date.now(),
      userPlan: 'google',
      userRole: isSuperAdmin ? 'superadmin' : 'user',
    })

    console.log('[OAUTH] User logged in:', { googleSub, email, isSuperAdmin })
    return sendRedirect(event, '/app')
  } catch (error: any) {
    console.error('[OAUTH] Error in OAuth callback:', error)
    return sendRedirect(event, '/?error=auth_failed')
  }
})
```

### Estrutura de Arquivos das Rotas OAuth

```
server/routes/auth/
├── google/
│   ├── index.get.ts      → GET /auth/google (inicia OAuth)
│   └── callback.get.ts   → GET /auth/google/callback (processa retorno)
```

> **⚠️ CRÍTICO:** Não use `google.get.ts` como nome de arquivo. Isso gera a rota `/auth/google` mas **não** `/auth/google/callback`. O Google precisa de ambas as rotas separadas.

### Fluxo Completo

```
GET /auth/google
        │
        ▼
┌──────────────────────────────┐
│ redirect_uri FORÇADO HTTPS   │
│ https://worker/auth/google/  │
│ callback                     │
└──────────────┬───────────────┘
               ▼
┌──────────────────────────────┐
│ accounts.google.com/oauth/   │
│ authorize                    │
│ (usuário autoriza)           │
└──────────────┬───────────────┘
               ▼
┌──────────────────────────────┐
│ Google retorna para:         │
│ https://worker/auth/google/  │
│ callback?code=xxx            │
└──────────────┬───────────────┘
               ▼
┌──────────────────────────────┐
│ callback.get.ts processa:    │
│ 1. Troca code → token        │
│ 2. Busca userinfo            │
│ 3. Salva no D1/KV            │
│ 4. Cria sessão               │
│ 5. Redirect /app             │
└──────────────────────────────┘
```

---

## 10. Utilitários D1 — Banco de Dados SQL

### Migração — `server/migrations/001_create_tables.sql`

```sql
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  google_sub TEXT UNIQUE NOT NULL,
  email TEXT NOT NULL,
  name TEXT NOT NULL,
  role TEXT DEFAULT 'user',
  plan TEXT DEFAULT 'google',
  created_at TEXT DEFAULT (datetime('now')),
  last_login_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS d1_state (
  user_id INTEGER NOT NULL UNIQUE,
  balance INTEGER NOT NULL DEFAULT 0,
  updated_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### Utilitários — `server/utils/db.ts`

```ts
export interface User {
  id: number
  google_sub: string
  email: string
  name: string
  role?: string
  plan?: string
}

export async function findOrCreateUser(
  db: D1Database,
  googleSub: string,
  email: string,
  name: string,
): Promise<User> {
  const existing = await db
    .prepare('SELECT id, google_sub, email, name FROM users WHERE google_sub = ?')
    .bind(googleSub)
    .first<User>()

  if (existing) {
    await db
      .prepare("UPDATE users SET last_login_at = datetime('now') WHERE google_sub = ?")
      .bind(googleSub)
      .run()
    return existing
  }

  const result = await db
    .prepare('INSERT INTO users (google_sub, email, name) VALUES (?, ?, ?) RETURNING id, google_sub, email, name')
    .bind(googleSub, email, name)
    .first<User>()

  if (!result) throw new Error('Failed to create user')

  // Inicializar estado com balance = 0
  await db
    .prepare('INSERT INTO d1_state (user_id, balance) VALUES (?, 0)')
    .bind(result.id)
    .run()

  return result
}

export interface UserWithBalance extends User {
  balance: number
}

export async function getUserData(
  db: D1Database,
  googleSub: string,
): Promise<UserWithBalance | null> {
  const user = await db
    .prepare('SELECT id, google_sub, email, name FROM users WHERE google_sub = ?')
    .bind(googleSub)
    .first<User>()

  if (!user) return null

  const balance = await getUserBalance(db, user.id)

  return { ...user, balance }
}

export async function getUserBalance(db: D1Database, userId: number): Promise<number> {
  const result = await db
    .prepare('SELECT balance FROM d1_state WHERE user_id = ?')
    .bind(userId)
    .first<{ balance: number }>()

  return result?.balance ?? 0
}

export async function setUserBalance(
  db: D1Database,
  userId: number,
  balance: number,
): Promise<void> {
  await db
    .prepare("UPDATE d1_state SET balance = ?, updated_at = datetime('now') WHERE user_id = ?")
    .bind(balance, userId)
    .run()
}
```

### Padrão de Uso D1

```ts
// Dentro de um handler de API
const db = event.context.cloudflare.env.DB

const result = await db
  .prepare('SELECT * FROM users WHERE google_sub = ?')
  .bind(googleSub)
  .first<User>()
```

---

## 11. Utilitários KV — Armazenamento Chave-Valor

### `server/utils/kv.ts`

```ts
export async function getCounter(kv: KVNamespace, googleSub: string): Promise<number> {
  const value = await kv.get(`user:${googleSub}:counter`)
  return value ? parseInt(value, 10) : 0
}

export async function setCounter(
  kv: KVNamespace,
  googleSub: string,
  counter: number,
): Promise<void> {
  await kv.put(`user:${googleSub}:counter`, String(counter))
}
```

### Padrão de Chaves KV Recomendado

```
user:{googleSub}:{chave}
```

Exemplos:
- `user:112112769343846647692:counter`
- `user:112112769343846647692:preferences`
- `user:112112769343846647692:cache:dashboard`

### D1 vs KV — Quando Usar Cada Um

| Recurso | D1 (SQL) | KV (Chave-Valor) |
|---------|----------|-----------------|
| Dados relacionais | ✅ | ❌ |
| Consultas complexas | ✅ | ❌ |
| Acesso rápido por chave | ❌ (lento) | ✅ (rápido) |
| TTL (expiração) | ❌ | ✅ |
| Writes frequentes | ✅ | ⚠️ (limitado) |
| Uso típico | Perfis, pedidos, saldo | Sessões, cache, contadores |

---

## 12. API Endpoints

### `GET /api/me` — Dados do Usuário

```ts
export default defineEventHandler(async (event) => {
  const session = await requireUserSession(event)

  const isLocalDev = !event.context.cloudflare
  const env = event.context.cloudflare?.env

  if (isLocalDev) {
    // Dev local: usar mocks
    const balance = getLocalUserBalance(session.user.googleSub)
    const counter = getLocalCounter(session.user.googleSub)
    return {
      name: session.user.name,
      email: session.user.email,
      balance,
      counter,
      localDev: true,
    }
  }

  // Produção: D1 + KV
  const userData = await getUserData(env.DB, session.user.googleSub)
  if (!userData) {
    throw createError({ statusCode: 404, message: 'User not found' })
  }

  const counter = await getCounter(env.KV, session.user.googleSub)

  return {
    name: session.user.name,
    email: session.user.email,
    balance: userData.balance,
    counter,
  }
})
```

### `POST /api/set-balance` — Atualizar Balance no D1

```ts
export default defineEventHandler(async (event) => {
  const session = await requireUserSession(event)
  const env = event.context.cloudflare.env
  const body = await readBody(event)

  if (typeof body.balance !== 'number') {
    throw createError({ statusCode: 400, message: 'Invalid balance value' })
  }

  const userData = await getUserData(env.DB, session.user.googleSub)
  if (!userData) {
    throw createError({ statusCode: 404, message: 'User not found' })
  }

  await setUserBalance(env.DB, userData.id, body.balance)

  return { success: true, balance: body.balance }
})
```

### `POST /api/set-counter` — Atualizar Counter no KV

```ts
export default defineEventHandler(async (event) => {
  const session = await requireUserSession(event)
  const env = event.context.cloudflare.env
  const body = await readBody(event)

  if (typeof body.counter !== 'number') {
    throw createError({ statusCode: 400, message: 'Invalid counter value' })
  }

  await setCounter(env.KV, session.user.googleSub, body.counter)

  return { success: true, counter: body.counter }
})
```

### `POST /api/logout` — Destruir Sessão

```ts
export default defineEventHandler(async (event) => {
  await clearUserSession(event)
  return { success: true }
})
```

---

## 13. Frontend — Páginas Nuxt

### `pages/index.vue` — Landing Page

```vue
<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100">
    <div class="card bg-white p-8 rounded-lg shadow-lg text-center">
      <h1 class="text-2xl font-bold mb-2">Mini App de Teste</h1>
      <p class="text-gray-600 mb-6">Nuxt 3 + Cloudflare + D1/KV + Google Auth</p>
      <a href="/auth/google" class="btn-google">
        <span class="logo">G</span> Entrar com Google
      </a>
    </div>
  </div>
</template>
```

### `pages/app.vue` — Área Logada

```vue
<template>
  <div class="min-h-screen bg-gray-100 p-8">
    <div class="card bg-white p-6 rounded-lg shadow-lg max-w-md mx-auto">
      <h1 class="text-2xl font-bold mb-4">Olá, {{ user?.name }}!</h1>
      <p class="text-gray-600">Email: {{ user?.email }}</p>
      <p class="text-gray-600">Balance: {{ userData?.balance }}</p>
      <p class="text-gray-600">Counter: {{ userData?.counter }}</p>

      <button @click="handleLogout" class="btn mt-4">Sair</button>
    </div>
  </div>
</template>

<script setup lang="ts">
const { user, loggedIn, clear } = useUserSession()
const { data: userData } = await useFetch('/api/me')

const handleLogout = async () => {
  await $fetch('/api/logout', { method: 'POST' })
  await clear()
  navigateTo('/')
}
</script>
```

### `useUserSession()` — Composable do nuxt-auth-utils

| Retorno | Tipo | Descrição |
|---------|------|-----------|
| `user` | `Ref<User \| null>` | Objeto User (googleSub, email, name) |
| `loggedIn` | `Ref<boolean>` | Usuário está autenticado |
| `clear()` | `() => Promise<void>` | Limpa a sessão no client |

---

## 14. Desenvolvimento Local (Mocks)

Em dev local (`npm run dev`) não há D1/KV disponível. Crie mocks com arquivos JSON:

### `server/utils/db-local.ts`

```ts
import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'node:fs'
import { join } from 'node:path'

const DB_DIR = join(process.cwd(), 'data-local')
const DB_PATH = join(DB_DIR, 'db.json')

function ensureDir() {
  if (!existsSync(DB_DIR)) mkdirSync(DB_DIR, { recursive: true })
}

function loadDB() {
  ensureDir()
  if (!existsSync(DB_PATH)) {
    const initial = { nextId: 1, users: [] }
    writeFileSync(DB_PATH, JSON.stringify(initial, null, 2))
    return initial
  }
  return JSON.parse(readFileSync(DB_PATH, 'utf-8'))
}

function saveDB(db: any) {
  writeFileSync(DB_PATH, JSON.stringify(db, null, 2))
}

export function findOrCreateLocalUser(googleSub: string, email: string, name: string) {
  const db = loadDB()
  let user = db.users.find((u: any) => u.google_sub === googleSub)

  if (user) {
    user.last_login_at = new Date().toISOString()
    saveDB(db)
    return user
  }

  user = {
    id: db.nextId++,
    google_sub: googleSub,
    email,
    name,
    balance: 0,
    created_at: new Date().toISOString(),
    last_login_at: new Date().toISOString(),
  }

  db.users.push(user)
  saveDB(db)
  return user
}

export function getLocalUserBalance(googleSub: string): number {
  const db = loadDB()
  const user = db.users.find((u: any) => u.google_sub === googleSub)
  return user?.balance ?? 0
}

export function setLocalUserBalance(googleSub: string, balance: number) {
  const db = loadDB()
  const user = db.users.find((u: any) => u.google_sub === googleSub)
  if (user) {
    user.balance = balance
    saveDB(db)
  }
}
```

### `server/utils/kv-local.ts`

```ts
import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'node:fs'
import { join } from 'node:path'

const KV_DIR = join(process.cwd(), 'data-local')
const KV_PATH = join(KV_DIR, 'kv.json')

function ensureDir() {
  if (!existsSync(KV_DIR)) mkdirSync(KV_DIR, { recursive: true })
}

function loadKV() {
  ensureDir()
  if (!existsSync(KV_PATH)) {
    writeFileSync(KV_PATH, JSON.stringify({}, null, 2))
    return {}
  }
  return JSON.parse(readFileSync(KV_PATH, 'utf-8'))
}

function saveKV(kv: any) {
  writeFileSync(KV_PATH, JSON.stringify(kv, null, 2))
}

export function getLocalCounter(key: string): number {
  const kv = loadKV()
  const value = kv[`user:${key}:counter`]
  return value ? parseInt(value, 10) : 0
}

export function setLocalCounter(key: string, counter: number): void {
  const kv = loadKV()
  kv[`user:${key}:counter`] = String(counter)
  saveKV(kv)
}
```

### `.gitignore` para Dev Local

```
data-local/
.env
.env.local
.env.production
.nuxt/
.output/
```

---

## 15. Deploy Seguro para Cloudflare

### Passo 1: Build

```bash
npm run build
# Output: ● Nitro preset: cloudflare-module
```

### Passo 2: Deploy

```bash
npx wrangler deploy .output/server/index.mjs --assets .output/public
```

### ⚠️ Regras de Segurança

| Regra | Por quê |
|-------|---------|
| NUNCA commitar `.env` | Secrets expostos no Git |
| Usar `.env.example` como template | Referência segura |
| Secrets via Wrangler CLI ou Dashboard | Armazenados criptografados |
| `NUXT_SESSION_PASSWORD` ≥32 chars | Segurança da sessão |
| `.gitignore` completo | Evita vazamento acidental |

---

## 16. Configuração de Secrets no Cloudflare

### Via Wrangler CLI (Recomendado)

```bash
# Session password (mínimo 32 caracteres)
echo "sua-senha-com-mais-de-32-caracteres" | npx wrangler secret put NUXT_SESSION_PASSWORD

# Google OAuth Client ID
echo "seu-client-id.apps.googleusercontent.com" | npx wrangler secret put NUXT_OAUTH_GOOGLE_CLIENT_ID

# Google OAuth Client Secret
echo "GOCSPX-xxxxxxxxxxxxxxx" | npx wrangler secret put NUXT_OAUTH_GOOGLE_CLIENT_SECRET
```

### Via Dashboard

1. Acesse [dash.cloudflare.com](https://dash.cloudflare.com)
2. **Workers & Pages** → seu worker → **Settings** → **Environment Variables**
3. Adicione como **Secrets** (não como plain text):

| Variável | Valor | Tipo |
|----------|-------|------|
| `NUXT_SESSION_PASSWORD` | Senha ≥32 caracteres | Secret |
| `NUXT_OAUTH_GOOGLE_CLIENT_ID` | Client ID do Google | Secret |
| `NUXT_OAUTH_GOOGLE_CLIENT_SECRET` | Client Secret do Google | Secret |

### Verificar Secrets

```bash
npx wrangler secret list
# [
#   { "name": "NUXT_SESSION_PASSWORD", "type": "secret_text" },
#   { "name": "NUXT_OAUTH_GOOGLE_CLIENT_ID", "type": "secret_text" },
#   { "name": "NUXT_OAUTH_GOOGLE_CLIENT_SECRET", "type": "secret_text" }
# ]
```

### Variáveis Públicas (wrangler.toml)

Variáveis que não são sensíveis (como a URL do app) podem ser colocadas no `wrangler.toml`:

```toml
[vars]
NUXT_PUBLIC_APP_URL = "https://meu-worker.workers.dev"
```

---

## 17. Criação de Banco D1 em Produção

```bash
# Criar o banco (se não existir)
npx wrangler d1 create meu-db
# Output: database_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Aplicar migrações
npx wrangler d1 execute meu-db \
  --file server/migrations/001_create_tables.sql \
  --remote

# Verificar tabelas
npx wrangler d1 execute meu-db \
  --command "SELECT name FROM sqlite_master WHERE type='table'" \
  --remote
```

---

## 18. Solução de Problemas

### ⚠️ Erro 1: `redirect_uri_mismatch` (Erro 400)

**Sintoma:**
```
Erro 400: redirect_uri_mismatch
Não foi possível fazer login, porque esse app enviou uma solicitação inválida.
```

**Causas Possíveis e Soluções:**

#### Causa A: Google Console não tem o URI de callback cadastrado

**Solução:** Adicione no Google Cloud Console → Credenciais → URI de redirecionamento autorizado:
```
https://meu-worker.workers.dev/auth/google/callback
```

#### Causa B: nuxt-auth-utils gera `http://` ao invés de `https://`

**Por que acontece:** Cloudflare Workers recebe internamente `http://` mesmo quando o tráfego do cliente é `https://`. O nuxt-auth-utils usa `getRequestURL(event)` do h3 que retorna `http://` para os Workers.

**Como verificar:** Na URL de erro do Google, procure por `redirect_uri=http://...`

**Solução definitiva:** Implemente handlers OAuth **manuais** (sem `defineOAuthGoogleEventHandler`) forçando HTTPS explícito no `redirect_uri`:

```ts
// server/routes/auth/google/index.get.ts
const redirectUri = 'https://meu-worker.workers.dev/auth/google/callback'

// server/routes/auth/google/callback.get.ts
const redirectUri = 'https://meu-worker.workers.dev/auth/google/callback'
```

#### Causa C: Rotas OAuth nomeadas incorretamente

**Sintoma:** Após o Google redirecionar, aparece `404 Page not found: /auth/google/callback`

**Por que acontece:** Se o arquivo se chamar `google.get.ts`, a rota será apenas `/auth/google` (sem `/callback`).

**Solução:** Use a estrutura correta:
```
server/routes/auth/google/
├── index.get.ts      → /auth/google
└── callback.get.ts   → /auth/google/callback
```

### ⚠️ Erro 2: `404 Page not found: /auth/google/callback`

**Sintoma:**
```
404
Page not found: /auth/google/callback?iss=...&code=...
```

**Causa:** O handler OAuth está no arquivo errado (`google.get.ts` em vez de `google/callback.get.ts`).

**Solução:** Reorganize as rotas conforme a [Seção 9](#9-oauth--handlers-google).

### Erro 3: `Binding 'DB' requires ES module format`

**Causa:** Nuxt está gerando Service Worker (não ES Module).

**Quando acontece:**
- Durante o `npx wrangler deploy`
- Usando preset `cloudflare` ao invés de `cloudflare-module`

**Solução:** No `nuxt.config.ts`:
```ts
nitro: { preset: 'cloudflare-module' }  // ← ES Module
```

**Verificação:**
```bash
npm run build
# Procure por: ● Nitro preset: cloudflare-module
```

### Erro 4: `User not found` no `/api/me`

**Causa:** Usuário logou mas não foi salvo no D1.

**Solução:** Aplique as migrações:
```bash
npx wrangler d1 execute meu-db \
  --file server/migrations/001_create_tables.sql \
  --remote
```

### Erro 5: `401 Unauthorized`

**Causa:** Sessão expirada ou não existe.

**Solução:** Verifique se `NUXT_SESSION_PASSWORD` está configurado e ≥32 caracteres.

### Erro 6: Token error no callback OAuth

**Sintoma:** No console aparece `[OAUTH] Token error: { error: 'invalid_grant', ... }`

**Causas:**
- `redirect_uri` não bate entre o request inicial e o callback
- Código já foi usado (Google OAuth codes são single-use)
- Client ID/Secret incorretos

**Solução:** Verifique se o `redirect_uri` é **idêntico** em ambas as chamadas (início e callback).

### Dev local não salva dados

**Causa:** Dev server não foi reiniciado após criar os mocks.

**Solução:**
```bash
# Pare o dev server (Ctrl+C)
npm run dev  # Reinicie
```

---

## 19. Checklist de Segurança

### Antes de Fazer Deploy

- [ ] `.env` está no `.gitignore`
- [ ] `.env.example` tem apenas placeholders (sem secrets reais)
- [ ] `data-local/` está no `.gitignore`
- [ ] `NUXT_SESSION_PASSWORD` tem ≥32 caracteres
- [ ] Secrets configurados via `wrangler secret put` (não no código)
- [ ] `wrangler.toml` tem IDs corretos de D1/KV
- [ ] URIs de redirecionamento no Google Console incluem produção e dev
- [ ] `NODE_ENV=production` nas variáveis de produção
- [ ] Build passa sem erros (`npm run build`)
- [ ] Lint passa sem erros (`npm run lint`)
- [ ] Preset Nitro é `cloudflare-module` (verifique no output do build)
- [ ] Handlers OAuth usam HTTPS explícito no `redirect_uri`
- [ ] Rotas OAuth estão em `google/index.get.ts` e `google/callback.get.ts`

### Após o Deploy

- [ ] Acessar URL de produção funciona
- [ ] Login com Google redireciona corretamente
- [ ] Callback `/auth/google/callback` não retorna 404
- [ ] Dados do usuário são salvos no D1
- [ ] Sessão persiste após refresh
- [ ] Logout funciona
- [ ] API `/api/me` retorna dados do usuário
- [ ] Nenhum secret exposto no código fonte (git history)
- [ ] `redirect_uri` na URL do Google usa HTTPS (não HTTP)

---

## 20. Referências

- [nuxt-auth-utils Docs](https://github.com/Atinux/nuxt-auth-utils)
- [Nitro Presets — Cloudflare Module](https://nitro.unjs.io/deploy/cloudflare)
- [Cloudflare Workers — ES Modules](https://developers.cloudflare.com/workers/reference/migrate-to-module-workers/)
- [Cloudflare D1 Docs](https://developers.cloudflare.com/d1/)
- [Cloudflare KV Docs](https://developers.cloudflare.com/kv/)
- [Cloudflare Secrets](https://developers.cloudflare.com/workers/configuration/secrets/)
- [Google OAuth 2.0 Docs](https://developers.google.com/identity/protocols/oauth2)
- [Wrangler Docs](https://developers.cloudflare.com/workers/wrangler/)
- [OAuth 2.0 Redirect URI Mismatch](https://developers.google.com/identity/protocols/oauth2/web-server#authorization-errors-redirect-uri-mismatch)

---

## Histórico de Correções

### Correção 1: redirect_uri_mismatch

**Data:** 12/04/2026

**Problema:** Erro 400 `redirect_uri_mismatch` persistente mesmo com URI cadastrado no Google Console.

**Causa Raiz:** O nuxt-auth-utils usa `getRequestURL(event)` do h3 para construir o `redirect_uri` automaticamente. Em Cloudflare Workers, esta função retorna `http://` internamente (mesmo para tráfego HTTPS do cliente), porque os Workers operam atrás de um proxy SSL.

**Solução Aplicada:** Substituição completa de `defineOAuthGoogleEventHandler` por handlers manuais com `redirect_uri` HTTPS forçado explicitamente em ambas as rotas (`/auth/google` e `/auth/google/callback`).

### Correção 2: 404 no callback

**Data:** 12/04/2026

**Problema:** Google OAuth funcionava (sem mais redirect_uri_mismatch) mas retornava `404 Page not found: /auth/google/callback`.

**Causa Raiz:** Arquivo `google.get.ts` gera apenas a rota `/auth/google`. O callback do Google precisa de `/auth/google/callback` como rota separada.

**Solução Aplicada:** Reorganização da estrutura de rotas para:
- `google/index.get.ts` → `/auth/google` (inicia OAuth)
- `google/callback.get.ts` → `/auth/google/callback` (processa retorno)
