# Windsurf Custom Rules

---

## [RULE-001] Idioma de Codificação vs. Comunicação

- **Coding Language**: Código-fonte, comentários e commits em **Inglês**.
- **Chat Language**: Interações no chat em **Português (Brasil)**.

<guidelines>
- Nunca responda em Inglês no chat.
- Se eu perguntar em Inglês, responda em Português.
</guidelines>

---

## [RULE-002] Sequência de Desenvolvimento

**Ordem obrigatória**:
1. **Clean Code**: Nomes significativos, funções pequenas, sem duplicação, legibilidade.
2. **SOLID**: Single Responsibility, Open/Closed, Liskov, Interface Segregation, Dependency Inversion.
3. **Clean Architecture**: Camadas independentes, dependências invertidas, testabilidade.

<guidelines>
- Aplique sempre nesta ordem.
- Considere usar a skill 'clean-code-solid-clean-architecture'.
</guidelines>

---

## [RULE-003] Atualização de Documentação

**Gatilhos**:
- Novos recursos, mudanças arquiteturais, correções críticas, atualizações de dependências, conclusão de fases.

**Conteúdo**:
- Atualizar seção de funcionalidades, **README.md**, roadmap, instruções de uso, requisitos.

**Status**:
- ✅ Concluído 🔄 Em Progresso 📋 Planejado ⚠️ Pendente 🚫 Cancelado

**Validação** (só é "concluído" quando):
1. Código funcional e testado.
2. Documentação no `README.md` atualizada.
3. Roadmap reflete estado atual.
4. Sem regressões.

<guidelines>
- Atualize imediatamente após mudanças.
- **Foco principal no README.md e roadmap** do projeto.
- **Confirme ao usuário**: "✅ Recurso/Fase finalizado e documentado no README.md."
- Mantenha formatação uniforme e tom profissional.
- Documente qualquer alteração em requisitos ou instruções de instalação.
</guidelines>

---

## [RULE-004] Testes Automatizados Obrigatórios

**Estrutura**:
```
test-automation/
├── scripts/
├── reports/
└── TEST_LOG.md
```

**Processo com correção**:
- **Gatilho de Ação**: Execute testes obrigatoriamente a **cada alteração** efetuada no código-fonte.
- **Validação Obrigatória**: Nenhuma tarefa deve ser considerada "concluída" sem que os testes tenham sido executados com sucesso.

1. Execute todos os testes.
2. Se houver erros → corrija → execute novamente → repita até passar.
3. Tipos obrigatórios: unitários, integração, regressão.

**Relatório** (`TEST_LOG.md`):
- Data, total de testes, passaram/falharam, cobertura.
- Lista de resultados (✅/❌).
- Ciclo de correção com horários e ações.
- Status final (APROVADO/REPROVADO).

**Critérios de aprovação**:
- Todos os testes passam (0 falhas).
- Cobertura mínima: 70%.
- Nenhuma regressão.
- Ciclo de correção completo.

<guidelines>
- Crie `test-automation/` se não existir.
- Execute testes após cada modificação.
- Não entregue código com testes falhando.
- Documente cada ciclo de correção.
- Só prossiga quando TODOS os testes passarem.
- Informe claramente o status e ações.
</guidelines>

---

## [RULE-005] Padronização de Código com ESLint

**Padronização de Linting**:
- **ESLint Obrigatório**: Sempre usar **ESLint** em qualquer código JavaScript/TypeScript do projeto.
- **Verificação Prévia**: Antes de criar configuração nova, verificar se já existe regra ou configuração de ESLint no repositório.
- **Respeito à Base**: Se existir configuração, respeitar e seguir as regras existentes.
- **Criação Padronizada**: Se não existir ESLint, criar a configuração seguindo as melhores práticas do projeto.
- **Teste de Funcionalidade**: Sempre testar se está tudo funcionando após criar ou alterar a configuração.
- **Correção Imediata**: Sempre corrigir quaisquer erros encontrados no ESLint antes de considerar a tarefa concluída.
- **Consistência Garantida**: Garantir que o código fique consistente, limpo e compatível com a base existente.
- **Resolução de Conflitos**: Se houver conflito entre regras, priorizar a configuração já existente do projeto.

<guidelines>
- Execute `npx eslint .` ou equivalente após cada alteração de código.
- Documente qualquer exceção necessária no arquivo de configuração do ESLint.
- Mantenha as regras atualizadas conforme evolução do projeto.
- Considere usar a skill 'eslint' quando disponível.
</guidelines>

---

## [RULE-006] Segurança Obrigatória

