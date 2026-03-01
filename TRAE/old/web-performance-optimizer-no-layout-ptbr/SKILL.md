---
name: web-performance-optimizer-no-layout-ptbr
description: ATIVE SEMPRE que o usuário pedir para otimizar velocidade, performance, PageSpeed, Lighthouse ou Core Web Vitals (LCP/INP/CLS) SEM alterar o layout visual. Cobre imagens, fontes, CSS/JS, cache, delivery, HTTP requests e resource hints. Não redesenha nada.
---

# Web Performance Optimizer (Sem alterar layout) — PT-BR

## Goal
Diagnosticar e corrigir gargalos de performance em páginas web mantendo o layout **exatamente igual** (mesma aparência, hierarquia e comportamento visual).

## Non-goals (o que NÃO fazer)
- Redesenhar layout, trocar componentes, mudar copy, alterar imagem de conteúdo.
- Esconder conteúdo ou alterar funcionalidade.

## Activation rule
Ative se o pedido envolver:
- "otimizar velocidade", "PageSpeed", "Lighthouse", "Core Web Vitals", "LCP/INP/CLS".
- "imagens pesadas", "CSS/JS bloqueando", "render-blocking", "cache", "lazy-load".
- "requisições HTTP", "CDN", "fontes lentas", "preload", "minificar".

## Métricas-alvo (Core Web Vitals — Google)
- **LCP** (Largest Contentful Paint): ≤ 2,5s (bom), > 4s (ruim).
- **INP** (Interaction to Next Paint): ≤ 200ms (bom), > 500ms (ruim).
- **CLS** (Cumulative Layout Shift): ≤ 0,1 (bom), > 0,25 (ruim).

## Inputs (clarify) — máximo 6
1. URL/ambiente e stack (HTML estático, WordPress, Next.js, etc.).
2. Onde ficam os assets (local, CDN, S3, WP Media).
3. Build disponível (Webpack/Vite/Next/etc.)? Pode gerar novos arquivos?
4. Objetivo principal (LCP, reduzir KB total, nota PageSpeed).
5. Restrições de browser/dispositivo.
6. Ferramentas permitidas (Sharp, ImageMagick, plugin WP, CI/CD).

## Procedure (Runbook)

### 1) Auditoria (baseline)
- Medir com Lighthouse/PageSpeed Insights antes de qualquer mudança.
- Identificar o elemento LCP (frequentemente o hero), os maiores assets, render-blocking e oportunidades de cache.
- Registrar as métricas para comparação posterior.

---

### 2) Imagens (maior ganho individual)

**A. Servir no tamanho real de exibição**
- Nunca enviar imagem de 1000×1000 se o maior uso real é 600×600.
- Para cada imagem, mapear: "tamanho exibido na página" e "tamanho no clique/lightbox".
- Gerar variantes por tamanho e servir com `srcset`/`sizes` para o browser escolher o arquivo certo para cada viewport/DPR.

**B. Formato moderno**
- Preferir **WebP** (boa compressão lossy e lossless, suporte amplo em browsers modernos).
- Se o projeto suportar, avaliar **AVIF** (compressão ainda melhor, mas suporte menos universal — use `<picture>` com fallback).
- Usar `<picture>` para servir formatos modernos com fallback para JPEG/PNG em browsers antigos.

**C. Evitar Layout Shift (CLS)**
- Sempre declarar `width` e `height` no `<img>` para o browser reservar espaço antes do download.
- Ou usar `aspect-ratio` no CSS — nunca deixar tamanho indefinido.

**D. Carregamento inteligente**
- Imagens **abaixo da dobra**: `loading="lazy"` (adia o download até o usuário se aproximar).
- Imagem do **hero/LCP** (acima da dobra): **nunca** usar `loading="lazy"`, e considerar `fetchpriority="high"` (máximo 1–2 por página).
- `decoding="async"` na maioria das imagens; evitar forçar `sync` em imagens não-críticas.

---

### 3) CSS/JS — Reduzir peso e render-blocking

**A. Minificação**
- Minificar CSS e JS em produção (remover espaços, comentários, encurtar variáveis). Ferramentas: Terser (JS), cssnano (CSS), ou automatizar no Vite/Webpack.

**B. Eliminar render-blocking**
- Scripts sem `defer` ou `async` bloqueiam o parser HTML e atrasam o LCP.
- Usar `defer` para scripts que precisam do DOM pronto; usar `async` para scripts independentes (ex: analytics).
- Como alternativa legada: mover `<script>` para o final do `<body>`.

**C. Remover código morto**
- **Tree-shaking**: importar apenas o que usa, com ESM + bundler (Webpack/Rollup/Vite). Remover bibliotecas inteiras que podem ser substituídas por funções menores.
- **CSS não usado**: usar PurgeCSS/UnCSS para remover regras CSS que não aparecem na página em produção.

