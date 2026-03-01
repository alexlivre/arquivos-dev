# Inkpage UI Kit & Design System

Bem-vindo ao guia oficial de componentes da Inkpage. Este documento serve como referência para manter a consistência visual e técnica em todos os projetos da agência.

Cada componente inclui:
1.  **Código:** HTML + Tailwind CSS pronto para copiar.
2.  **Visual:** Descrição do comportamento.
3.  **Técnica:** Explicação detalhada dos efeitos (FX).

---

## 1. Inkpage Agency Badge (Standalone)

O selo de autoria digital da Inkpage. Discreto, elegante e com micro-interações premium. Ideal para rodapés minimalistas ou áreas de crédito flutuantes.

```html
<!-- Inkpage Agency Badge (Standalone) -->
<a href="https://www.inkpage.com.br" target="_blank" rel="noopener"
  class="group relative flex items-center gap-3 px-4 py-2.5 rounded-xl bg-slate-50/50 hover:bg-white border border-slate-200/60 hover:border-purple-200/60 shadow-sm hover:shadow-lg hover:shadow-purple-100/50 transition-all duration-300 overflow-hidden inline-flex">

  <!-- Visual Shine Effect -->
  <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/60 to-transparent -translate-x-full group-hover:translate-x-full duration-1000 transition-transform ease-in-out"></div>
  
  <div class="flex flex-col items-end relative z-10">
    <span
      class="text-[9px] font-extrabold text-slate-400 uppercase tracking-widest group-hover:text-purple-600 transition-colors duration-300">
      Presença Digital
    </span>
    <span class="font-display text-sm font-bold text-slate-700 group-hover:text-transparent group-hover:bg-clip-text group-hover:bg-gradient-to-r group-hover:from-purple-600 group-hover:to-fuchsia-600 transition-all duration-300 leading-tight">
      Inkpage
    </span>
  </div>

  <div
    class="relative w-9 h-9 rounded-lg bg-slate-100 border border-slate-200/50 group-hover:border-purple-200 group-hover:bg-gradient-to-br group-hover:from-purple-600 group-hover:to-fuchsia-600 flex items-center justify-center transition-all duration-300 shadow-inner group-hover:shadow-lg z-10">
    <!-- Certifique-se de ter o logo-inkpage.svg -->
    <img src="public/images/logo-inkpage.svg" alt="Logo Inkpage"
      class="w-5 h-5 opacity-40 grayscale group-hover:grayscale-0 group-hover:opacity-100 group-hover:brightness-0 group-hover:invert transition-all duration-300">
  </div>
</a>
```

### Detalhes Técnicos (FX)
- **Shine Effect:** Uma `div` absoluta com gradiente transparente desliza horizontalmente no hover.
- **Gradient Text:** `bg-clip-text` aplica o gradiente da marca apenas no texto "Inkpage".
- **Logo Transition:** `grayscale` + `opacity` inicial transforma-se em `brightness-0 invert` (branco puro) no hover.

---

## 2. Inkpage Standard Footer (Full Component)

O rodapé completo e padronizado. Inclui o container com efeito de vidro (Glassmorphism), área para a marca do cliente e o Badge Inkpage integrado.

