---
name: Spec (Pato)
description: Conversa com o usuário para definir o que vai ser desenvolvido, quebra o trabalho em histórias de usuário (US) — cada uma um entregável de até 500 linhas de lógica — e escreve em docs/specs/ a spec da próxima US antes de qualquer código. Use quando o usuário pedir "/pato/spec", "faz a spec", "escreve a especificação", "quebra em histórias", "próxima US" ou mandar o link/chave de um card (Jira, GitHub, Linear...) ou o texto de uma tarefa para ser implementada.
---

# /pato/spec — Refinamento, histórias e especificação

Defina com o usuário o que vai ser desenvolvido, quebre o trabalho em histórias de usuário (US) entregáveis e escreva a spec da próxima US. Não escreva código de produção neste passo.

## Regra de entrega

Vale para todo o fluxo: `/pato/implement`, `/pato/verify` e `/pato/close-spec` cobram a mesma regra.

- **Uma US = uma spec = uma branch = um PR** — um PR por repo tocado, quando a US atravessa mais de um repo.
- **Cada US é um entregável:** fatia vertical que entrega a história de ponta a ponta para quem usa; mergeada, deixa a base coerente e utilizável.
- **Limite de 500 linhas de lógica por US**, adicionadas ou modificadas, somando os repos. Remoção não conta; testes, documentação, configuração e dados, lockfiles, migrations e código gerado também não. Se o `AGENTS.md` do projeto definir outro limite ou outra medição, vale o do projeto.
- **Não coube? Fatie por valor** (outra US que se sustenta sozinha) ou corte escopo, sempre com o usuário. **Proibido** quebrar em parte 1/2/3 (ou a/b, P1/P2, "server" e "client" como entregáveis separados), fatiar por camada, abrir PRs por faixa de commits, empilhar PRs, esconder meia funcionalidade atrás de flag ou burlar a medição.

## 1. Entender o pedido

1. A entrada pode ser: URL de card (ex.: `https://empresa.atlassian.net/browse/ZH-123`, uma issue do GitHub/Linear etc.), uma chave (ex.: `ZH-123`), o caminho de um mapa em `docs/specs/` ou a descrição colada. Se a entrada vier vazia: havendo em `docs/specs/` um mapa com US ainda sem spec, ofereça a próxima (seção 7); senão, pergunte o que especificar e pare.
2. Se a entrada for um mapa ou o card já tiver mapa de histórias (`docs/specs/<ID>-mapa.md`), o pedido é a próxima US: vá para a seção 7. Procure também nas branches do card (`git branch -a --list '*<chave ou slug do card>*'`, lendo com `git show <branch>:<caminho>`): enquanto a US anterior não é mergeada, o mapa e a spec dela só existem na branch dela.
3. Se o card já tiver spec, mas não mapa: abra-a e pergunte se deve atualizá-la, abrir uma nova US para o mesmo card (ex.: a que foi cortada e registrada em "Fora") ou parar. Nova US cria o mapa, com a spec existente como US1 — pelo caminho atual, sem renomear — e segue pela seção 7.
4. Se for URL ou chave, tente ler o card com o que estiver disponível:
   - `webfetch` para páginas abertas;
   - MCP conectado (Atlassian/Jira, GitHub, Linear...) se existir — confira as ferramentas disponíveis na sessão.
   Se a página exigir login ou nada estiver conectado, **peça para o usuário colar o conteúdo do card**. Nunca invente o conteúdo.
5. Traga da fonte: título, tipo, descrição, critérios de aceite, comentários, subtarefas, itens vinculados e anexos quando acessíveis.
6. Trate o card como a fonte do pedido. Comentários recentes podem alterar a descrição; quando conflitarem, isso é ambiguidade para a seção 3.
7. Pedido vago demais para saber onde olhar no código? Comece pela conversa (seção 3) e explore depois.

## 2. Explorar o código (economia de leitura)

A exploração é **graphify-first**: consulte o grafo do projeto em vez de ler arquivos, e abra só os trechos que as respostas apontarem.

