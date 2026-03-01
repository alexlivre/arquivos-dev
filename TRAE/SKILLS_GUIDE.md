# Guia Completo de Criação de Skills para o Antigravity

O **Google Antigravity** é uma IDE agêntica que usa Skills como módulos especializados para estender as capacidades do agente sob demanda, transformando o modelo generalista Gemini 3 em um especialista altamente focado para tarefas específicas. [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)

***

## O Que São Skills?

Skills são pacotes baseados em diretórios que contêm um arquivo de definição (`SKILL.md`) e ativos opcionais de suporte (scripts, referências, templates).  Diferentemente de um System Prompt (sempre carregado), uma Skill é injetada no contexto do agente **somente quando ele identifica relevância** para a solicitação atual — uma arquitetura chamada de *Progressive Disclosure*. [antigravity](https://antigravity.google/docs/skills)

Isso resolve o problema de **Context Saturation**: projetos grandes com dezenas de ferramentas carregadas indiscriminadamente causam alta latência, desperdício de tokens e "context rot", onde o modelo se confunde com dados irrelevantes. [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)

***

## Skills vs. Outros Mecanismos

| Mecanismo | Ativação | Finalidade |
|---|---|---|
| **Rules** | Sempre ativa (passiva) | Guardrails globais permanentes  [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills) |
| **Skills** | Ativada pelo agente (automática) | Conhecimento especializado sob demanda  [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills) |
| **Workflows** | Ativada pelo usuário (ex: `/test`) | Macros explicitamente disparadas  [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills) |
| **MCP Servers** | Persistente (stateful) | Conexões pesadas com sistemas externos  [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills) |

***

## Escopo das Skills

Skills podem existir em dois escopos distintos: [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)

- **Workspace (projeto):** Localização: `.agent/skills/` na raiz do workspace. Ideal para scripts de deploy específicos do projeto, gerenciamento de banco de dados daquela aplicação ou boilerplate de frameworks proprietários.
- **Global (usuário):** Localização: `~/.gemini/antigravity/skills/`. Disponível em todos os projetos; ideal para utilitários gerais como formatação de commits, geração de UUIDs ou revisão de estilo de código.

***

## Estrutura de Diretórios

A estrutura padrão de uma Skill é simples e separa instruções, lógica e conhecimento: [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)

```
minha-skill/
├── SKILL.md            # Arquivo de definição (obrigatório)
├── scripts/            # [Opcional] Scripts Python, Bash ou Node
│   ├── run.py
│   └── util.sh
├── references/         # [Opcional] Documentação ou templates
│   └── api-docs.md
└── assets/             # [Opcional] Ativos estáticos (imagens, logos)
```

***

## O Arquivo SKILL.md

O `SKILL.md` é o cérebro da Skill e tem duas partes obrigatórias: [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)

### YAML Frontmatter (metadados)

```yaml
---
name: nome-da-skill
description: Descrição precisa de quando o agente deve usar esta skill. Use quando o usuário pedir para X ou Y.
---
```

- **`name`:** Único no escopo; use letras minúsculas e hífens. Se omitido, usa o nome do diretório. [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)
- **`description`:** Campo **mais crítico**. Funciona como "frase de gatilho" para o roteador semântico do agente. Seja específico: "Executa queries SQL somente-leitura no banco PostgreSQL local para recuperar dados de usuários ou transações" é muito melhor que "Ferramentas de banco de dados". [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)

### Corpo em Markdown (instruções)

O corpo é "engenharia de prompt persistida em arquivo". Inclua: [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)

```markdown
## Objetivo
Descrição clara do que a skill realiza.

## Instruções
1. Passo 1...
2. Passo 2...

## Constraints
- Nunca faça X.
- Se Y acontecer, faça Z.

## Exemplo
Input: ...
Output: ...
```

***

## Os 5 Níveis de Complexidade

### Nível 1 — Roteador Básico (`git-commit-formatter`)

O "Hello World" das Skills. Apenas um `SKILL.md` com instruções textuais. Sem scripts ou arquivos extras. [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)

```
git-commit-formatter/
└── SKILL.md
```

**Caso de uso:** Formatar mensagens de commit seguindo a especificação *Conventional Commits* automaticamente ao pedir `Commit these changes`. [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)

***

### Nível 2 — Utilização de Assets (`license-header-adder`)

Usa a pasta `references/` para armazenar texto estático pesado (como headers de licença de 20 linhas), evitando desperdício de tokens no `SKILL.md`. [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)

```
license-header-adder/
├── SKILL.md
└── resources/
    └── HEADER_TEMPLATE.txt
```

O `SKILL.md` instrui o agente a **ler o arquivo de referência** antes de agir, garantindo precisão em textos legais. [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)

***

### Nível 3 — Aprendizado por Exemplos (`json-to-pydantic`)

Usa a pasta `examples/` com pares de entrada/saída para *few-shot learning*. LLMs são motores de correspondência de padrões — mostrar exemplos concretos costuma ser mais eficaz que regras verbose. [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)

```
json-to-pydantic/
├── SKILL.md
└── examples/
    ├── input_data.json   # Estado "antes"
    └── output_model.py   # Estado "depois"
```

**Caso de uso:** Converter JSON de APIs em modelos Pydantic com estilo consistente de imports, nomes e tipagem. [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)

***

### Nível 4 — Lógica Procedural com Scripts (`database-schema-validator`)

Delega verificações a scripts determinísticos. Em vez de o LLM "adivinhar" se um schema SQL é válido, um script Python retorna saída binária (exit code 0 ou 1). [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)

```
database-schema-validator/
├── SKILL.md
└── scripts/
    └── validate_schema.py
```

No `SKILL.md`, instrua o agente a **executar o script via `run_command`** e interpretar o código de saída, em vez de analisar o arquivo manualmente. [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)

***

### Nível 5 — O Arquiteto (`adk-tool-scaffold`)

Combina scripts, templates e exemplos para tarefas complexas de múltiplas etapas. Este padrão cobre a maioria dos recursos disponíveis em Skills. [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)

```
adk-tool-scaffold/
├── SKILL.md
├── resources/
│   └── ToolTemplate.py.hbs   # Template Jinja2
├── scripts/
│   └── scaffold_tool.py      # Script gerador
└── examples/
    └── WeatherTool.py         # Implementação de referência
```

**Fluxo:** O agente (1) roda o script de scaffold para criar o arquivo inicial, (2) lê o exemplo para entender o estilo, e (3) refina o código gerado com lógica real. [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)

***

## Boas Práticas

- **Uma skill, uma responsabilidade:** Crie skills focadas em vez de uma skill "faz-tudo". [antigravity](https://antigravity.google/docs/skills)
- **`description` precisa:** É o único campo indexado pelo roteador — invista tempo nele. Uma descrição vaga resulta em uma skill que nunca é ativada. [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)
- **Scripts para verdades determinísticas:** Use scripts quando precisar de saídas binárias ou operações que um LLM pode "alucinar" (validações, cálculos, I/O de arquivos). [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)
- **References para textos pesados:** Não coloque conteúdo estático volumoso diretamente no `SKILL.md` — use a pasta `references/` e instrua o agente a ler quando necessário. [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)
- **Composabilidade:** Uma Rule global pode forçar o uso de uma Skill específica, e um Workflow pode orquestrar múltiplas Skills para montar pipelines robustos. [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)

***

## Recursos e Repositórios

- **Documentação oficial:** [antigravity.google/docs/skills](https://antigravity.google/docs/skills) [antigravity](https://antigravity.google/docs/skills)
- **Codelab oficial do Google:** [codelabs.developers.google.com/getting-started-with-antigravity-skills](https://codelabs.developers.google.com/getting-started-with-antigravity-skills) [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills?hl=en)
- **Repositório do codelab:** [github.com/rominirani/antigravity-skills](https://github.com/rominirani/antigravity-skills) [codelabs.developers.google](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)
- **Repositório comunitário com 58+ skills prontas** cobrindo engenharia de software, design criativo, product management, TDD, Clean Architecture e mais [reddit](https://www.reddit.com/r/google_antigravity/comments/1qcuc8u/i_aggregated_58_skills_for_antigravity_into_one/)