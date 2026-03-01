---
name: web-performance-optimizer-no-layout-ptbr
description: ATIVE SEMPRE que o usuário pedir para otimizar velocidade, performance, PageSpeed, Lighthouse ou Core Web Vitals (LCP/INP/CLS) SEM alterar o layout visual. Cobre imagens, fontes, CSS/JS, cache, delivery, HTTP requests, resource hints e percepção UX. Não redesenha nada.
---

# Web Performance Optimizer (Sem alterar layout) — PT-BR

## Instructions
Siga este guia passo a passo sempre que a skill for ativada.

### 1. **Identifique a solicitação e ative a skill**
- Ative quando o usuário mencionar: otimizar velocidade, PageSpeed, Lighthouse, Core Web Vitals, LCP/INP/CLS, imagens pesadas, CSS/JS bloqueando, render-blocking, cache, lazy-load, requisições HTTP, CDN, fontes lentas, preload, minificar.

### 2. **Entenda o objetivo e as restrições**
- **Objetivo**: Diagnosticar e corrigir gargalos de performance mantendo o layout **exatamente igual** (mesma aparência, hierarquia e comportamento visual).
- **Não faça**: Redesenhar layout, trocar componentes, mudar copy, alterar imagem de conteúdo, esconder conteúdo ou alterar funcionalidade.
- **Métricas-alvo (Core Web Vitals)**:
  - **LCP** (Largest Contentful Paint): ≤ 2,5s (bom), > 4s (ruim)
  - **INP** (Interaction to Next Paint): ≤ 200ms (bom), > 500ms (ruim)
  - **CLS** (Cumulative Layout Shift): ≤ 0,1 (bom), > 0,25 (ruim)

### 3. **Colete os inputs necessários (se faltarem)**
Faça no máximo 6 perguntas objetivas:
   1. URL/ambiente e stack (HTML estático, WordPress, Next.js, etc.).
   2. Onde ficam os assets (local, CDN, S3, WP Media).
   3. Build disponível (Webpack/Vite/Next/etc.)? Pode gerar novos arquivos?
   4. Objetivo principal (LCP, reduzir KB total, nota PageSpeed).
   5. Restrições de browser/dispositivo.
   6. Ferramentas permitidas (Sharp, ImageMagick, plugin WP, CI/CD).

### 4. **Execute a auditoria inicial (baseline)**
- Meça com Lighthouse/PageSpeed Insights antes de qualquer mudança.
- Identifique: elemento LCP (frequentemente hero), maiores assets, render-blocking, oportunidades de cache.
- Registre as métricas para comparação posterior.

### 5. **Otimize as imagens (maior ganho individual)**
- **Serva no tamanho real de exibição**: Não envie imagem maior que o necessário; gere variantes com `srcset`/`sizes`.
- **Use formatos modernos**: Prefira WebP, avalie AVIF; use `<picture>` com fallback.
- **Evite Layout Shift (CLS)**: Declare `width` e `height` no `<img>` ou use `aspect-ratio` no CSS.
- **Carregamento inteligente**: 
  - Imagens abaixo da dobra: `loading="lazy"`.
  - Imagem hero/LCP (acima da dobra): **nunca** use `lazy`; considere `fetchpriority="high"` (máx. 1–2 por página).
  - Use `decoding="async"` na maioria das imagens.

### 6. **Otimize CSS e JavaScript**
- **Minifique e organize**: Use Terser (JS), cssnano (CSS) ou automatize no build.
- **Elimine render-blocking**: Use `defer`/`async` em scripts; mova `<script>` para final do `<body>` se necessário.
- **Remova código morto**: Tree-shaking para JS; PurgeCSS/UnCSS para CSS não usado.
- **Code splitting**: Divida JS em chunks; use dynamic imports para carregar sob demanda.

### 7. **Otimize fontes**
- **Auto-hospede e use WOFF2**: Hospede localmente; remova links externos no `<head>`; converta para `.woff2`.
- **Defina `font-display`**: Use `fallback` ou `optional` para fontes menos críticas; `swap` para tipografia central.
- **Preload seletivo**: Use `<link rel="preload">` apenas para a fonte mais importante (acima da dobra).

### 8. **Reduza HTTP Requests**
- **Combine arquivos**: Unifique múltiplos CSS/JS quando possível (bundling).
- **Inline CSS crítico**: Extraia e coloque inline o CSS necessário para "above-the-fold".
- **Use HTTP/2 ou HTTP/3**: Verifique se o servidor suporta para melhorar multiplexing.