1. Cheque o que existe em cada repo com código que o pedido pode tocar — num workspace de repos independentes (ex.: `server/` e `client/` dentro de uma raiz só de docs), cada um deles, e não a raiz. Use só esta checagem: o `graphify check-update` não imprime nada sem grafo, nem quando o código mudou.

   ```bash
   command -v graphify >/dev/null && echo "graphify ok" || echo "graphify ausente"
   for repo in .; do                     # repos independentes: for repo in server client; do
     test -f "$repo/graphify-out/graph.json" && echo "grafo ok: $repo" || echo "grafo ausente: $repo"
   done
   ```

2. **Com graphify e grafo:** atualize e consulte dentro de cada repo (ou com `--graph <repo>/graphify-out/graph.json`):

   ```bash
   graphify update .                      # sempre, no início: incremental, segundos, sem LLM
   graphify explain "<Símbolo>"           # onde o símbolo está e quem o usa
   graphify affected "<Símbolo>"          # o que depende dele antes de mudar
   graphify path "A" "B"                  # como dois símbolos se conectam
   graphify query "<nomes do código>" --budget 800   # subgrafo a partir de símbolos, ex.: "computeSplit toSplitView"
   ```

   Pergunte por símbolos, não por frases: o `query` casa as palavras com nomes do código, e uma pergunta em português volta truncada e cheia de nós genéricos. Sem saber o nome, ache-o antes com `rg -n` e siga pelo `explain`. Abra arquivos apenas para confirmar o que o grafo apontou (busca por linha + leitura do trecho). `README`, `AGENTS.md`, `CLAUDE.md` e os títulos/frontmatter das specs em `docs/specs/` podem ser lidos direto — continue dirigido, nunca varra o repositório.

   Entre repos independentes não há aresta no grafo: o client fala com o server por HTTP e por tipos gerados, então juntar os grafos (`merge-graphs`) não acrescenta nada. A ligação entre eles é o contrato — rotas e DTOs no server, tipos gerados e chamadas da API no client.

3. **Sem graphify ou sem grafo: pare e pergunte agora**, com o tool `question`, antes de ler qualquer código além de `README`/`AGENTS.md`. A pergunta é obrigatória — não siga para a leitura dirigida por conta própria — e nunca instale nem rode a extração sem confirmação:

   - **Gerar agora** (instalando o CLI se faltar): se `graphify` não estiver no PATH, instale antes (`uv tool install graphifyy`; sem `uv`, `pipx install graphifyy`; sem nenhum dos dois, peça ao usuário para instalar o CLI); gere só o código, offline, dentro de cada repo sem grafo: `(cd <repo> && graphify extract . --code-only)`. O `extract` respeita o `.gitignore`: rodado na raiz de um workspace que ignora os repos aninhados, ele não enxerga o código deles. Se `graphify-out/` não estiver versionado nem ignorado, acrescente-o ao `.git/info/exclude` do repo para não sujar o git. Depois siga pelo item 2.
   - **Seguir sem graphify:** exploração dirigida — busca por símbolo (`rg -n`, `grep -n`) e leitura só dos trechos necessários; nunca varra o repositório arquivo a arquivo.

4. O que a spec precisa saber: estrutura de pastas, stack, padrões existentes, módulos que serão tocados, testes existentes — e o suficiente para estimar cada US (arquivos e símbolos que mudam). Perguntas de arquitetura ("o que chama X", "quem usa Y", "o que quebra se Z mudar") são respondidas pelo grafo; só leia código quando o grafo não responder.

5. Se o escopo tocar em telas: localize o Playwright do projeto (`playwright.config.*`, pasta de testes e2e, scripts do `package.json`) e entenda como os testes de tela rodam hoje — por busca dirigida ou pelo grafo.

## 3. Conversar com o usuário (OBRIGATÓRIO)

Antes de quebrar em histórias, chegue a um acordo com o usuário sobre **o que** vai ser desenvolvido. Converse em rodadas e só siga quando não houver ponto em aberto.