**D. Code splitting**
- Dividir JS em chunks e carregar sob demanda (dynamic imports), reduzindo o JS inicial enviado ao browser.

---

### 4) Fontes — Evitar bloqueio e FOUT/FOIT

**A. `font-display`**
- Sempre definir `font-display` no `@font-face`. Valores mais comuns:
  - `swap`: mostra texto com fallback imediatamente, troca quando a fonte carregar (risco de CLS).
  - `fallback`: aguarda ~100ms, depois usa fallback; troca se a fonte chegar antes de 3s.
  - `optional`: usa a fonte só se já estiver em cache; sem CLS, mas pode não usar a fonte no 1º acesso.
- Preferir `fallback` ou `optional` para fontes menos críticas; `swap` para tipografia central.

**B. Preload seletivo**
- Usar `<link rel="preload">` para a fonte mais importante (acima da dobra), mas com cautela — preload de muitas fontes disputa com recursos críticos.

**C. Auto-hospedar fontes**
- Hospedar fontes localmente elimina a latência de DNS/conexão com servidores externos (Google Fonts, Typekit etc.).

---

### 5) HTTP Requests — Reduzir round-trips

**A. Combinar arquivos**
- Unificar múltiplos arquivos CSS e JS quando possível (bundling), reduzindo o número de requisições.
- Evitar excesso de plugins que adicionam seus próprios arquivos CSS/JS.

**B. Inline de CSS crítico**
- Extrair e inline o CSS necessário para o "acima da dobra" (above-the-fold) e adiar o restante. Isso elimina o round-trip do CSS antes do primeiro render.

**C. HTTP/2 ou HTTP/3**
- Verificar se o servidor usa HTTP/2 (ou 3): com multiplexing, múltiplas requisições paralelas são mais eficientes; o bundling agressivo se torna menos necessário.

---

### 6) Resource Hints — Antecipar conexões e downloads

- **`dns-prefetch`**: resolve o DNS de domínios externos cedo (baixo custo, boa cobertura).
- **`preconnect`**: resolve DNS + establece TCP + TLS cedo (mais poderoso, usar só para domínios críticos — máx. 2–4).
- **`preload`**: força o download antecipado de um recurso crítico (fonte, hero image, CSS above-fold).
- **`prefetch`**: baixa recursos para *próximas navegações* (baixa prioridade, não bloqueia nada).
- Regra: `dns-prefetch` como fallback de `preconnect` para browsers que não suportam preconnect.

---

### 7) Cache — Evitar downloads repetidos

- Configurar headers `Cache-Control` com `max-age` longo para assets estáticos (imagens, CSS, JS) com hash no nome do arquivo.
- Usar CDN para entrega geográfica e cache na borda (edge).
- Ativar compressão **Brotli** (ou Gzip como fallback) para todos os assets de texto (HTML, CSS, JS, fontes).

---

### 8) Terceiros (third-party scripts) — Controlar impacto

- Analytics, chat, pixels de anúncio: adiar carregamento até após o `load` do evento principal.
- Nunca bloquear o render com scripts de terceiros (usar `async` ou `defer`).
- Auditar e remover scripts de terceiros desnecessários (cada um adiciona DNS, TCP e processamento).

---

## Output format (entregável)

### A) Diagnóstico (top 10)
Lista objetiva dos maiores desperdícios com "onde acontece" e "o que fazer".

### B) Plano de otimização (sem layout)
- **Imagens**: tabela `[arquivo atual → novos arquivos]` com tamanhos, formato e forma de referência.
- **CSS/JS**: lista do que minificar, o que tem `defer/async`, o que é dead code.
- **Fontes**: estratégia de `font-display` e preloads.
- **Cache/CDN**: política de headers por tipo de asset.
- **Resource hints**: lista de domínios com `preconnect/dns-prefetch`.

### C) Implementação (passo a passo)
Passos concretos por stack. Sempre incluir checklist de "não mudou o layout" (diff visual antes/depois).

### D) Validação
- Comparar métricas antes/depois (Lighthouse/PageSpeed Insights).
- Testar em conexão lenta e mobile.

### E) Rollback
Como reverter cada mudança rapidamente.

## Constraints (Do Not)
- Não mudar layout, componentes, copy ou crop de imagens.
- Não usar `fetchpriority="high"` em mais de 1–2 recursos por página.
- Não recomendar `loading="lazy"` para imagens above-the-fold.
- Não inventar números: métricas reportadas devem ser medições reais; estimativas devem ser explicitadas como tal.
- Não ativar compressão de imagem com qualidade tão baixa que cause perda visual perceptível.
