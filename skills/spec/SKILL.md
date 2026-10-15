---
name: Spec (Pato)
description: Escreve a spec de implementação em docs/specs/ antes de qualquer código. Use quando o usuário pedir "/pato/spec", "faz a spec", "escreve a especificação" ou mandar o link/chave de um card (Jira, GitHub, Linear...) ou o texto de uma tarefa para ser implementada.
---

# /pato/spec — Especificação de implementação

Produza uma spec clara, revisável e implementável para a tarefa recebida. Não escreva código de produção neste passo.

## 1. Entender o pedido

1. A entrada pode ser: URL de card (ex.: `https://empresa.atlassian.net/browse/ZH-123`, uma issue do GitHub/Linear etc.), uma chave (ex.: `ZH-123`) ou a descrição colada. Se a entrada vier vazia, pergunte o que especificar e pare.
2. Se for URL ou chave, tente ler o card com o que estiver disponível:
   - `webfetch` para páginas abertas;
   - MCP conectado (Atlassian/Jira, GitHub, Linear...) se existir — confira as ferramentas disponíveis na sessão.
   Se a página exigir login ou nada estiver conectado, **peça para o usuário colar o conteúdo do card**. Nunca invente o conteúdo.
3. Traga da fonte: título, tipo, descrição, critérios de aceite, comentários, subtarefas, itens vinculados e anexos quando acessíveis.
4. Trate o card como a fonte do pedido. Comentários recentes podem alterar a descrição; quando conflitarem, isso é ambiguidade para o passo 3.

## 2. Explorar o código

Explore o repositório o suficiente para ancorar a spec no código real: estrutura de pastas, stack, padrões existentes, módulos que serão tocados, testes existentes, `README`/`AGENTS.md`/`CLAUDE.md` e specs anteriores em `docs/specs/`.

Se o escopo tocar em telas: localize o Playwright do projeto (`playwright.config.*`, pasta de testes e2e, scripts do `package.json`) e entenda como os testes de tela rodam hoje.

## 3. Perguntar antes de assumir (OBRIGATÓRIO)

Liste para si todas as ambiguidades e lacunas. Considere no mínimo:

- Pedido sem descrição ou sem critérios de aceite claros
- Divergência entre descrição e comentários
- Objetivo e critério de "pronto" (o que precisa funcionar para aceitar)
- Escopo: o que está dentro e o que fica de fora
- Regras de negócio, casos de borda e tratamento de erro
- Dados: modelos, migrações, integrações externas, credenciais
- Interface: endpoints, telas, mensagens, contratos de API
- Compatibilidade, performance, segurança
- Conflitos entre o pedido e o que o código atual faz
- Telas: quais fluxos o usuário espera ver cobertos por testes E2E

Se houver **qualquer** ambiguidade relevante ou a tarefa estiver mal descrita:

- Pergunte ao usuário com o tool `question` (até 4 perguntas por rodada, com opções concretas e a recomendada primeiro). Faça quantas rodadas forem necessárias.
- **Não escreva a spec com suposições silenciosas.**
- Só registre algo como "Premissa" quando o usuário disser explicitamente para você decidir; deixe a premissa visível na seção de premissas.

## 4. Escrever a spec

1. Crie a pasta `docs/specs/` se não existir.
2. Nomeie o arquivo `docs/specs/<ID>-<slug-kebab-case>.md`, onde `ID` é a chave do card (ex.: `ZH-123`) ou, sem chave, a data de hoje (`AAAA-MM-DD-<slug>`).
3. Se já existir spec para esse ID, abra-a e pergunte se deve atualizá-la em vez de criar outra.
4. Preencha seguindo `references/spec-template.md`, com `status: pendente` e `card:` com a URL (ou `—`).
5. Leve para a spec os critérios de aceite do pedido (reescritos de forma testável) e acrescente os que surgirem das respostas.
6. Quebre a implementação em tarefas pequenas e verificáveis (checklist `- [ ]`), cada uma correspondendo a um commit lógico.
7. **Regra de telas (Playwright CLI):** se o escopo tocar telas, preencha a seção "Telas e fluxos E2E (Playwright)" com:
   - os fluxos que precisam ser testados (pré-condição, passos, resultado esperado);
   - a estratégia de seletores (role/label/`data-testid`, evitando CSS frágil);
   - o comando de execução, ex.: `npx playwright test e2e/<arquivo>.spec.ts`;
   - a evidência esperada (screenshot do estado final e trace em falha).
   Se o projeto ainda não tem Playwright, inclua uma tarefa de setup na spec.

## 5. Revisão com o usuário

1. Mostre um resumo curto da spec (objetivo, escopo, nº de tarefas, riscos) e o caminho do arquivo.
2. Pergunte se aprova ou quer ajustes. Aplique os ajustes no arquivo.
3. Não faça commit da spec aqui: ela entra no primeiro commit do `/pato/implement`.
4. Não altere nada no card (status, comentários) sem pedido do usuário.
5. Ao final, indique o próximo passo: `/pato/implement` (na mesma sessão, sem argumento).