**Princípio Fundamental**: Segurança sempre tem prioridade sobre conveniência.

**Obrigações de Segurança**:
- **Princípio do Menor Privilégio**: Implementar autenticação, autorização e controle de acesso para todas as ações sensíveis.
- **Validação e Sanitização**: Toda entrada externa (usuário, API, arquivos) deve ser validada e sanitizada.
- **Proteção de Dados Sensíveis**: É proibido hardcodar segredos, expor dados confidenciais ou desabilitar proteções de segurança.
- **Análise de Vulnerabilidades**: Verificar riscos como SQL Injection, XSS, CSRF, SSRF, Path Traversal, Injeção de Comandos.
- **Gestão de Dependências**: Não usar dependências com vulnerabilidades conhecidas; manter atualizadas.
- **Logs Seguros**: Logs e mensagens de erro não podem expor informações internas ou dados confidenciais.
- **Interrupção por Segurança**: Se houver risco de segurança identificado, a implementação deve ser interrompida e substituída por alternativa segura.

**Validação de Segurança** (antes de considerar "concluído"):
1. Nenhum segredo hardcoded no código
2. Todas as entradas externas validadas
3. Controles de acesso implementados
4. Dependências verificadas por vulnerabilidades
5. Logs não expõem informações sensíveis

<guidelines>
- Segurança sempre tem prioridade sobre conveniência ou prazos.
- Nenhuma entrega é válida se introduzir brecha de segurança conhecida.
- Em caso de dúvida, escolha a opção mais restritiva e segura.
- Considere usar ferramentas de análise estática de segurança (SAST) quando disponível.
- Documente decisões de segurança importantes e compensações feitas.
</guidelines>

---

## [RULE-007] Administração Completa do Repositório GitHub via MCP

**Gestão Integral do Repositório**: Quando disponível, usar o MCP (Model Context Protocol) do GitHub para todas as operações de administração do repositório, analisando a situação e decidindo ações apropriadas.

**Escopo de Administração**:
- **Leitura e Análise**: Ler repositório, revisar código, issues, PRs, documentação e estados
- **Gerenciamento de Branches**: Criar, gerenciar, deletar (com cuidado) branches
- **Controle de Versão**: Commits, tags, releases, versionamento semântico
- **Pull Requests**: Criar, revisar, mergear, gerenciar fluxo de trabalho
- **Documentação**: Atualizar README, wiki, docs e metadados
- **Configurações**: Gerenciar configurações do repositório (com confirmação)

**Processo de Decisão**:
1. **Analisar**: Situação atual, necessidades do projeto, histórico
2. **Avaliar**: Riscos, impacto, prioridades
3. **Decidir**: Ação apropriada baseada em análise
4. **Executar**: Via MCP quando disponível, ou métodos alternativos
5. **Validar**: Resultados e consistência

**Princípios de Administração**:
- **Análise Contínua**: Sempre avaliar se ações são necessárias (commits, tags, branches, etc.)
- **Decisão Proativa**: Tomar decisões baseadas em estado do projeto e melhores práticas
- **Ação Preventiva**: Antecipar necessidades e agir antes de problemas
- **Registro Completo**: Documentar decisões e ações tomadas
- **Reversibilidade**: Preferir ações que possam ser revertidas se necessário

**Ações Automáticas** (quando analisadas como necessárias):
- ✅ **Commits**: Após alterações significativas, com mensagens descritivas
- ✅ **Branches**: Para features, hotfixes, ou experimentos
- ✅ **Tags**: Para releases, versões importantes ou marcos
- ✅ **PRs**: Para integração de código, revisão e documentação
- ✅ **Documentação**: Atualização contínua de README e docs

**Validação de Administração**:
1. Estado do repositório analisado e compreendido
2. Decisões tomadas baseadas em análise apropriada
3. Ações executadas via MCP quando disponível
4. Segurança e boas práticas mantidas
5. Repositório em estado consistente e atualizado

<guidelines>
- Use o MCP do GitHub como ferramenta principal de administração quando disponível.
- **Sempre analise a situação antes de agir**: "O que precisa ser feito? Por quê? Como?"
- **Tome decisões proativas**: Se identificar necessidade de commit, tag, branch, etc. → execute.
- **Priorize ações preventivas**: Antecipe problemas e aja para evitá-los.
- **Documente decisões**: Registre por que cada ação foi tomada.
- Se o MCP não estiver disponível, informe: "⚠️ MCP do GitHub não disponível - usando métodos alternativos."
- Considere usar a skill 'github-mcp' quando disponível para integração otimizada.
</guidelines>

---