1. **Entendimento.** Devolva em poucas linhas o que entendeu — o problema, quem é afetado (persona), o resultado esperado e o que o código já faz hoje sobre isso — e peça para confirmar ou corrigir.
2. **Descoberta**, quando o pedido é vago ou só descreve a solução: quem usa e em que momento; como resolve hoje; o que precisa funcionar para considerar pronto; um exemplo concreto (dados, valores, tela, passo a passo).
3. **Detalhes.** Liste para si as ambiguidades e lacunas e pergunte. Considere no mínimo:
   - Pedido sem descrição ou sem critérios de aceite claros
   - Divergência entre descrição e comentários
   - Escopo: o que está dentro e o que fica de fora
   - Regras de negócio, casos de borda e tratamento de erro
   - Dados: modelos, migrações, integrações externas, credenciais
   - Interface: endpoints, telas, mensagens, contratos de API
   - Compatibilidade, performance, segurança
   - Conflitos entre o pedido e o que o código atual faz
   - Telas: quais fluxos o usuário espera ver cobertos por testes E2E
4. **Prioridade.** O que é essencial na primeira entrega (o mínimo que já resolve o problema para a persona), o que pode vir depois e o que fica fora.

Como perguntar:

- Decisão com alternativas: tool `question` (até 4 perguntas por rodada, com opções concretas e a recomendada primeiro).
- Pergunta aberta (descrever um fluxo, dar um exemplo): em texto, e espere a resposta.
- Faça quantas rodadas forem necessárias; a cada uma, diga o que ficou decidido e o que ainda falta.
- Tarefa pequena e clara: junte entendimento e proposta de história numa única confirmação (seção 4).
- **Não escreva a spec com suposições silenciosas.** Só registre algo como "Premissa" quando o usuário disser explicitamente para você decidir; deixe a premissa visível na seção de premissas.
- Guarde cada pergunta e resposta para "Decisões e respostas do usuário".

## 4. Quebrar em histórias (US)

Leia `references/historias.md` (formato, checagem, técnicas de fatiamento e anti-padrões) e proponha as histórias.

1. Cada US traz: título; **"Como <persona>, quero <capacidade>, para <benefício>."**; critérios de aceite no formato Dado/Quando/Então; estimativa de linhas de lógica; repos tocados; e de qual US anterior depende, se depender.
2. **Estime por arquivo**, a partir da exploração: o que muda em cada arquivo e quantas linhas de lógica isso dá. Mire em **até ~400 linhas por US** — estimativa costuma sair baixa, e o limite de 500 é medido no fim. Acima disso, fatie a US ou corte escopo.
3. Passe cada US pela checagem de `references/historias.md`. US que falha (não entrega valor sozinha, é uma camada, depende de outra que não estará mergeada, passa do limite) não vai para o usuário: refaça a quebra.
4. Mostre a proposta: uma tabela (US, história, estimativa, depende de) e, para cada US, os critérios de aceite e o que fica para outra US. Pergunte com o tool `question` se aprova ou quer ajustar (juntar, dividir, reordenar, cortar). Itere até aprovar. Saiu uma US só? Mostre-a no mesmo formato e confirme.
5. Comportamento que não cabe em 500 linhas nem fatiado por valor: não proponha partes técnicas. Mostre o porquê e decida com o usuário o corte (o mínimo que resolve agora; o resto vira US seguinte ou sai do card). Exceção acima de 500 só por ordem explícita do usuário, registrada em "Decisões e respostas do usuário" — não a ofereça como opção.

## 5. Escrever a spec

1. Crie a pasta `docs/specs/` se não existir.
2. O `ID` é a chave do card (ex.: `ZH-123`) ou, sem chave, a data de hoje com um slug (`AAAA-MM-DD-<slug>`).
   - **Uma US:** só a spec, `docs/specs/<ID>-<slug>.md`, com `id: <ID>`.
   - **Mais de uma US:** o mapa `docs/specs/<ID>-mapa.md`, seguindo `references/mapa-template.md`, e a spec de cada US em `docs/specs/<ID>-us<N>-<slug>.md`, com `id: <ID>-us<N>`. O mapa já nasce com o caminho da spec de cada US e só muda quando a quebra mudar.
