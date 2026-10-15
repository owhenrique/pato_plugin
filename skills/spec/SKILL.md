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

## 2. Explorar o código (economia de leitura)

A exploração é **graphify-first**: consulte o grafo do projeto em vez de ler arquivos, e abra só os trechos que as respostas apontarem.

1. Cheque o que existe (na raiz do projeto):

   ```bash
   command -v graphify >/dev/null && echo "graphify ok" || echo "graphify ausente"
   test -f graphify-out/graph.json && echo "grafo ok" || echo "grafo ausente"
   ```

2. **Com graphify e grafo:** mantenha o grafo atualizado e consulte:

   ```bash
   graphify check-update .        # indica se há mudanças desde a última extração
   graphify update .              # incremental; só se check-update indicar mudanças
   graphify query "<pergunta>"    # subgrafo que responde a pergunta, ex.: "onde ficam os testes E2E?"
   graphify explain "<Símbolo>"   # um nó e suas conexões
   graphify affected "<Símbolo>"  # o que depende disso antes de mudar
   graphify path "A" "B"          # como dois conceitos se conectam
   ```

   Abra arquivos apenas para confirmar o que o grafo apontou (busca por linha + leitura do trecho). `README`, `AGENTS.md`, `CLAUDE.md` e os títulos/frontmatter das specs em `docs/specs/` podem ser lidos direto — continue dirigido, nunca varra o repositório.

3. **Sem graphify ou sem grafo:** pergunte ao usuário com o tool `question` — nunca instale nem rode a extração sem confirmação:

   - **Gerar agora** (instalando o CLI se faltar): se `graphify` não estiver no PATH, instale antes (`uv tool install graphifyy`; sem `uv`, `pipx install graphifyy`; sem nenhum dos dois, peça ao usuário para instalar o CLI); gere só o código, offline: `graphify extract . --code-only`. Se `graphify-out/` não estiver versionado nem ignorado, acrescente `graphify-out/` ao `.git/info/exclude` para não sujar o git. Depois siga pelo item 2.
   - **Seguir sem graphify:** exploração dirigida — busca por símbolo (`rg -n`, `grep -n`) e leitura só dos trechos necessários; nunca varra o repositório arquivo a arquivo.

4. O que a spec precisa saber: estrutura de pastas, stack, padrões existentes, módulos que serão tocados, testes existentes. Perguntas de arquitetura ("o que chama X", "quem usa Y", "o que quebra se Z mudar") são respondidas pelo grafo; só leia código quando o grafo não responder.

5. Se o escopo tocar em telas: localize o Playwright do projeto (`playwright.config.*`, pasta de testes e2e, scripts do `package.json`) e entenda como os testes de tela rodam hoje — por busca dirigida ou pelo grafo.

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
5. Preencha **"Arquivos que a mudança toca"** com os caminhos exatos (criar/alterar/remover) que a exploração encontrou — é a lista que limita a leitura do `/pato/implement` e o escopo do `/pato/verify`.
6. Leve para a spec os critérios de aceite do pedido (reescritos de forma testável) e acrescente os que surgirem das respostas.
7. Quebre a implementação em tarefas pequenas e verificáveis (checklist `- [ ]`), cada uma correspondendo a um commit lógico.
8. **Regra de telas (Playwright CLI):** se o escopo tocar telas, preencha a seção "Telas e fluxos E2E (Playwright)" com:
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