### 9. **Use Resource Hints estrategicamente**
- `dns-prefetch`: Para domínios externos.
- `preconnect`: Para domínios críticos (máx. 2–4).
- `preload`: Para recursos críticos (fonte, hero image, CSS above-fold).
- `prefetch`: Para recursos de próximas navegações.

### 10. **Configure cache e compressão**
- Headers `Cache-Control` com `max-age` longo para assets estáticos (com hash no nome).
- Use CDN para entrega geográfica e cache na borda.
- Ative compressão **Brotli** (ou Gzip como fallback) para assets de texto.

### 11. **Controle scripts de terceiros**
- Adie carregamento (após evento `load`) para analytics, chat, pixels.
- Use `async` ou `defer`; nunca bloqueie o render.
- Audite e remova scripts desnecessários.

### 12. **Melhore a percepção visual (Mobile)**
- Adicione `<meta name="theme-color" content="#HEX">` no `<head>` (cor de fundo predominante do site).

### 13. **Formate a saída (entregável)**
Sempre entregue neste formato:

**A) Diagnóstico (top 10)**
Lista objetiva dos maiores desperdícios com "onde acontece" e "o que fazer".

**B) Plano de otimização (sem layout)**
- Imagens: tabela `[arquivo atual → novos arquivos]` com tamanhos, formato e referência.
- CSS/JS: lista do que minificar, defer/async, dead code.
- Fontes: estratégia de formato `.woff2`, deleção de links externos, `font-display`.
- UX: Sugestão de cor para `theme-color`.
- Cache/CDN: política de headers por tipo de asset.
- Resource hints: lista de domínios com `preconnect/dns-prefetch`.

**C) Implementação (passo a passo)**
Passos concretos por stack. Sempre incluir checklist de "não mudou o layout".
**Ação obrigatória final**: Instrua o usuário a rodar o comando de build de produção (ex: `npm run build`) para garantir minificação.

**D) Validação**
- Compare métricas antes/depois (Lighthouse/PageSpeed Insights).
- Teste em conexão lenta e mobile.

**E) Rollback**
Como reverter cada mudança rapidamente.

### 14. **Respeite as restrições (NÃO FAÇA)**
- Não mude layout, componentes, copy ou crop de imagens.
- Não mantenha links para serviços de fontes externas se optou por auto-hospedar.
- Não use `fetchpriority="high"` em mais de 1–2 recursos por página.
- Não recomende `loading="lazy"` para imagens above-the-fold.
- Não invente números; use medições reais.
- Não ative compressão de imagem com qualidade perceptivelmente baixa.

## Examples

### Exemplo 1 — Otimização de página WordPress lenta
**Solicitação do usuário**:  
"Minha página inicial no WordPress está com LCP de 5s. Otimize sem mudar o visual."

**Ações do assistente (resumo)**:
- Perguntar: stack (WordPress), assets (WP Media), plugins, objetivo (melhorar LCP).
- Auditoria Lighthouse para identificar gargalos (ex.: imagens grandes, fontes externas, CSS/JS bloqueantes).
- Entregar plano com: otimização de imagens (converter para WebP, srcset), remoção de fontes do Google Fonts (auto-hospedar WOFF2), defer/async em scripts, configuração de cache via plugin.
- Incluir instruções passo a passo para WordPress (plugins recomendados, edição de functions.php).
- Validar com nova auditoria e comparar métricas.

### Exemplo 2 — Aplicação Next.js com CLS alto
**Solicitação do usuário**:  
"Meu site em Next.js tem CLS de 0,3. Corrija sem alterar o layout."

**Ações do assistente (resumo)**:
- Perguntar: build (Next.js), assets (CDN), objetivo (reduzir CLS).
- Identificar causas de layout shift (imagens sem dimensões, fontes sem `font-display`, ads dinâmicos).
- Entregar plano com: adição de width/height em todas as imagens, `font-display: optional` nas fontes, preload de fontes críticas, ajuste de `theme-color`.
- Incluir instruções para Next.js (configuração do `next.config.js`, uso do componente Image).
- Validar CLS após implementação.

### Exemplo 3 — Site estático com muitas requisições
**Solicitação do usuário**:  
"Meu site HTML estático tem 80 requisições. Reduza sem mudar nada visualmente."

**Ações do assistente (resumo)**:
- Perguntar: estrutura de arquivos, uso de CDN, ferramentas de build.
- Auditar requisições (ex.: múltiplos CSS/JS, fontes, ícones).
- Entregar plano com: combinação de arquivos CSS/JS, conversão de ícones para SVG sprite, auto-hospedagem de fontes, uso de `preconnect` para domínios críticos.
- Incluir scripts para automatizar minificação e bundling.
- Validar redução de requisições e melhoria no PageSpeed.
