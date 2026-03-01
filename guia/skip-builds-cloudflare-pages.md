# Guia para Pular e Controlar Builds no Cloudflare Pages com GitHub

Este guia explica como gerenciar os builds automáticos no Cloudflare Pages quando você usa integração com GitHub, permitindo pular builds quando necessário e retomá-los quando quiser.

## 📌 Introdução Rápida

No Cloudflare Pages com GitHub, você pode **"pular" o build** usando prefixos específicos na mensagem do commit. Quando quiser **"autorizar"** (permitir o build), basta fazer um push com commit sem esse prefixo ou usar um Deploy Hook.

---

## ⏸️ Como Pular o Build (GitHub)

### Prefixos que Pulam o Build
Coloque **um destes prefixos** no início da mensagem do commit (não diferencia maiúsculas/minúsculas):
- `[CI Skip]`
- `[CI-Skip]`
- `[Skip CI]`
- `[Skip-CI]`
- `[CF-Pages-Skip]`

Quando você fizer push desse commit para a branch conectada, o Pages **omitirá o deploy/build** desse push.

### Exemplos Práticos

#### Via Terminal (Git)
```bash
git commit -m "[CI Skip] Ajuste pequeno (sem deploy)"
git push
```

#### No Site do GitHub
Ao editar um arquivo no GitHub, no campo **"Commit changes"**, comece com um dos prefixos:
```
[CI Skip] Ajuste de documentação
```
Em seguida, confirme o commit normalmente.

### Observação Importante
Quando um build é pulado por esse motivo, o **"check run/status"** do Pages pode não aparecer naquele commit no GitHub.

---

## ▶️ Como "Autorizar" e Fazer Build Quando Quiser

### Método 1: Commit Normal (Recomendado)
O Pages faz deploy automaticamente sempre que você faz push de uma mudança para uma branch conectada. Para voltar a buildar:

1. Faça um commit **sem o prefixo de skip**
2. Dê push para a branch

```bash
git commit -m "Correção crítica - precisa de deploy"
git push
```

**Dica prática**: Se você fez vários commits com `[CI Skip]` e depois faz um commit sem o prefixo, esse build incluirá **todas as mudanças acumuladas** na branch até aquele momento.

### Método 2: Deploy Hook (Sem Novo Commit)
Use um **Deploy Hook** para disparar um build via HTTP POST, sem depender de novo commit.

#### Configurando o Deploy Hook
1. Acesse o painel da Cloudflare
2. Vá para **Workers & Pages** → seu projeto → **Settings** → **Builds**
3. Clique em **"Add deploy hook"**
4. Escolha um nome e selecione a branch para buildar
5. Copie a URL gerada

#### Usando o Deploy Hook
Com `curl` no terminal:
```bash
curl -X POST "https://api.cloudflare.com/client/v4/pages/webhooks/deploy_hooks/SEU_TOKEN_AQUI"
```

Ou usando qualquer cliente HTTP que suporte POST.

### ⚠️ Atenção com Deploy Hooks
- Deploy Hooks **não exigem autenticação extra**
- **Trate a URL como segredo** (se vazar, apague e gere outra)
- Para regenerar: vá em **Settings** → **Builds**, encontre o hook e use **"Regenerate"** ou **"Delete"**

---

## 📋 Fluxo de Trabalho Recomendado

1. **Desenvolvimento normal**: Commits sem prefixo → build automático
2. **Ajustes menores**: Use `[CI Skip]` no commit para evitar build desnecessário
3. **Quando pronto para produção**: Commit sem prefixo ou use Deploy Hook
4. **Builds manuais sob demanda**: Configure e use Deploy Hooks

## 🔄 Resumo dos Comandos Úteis

| Situação | Comando/Prática |
|----------|-----------------|
| Pular build | `git commit -m "[CI Skip] mensagem"` |
| Build normal | `git commit -m "mensagem normal"` |
| Build sem commit | `curl -X POST URL_DO_DEPLOY_HOOK` |
| Verificar status | Confira na aba "Actions" do seu repositório GitHub |

---

## ❓ Dúvidas Comuns

**Q: Posso usar esses prefixos em qualquer branch?**  
R: Sim, funcionam em qualquer branch conectada ao Cloudflare Pages.

**Q: E se eu esquecer e fazer commit com [CI Skip] sem querer?**  
R: Basta fazer outro commit sem o prefixo ou usar um Deploy Hook para forçar o build.

**Q: O Deploy Hook builda qual versão do código?**  
R: A versão mais recente da branch que você configurou no hook.

**Q: Posso ter múltiplos Deploy Hooks?**  
R: Sim, você pode criar vários hooks para diferentes branches ou propósitos.

---

Este guia cobre as principais formas de controlar seus builds no Cloudflare Pages. Use os prefixos de skip para otimizar seu fluxo de trabalho e evitar builds desnecessários, mantendo o controle total sobre quando seus deploys acontecem.