```html
<!-- Inkpage Standard Footer -->
<footer class="mt-20 py-10 bg-white/60 backdrop-blur-md border-t border-white/50">
    <div class="max-w-6xl mx-auto px-6 flex flex-col md:flex-row items-center justify-between gap-8">
      
      <!-- Lado Esquerdo: Marca do Cliente -->
      <div class="flex flex-col items-center md:items-start gap-2">
        <div class="flex items-center gap-3 opacity-90">
          <!-- TODO: Logo do Cliente -->
          <img src="public/images/logo-comunidade.webp" alt="Logo do Cliente"
            class="w-8 h-8 rounded-full border border-slate-200 shadow-sm">
          <span class="font-display text-base font-bold text-slate-700 tracking-wide">Nome do Projeto</span>
        </div>
        <div class="text-xs text-slate-500 font-medium md:pl-11">
          &copy; 2026 Todos os direitos reservados.
        </div>
      </div>

      <!-- Lado Direito: Inkpage Badge -->
      <!-- (Código do Badge acima) -->
      <a href="https://www.inkpage.com.br" target="_blank" rel="noopener"
        class="group relative flex items-center gap-3 px-4 py-2.5 rounded-xl bg-slate-50/50 hover:bg-white border border-slate-200/60 hover:border-purple-200/60 shadow-sm hover:shadow-lg hover:shadow-purple-100/50 transition-all duration-300 overflow-hidden">
        
        <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/60 to-transparent -translate-x-full group-hover:translate-x-full duration-1000 transition-transform ease-in-out"></div>
        
        <div class="flex flex-col items-end relative z-10">
          <span class="text-[9px] font-extrabold text-slate-400 uppercase tracking-widest group-hover:text-purple-600 transition-colors duration-300">Presença Digital</span>
          <span class="font-display text-sm font-bold text-slate-700 group-hover:text-transparent group-hover:bg-clip-text group-hover:bg-gradient-to-r group-hover:from-purple-600 group-hover:to-fuchsia-600 transition-all duration-300 leading-tight">Inkpage</span>
        </div>

        <div class="relative w-9 h-9 rounded-lg bg-slate-100 border border-slate-200/50 group-hover:border-purple-200 group-hover:bg-gradient-to-br group-hover:from-purple-600 group-hover:to-fuchsia-600 flex items-center justify-center transition-all duration-300 shadow-inner group-hover:shadow-lg z-10">
          <img src="public/images/logo-inkpage.svg" alt="Logo Inkpage" class="w-5 h-5 opacity-40 grayscale group-hover:grayscale-0 group-hover:opacity-100 group-hover:brightness-0 group-hover:invert transition-all duration-300">
        </div>
      </a>

    </div>
  </footer>
```

### Detalhes Técnicos (Footer)
- **Glassmorphism:** `bg-white/60` (transparência) + `backdrop-blur-md` (desfoque do fundo) cria a estética de vidro fosco.
- **Hierarquia:** Separação clara entre a marca do projeto (esquerda) e a assinatura da agência (direita).

---

## 3. Shine Button (CTA Primary)

Botão de chamada para ação (CTA) com gradiente e efeito de brilho intenso. Ideal para conversão (ex: "Comprar", "Inscrever-se").

```html
<!-- Shine Button (CTA) -->
<a href="#" 
   class="inline-flex items-center justify-center relative overflow-hidden gap-3 px-8 py-4 text-lg font-bold text-white bg-slate-900 rounded-full hover:bg-slate-800 hover:shadow-2xl hover:shadow-purple-500/20 transition-all duration-300 transform hover:-translate-y-1 group">
  
  <!-- Shine Effect (40% Opacity for Dark BG) -->
  <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/40 to-transparent -translate-x-full group-hover:translate-x-full duration-1000 transition-transform ease-in-out"></div>
  
  <!-- Icon (Optional) -->
  <svg class="w-6 h-6 fill-current" viewBox="0 0 24 24">
    <!-- SVG Content -->
  </svg>
  
  <!-- Text with Animated Underline -->
  <span class="relative mr-1">
    Texto do Botão
    <span class="absolute left-0 -bottom-1 w-0 h-[2px] bg-gradient-to-r from-fuchsia-500 via-white to-fuchsia-500 group-hover:w-full transition-all duration-1000 ease-in-out opacity-80 shadow-[0_0_8px_rgba(217,70,239,0.5)]"></span>
  </span>
</a>
```

### Detalhes Técnicos (Button)
- **Shine Opacity:** Note que usamos `via-white/40` (e não 60%) porque o fundo do botão é muito escuro (`bg-slate-900`), o que faria o brilho "estourar" se fosse mais forte.
- **Animated Underline:** O sublinhado (`absolute h-[2px]`) expande de 0 a 100% (`w-0` -> `w-full`) em sincronia com o brilho (`duration-1000`).
- **Neon Shadow:** A linha tem uma sombra roxa brilhante (`shadow-[0_0_8px_rgba(217,70,239,0.5)]`) para um efeito cyber/high-tech.

---
**© Inkpage | Presença Digital**