3. Escreva agora só a spec da **primeira US**. As demais ficam no mapa, sem arquivo de spec, até chegar a vez delas (seção 7) — já com o código das anteriores na base.
4. Preencha seguindo `references/spec-template.md`, com `status: pendente`, `card:` com a URL (ou `—`), `mapa:` e `depende_de:`.
5. **História e critérios de aceite** vêm da US aprovada, reescritos de forma testável (Dado/Quando/Então), mais os que surgirem das respostas.
6. Preencha **"Arquivos que a mudança toca"** com os caminhos exatos (criar/alterar/remover), os símbolos e a estimativa de linhas de cada arquivo — é a lista que limita a leitura do `/pato/implement` e o escopo do `/pato/verify`.
7. Preencha **"Limite de tamanho"**: a estimativa (soma dos arquivos, por repo), o que não conta (arquivos gerados e o comando que os gera) e o comando de medição — o do `AGENTS.md` do projeto, se houver; senão, o do template, com a branch base e os repos do projeto.
8. Quebre a US em **tarefas** pequenas e verificáveis (checklist `- [ ]`), cada uma um commit lógico. Tarefas são passos da mesma US e entram todas no mesmo PR; nunca viram PR separado.
9. Preencha a **"Triagem de implementação"**: conte tarefas e arquivos, traga as linhas estimadas e marque tela, migração, contrato de API e dependência nova. Sugira o modo: **direto** (mesma janela) só com 1 tarefa, ≤ 3 arquivos, ≤ 50 linhas e nada mais marcado; qualquer coisa além → **agent-driven**. O `/pato/implement` confirma o modo com o usuário antes de começar.
10. **Regra de telas (Playwright CLI):** se o escopo tocar telas, preencha a seção "Telas e fluxos E2E (Playwright)" com:
    - os fluxos que precisam ser testados (pré-condição, passos, resultado esperado);
    - a estratégia de seletores (role/label/`data-testid`, evitando CSS frágil);
    - o comando de execução, ex.: `npx playwright test e2e/<arquivo>.spec.ts`;
    - a evidência esperada (screenshot do estado final e trace em falha).
    Se o projeto ainda não tem Playwright, inclua uma tarefa de setup na spec.

## 6. Revisão com o usuário

1. Mostre um resumo curto: a história (Como/quero/para), os critérios de aceite, a estimativa contra o limite de 500, o nº de tarefas, o modo sugerido pela triagem, os riscos e, com mapa, as próximas US. Indique o caminho dos arquivos.
2. Pergunte se aprova ou quer ajustes. Aplique os ajustes nos arquivos.
3. Não faça commit da spec nem do mapa aqui: eles entram no primeiro commit do `/pato/implement`.
4. Não altere nada no card (status, comentários) sem pedido do usuário.
5. Ao final, indique o próximo passo: `/pato/implement`, de preferência numa **sessão nova**. A spec carrega tudo o que a implementação precisa; a exploração feita aqui, levada junto, deixaria cada passo do implement mais caro e o modelo menos preciso.

## 7. Próxima história (card com mapa)

Quando o card já tem mapa — ex.: `/pato/spec ZH-123` depois de fechar a US1:

1. Leia o mapa. A próxima é a primeira US, na ordem, cujo arquivo de spec ainda não existe — nem na base, nem nas branches do card. Se ela depender de uma US cujo PR ainda não foi mergeado, avise: dá para detalhar agora, mas o `/pato/implement` só começa depois do merge. Pergunte se segue ou se pula para uma US independente.
2. Mostre a US como está no mapa e pergunte se algo mudou com as entregas anteriores (escopo, prioridade, critérios). Se mudou, ajuste o mapa com o usuário.
3. Passe a US pela checagem de `references/historias.md`. Se não passar — ex.: critérios cortados às pressas no `/pato/implement` —, refaça a quebra com o usuário (seção 4).
4. Siga as seções 2, 3 (só o que é novo nesta US), 5 e 6 para ela.
