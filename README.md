# 🦆 Pato

Fluxo de desenvolvimento orientado a spec para OpenCode, em quatro comandos. Cada entrega é uma **história de usuário (US)** de até 500 linhas de lógica, num PR que se sustenta sozinho:

| Comando | O que faz |
| --- | --- |
| `/pato/spec <url, chave ou descrição>` | Lê o card/pedido, explora o repositório **via graphify** (pergunta antes de instalar/gerar o grafo; sem graphify, leitura dirigida), **conversa com você** para definir o que vai ser feito (entendimento, regras, prioridade), quebra o trabalho em **histórias de usuário (US)** — cada uma um entregável de até 500 linhas de lógica — e escreve a spec da próxima US em `docs/specs/`, com a triagem que sugere o modo de implementação. Status `pendente`. |
| `/pato/implement` | Confirma com você o modo da triagem — **direto** (mesma janela) ou **agent-driven** (subagente por tarefa) —, cria a branch da US a partir de `develop` (ou `main`) e implementa tarefa por tarefa com commits atômicos **lendo só os arquivos listados na spec** (mais dependências diretas); **mede as linhas de lógica a cada commit e para se passar de 500**; telas ganham teste E2E rodado via Playwright CLI. Status `em-andamento`. |
| `/pato/verify` | Dispara um subagente em contexto limpo: ele confere o diff contra a spec, se a US funciona sozinha de ponta a ponta e o limite de 500 linhas, roda as suítes (incluindo Playwright CLI) e **só reporta** — não corrige. Registra `verificada_em` e a seção "Verificação independente" na spec. |
| `/pato/close-spec` | Exige a verificação independente registrada e **barra acima de 500 linhas**, valida tarefas/testes, **pergunta se houve teste (manual/QA) e registra na spec**, marca `status: implementado`, faz push e abre/atualiza **um MR/PR por repo tocado** (via `glab`, `gh` ou texto pronto) com a história na descrição; atualiza o card se estiver acessível e aponta a próxima US. |

## Instalação

```bash
cd ~/Work/pato && ./install.sh
```

O instalador cria symlinks no `~/.config/opencode` global:

- `~/.config/opencode/skills/{spec,implement,verify,close-spec}` → skills deste repo (o modelo também descobre e carrega sozinho, sem comando);
- `~/.config/opencode/commands/pato` → commands deste repo (o TUI ganha `/pato/spec`, `/pato/implement`, `/pato/verify` e `/pato/close-spec`).

Alternativa sem symlink: adicione `~/Work/pato/skills` ao array `skills` do `~/.config/opencode/opencode.json`.

## Uso

O `/pato/spec` roda na sessão em que você conversa; o `/pato/implement`, de preferência numa sessão nova — a spec é o handoff, e a janela começa sem a exploração da spec. `/pato/verify` e `/pato/close-spec` podem seguir nessa mesma sessão. Só o primeiro comando recebe argumento:

```
/pato/spec https://suaempresa.atlassian.net/browse/ZH-123
# sessão nova
/pato/implement
/pato/verify
/pato/close-spec
```

A entrada do `/pato/spec` é agnóstica: URL de card (Jira, GitHub, Linear...), chave, ou o texto colado. Sem MCP conectado para o tracker, o Pato pede o conteúdo e, no fechamento, entrega o texto do comentário pronto para colar.

Card que virou mais de uma US: depois do `/pato/close-spec` de uma, `/pato/spec ZH-123` detalha a próxima do mapa e o ciclo recomeça — uma US por PR.

Se abrir uma sessão nova no meio do fluxo, os comandos encontram a spec em andamento pela branch atual ou perguntam qual usar.

## Histórias (US) e o limite de 500 linhas

**Uma US = uma spec = uma branch = um PR** (um por repo, quando a US atravessa mais de um). O PR é sempre um entregável: a história funciona de ponta a ponta e a base fica coerente depois do merge.

1. **Conversa.** O `/pato/spec` confirma o entendimento (problema, persona, resultado esperado), pergunta o que estiver vago — regras, casos de borda, telas — e combina com você o que é essencial na primeira entrega e o que fica para depois.
2. **Histórias.** O trabalho vira US no formato *Como <persona>, quero <capacidade>, para <benefício>*, com critérios Dado/Quando/Então e estimativa de linhas por arquivo (meta de ~400 por US). A quebra é **por valor** — passos do fluxo, regras, variações de dado, operações —, nunca por camada. Você aprova ou ajusta a quebra antes da spec.
3. **Mapa.** Card com mais de uma US ganha `docs/specs/<ID>-mapa.md` (ordem, dependências, critérios e o caminho da spec de cada US) e uma spec por US, `docs/specs/<ID>-us<N>-<slug>.md`. Só a próxima US é detalhada; as outras ficam no mapa, sem arquivo de spec, até chegar a vez — já com o código das anteriores na base.
4. **Medição.** Contam as linhas de lógica adicionadas ou modificadas (`git diff --numstat` contra a base, somando os repos); remoção, testes, docs, config/dados, lockfiles, migrations e código gerado não contam. O comando fica na seção "Limite de tamanho" da spec — se o `AGENTS.md` do projeto definir outro limite ou outra medição, vale o do projeto. O `/pato/implement` mede a cada commit, o `/pato/verify` mede de novo e o `/pato/close-spec` não abre PR acima de 500.
5. **Passou de 500?** O Pato para e decide com você: reduzir o escopo da US (os critérios cortados viram uma nova US no mapa) ou simplificar o código. Nunca: parte 1/2/3, PRs por faixa de commits, PR empilhado na branch de outra US, flag escondendo meia funcionalidade ou lógica movida para arquivos que não contam. Exceção só por ordem explícita sua, registrada na spec e no PR.

## Economia de contexto — graphify e janela leve

O que mais pesa não é o tamanho de uma leitura, e sim quantos passos rodam com a janela cheia: cada passo reenvia o contexto inteiro. Por isso o Pato mantém as janelas pequenas, em vez de picotar o que o modelo lê.

- **`/pato/spec`** atualiza o grafo (`graphify update .`, incremental, segundos) e consulta por símbolo (`explain`, `affected`, `path`, `query` com nomes do código) em vez de ler arquivos, abrindo só os trechos que o grafo apontar. Sem graphify instalado ou sem grafo, o Pato **pergunta antes de qualquer leitura** se deve instalar (`uv tool install graphifyy` ou `pipx install graphifyy`) e gerar (`graphify extract . --code-only`, offline e só código) — ou segue com leitura dirigida.
- **Workspace com repos independentes** (ex.: `client/` e `server/` numa raiz de docs): um grafo por repo, gerado dentro dele — o `extract` respeita o `.gitignore`, e na raiz ele não enxerga os repos ignorados. Não há aresta entre os repos (eles se falam por HTTP e tipos gerados), então juntar os grafos não ajuda; a ponte é o contrato da API.
- **`/pato/implement`** lê só a spec, os arquivos listados em "Arquivos que a mudança toca", testes ligados e dependências imediatas; consultas pontuais com `rg`/trecho, sem re-explorar o repositório. No modo agent-driven, cada subagente lê a spec inteira uma vez (ela é de uma US só) e recebe o contrato da tarefa; a janela principal não lê código — só a spec, o `--stat` e os relatórios.
- **Telas** são validadas por teste Playwright versionado, rodado via CLI: um passo por execução, e o `/pato/verify` roda o mesmo arquivo. Navegação interativa clique a clique só para descobrir seletores.
- O grafo (`graphify-out/`) fica fora do git via `.git/info/exclude` quando gerado pelo Pato.

## Triagem e modos de implementação

O `/pato/spec` metrifica a tarefa — tarefas, arquivos, linhas de lógica estimadas, tela, migração, contrato de API, dependência nova, repos — e registra uma sugestão de modo. O `/pato/implement` mostra a triagem e **pergunta antes de começar**:

- **Direto (mesma janela):** só para o trivial — 1 tarefa, ≤ 3 arquivos, ≤ 50 linhas e nenhum item marcado. A implementação acontece na própria sessão.
- **Agent-driven:** qualquer coisa além disso. Cada tarefa da spec roda num subagente novo (contexto limpo), em sequência; a janela principal orquestra — confere o diff por `git diff --stat`, marca a tarefa e faz o commit atômico. O contexto da implementação não ocupa a janela.

A escolha fica registrada na spec (`modo:`). O `/pato/verify` continua independente nos dois casos.

## Regra de telas — Playwright CLI

Tarefa que mexe em tela não fecha sem teste E2E:

1. **spec** planeja os fluxos (passos, seletores por role/label/test-id e evidência esperada);
2. **implement** cria/atualiza o teste, roda `npx playwright test <arquivo>` (falha bloqueia o commit) e salva screenshot em `test-results/<ID>/`;
3. **verify** roda a suíte completa em contexto limpo e reporta;
4. **close-spec** roda a suíte completa via CLI e registra a evidência no Registro de testes.

## Verificação independente

Depois do `/pato/implement`, o `/pato/verify` spawna um subagente novo (sem o contexto da implementação) que lê a spec, revisa `git diff base...HEAD`, dá veredito por critério de aceite, confere se a US funciona sozinha (sem camada faltando, sem branch de outra US por baixo), mede as linhas, roda as suítes e reporta achados por severidade com `arquivo:linha`. Ele não corrige nada: você decide o que ajustar. O `/pato/close-spec` exige esse registro (com sua decisão) antes de fechar.

## Ciclo de status da spec

`pendente` → `em-andamento` → `implementado`, com `verificada_em` preenchido pelo `/pato/verify` antes do fechamento. O status é de cada US (spec); o mapa não tem status — US cujo arquivo de spec ainda não existe é a que falta detalhar.

## Requisitos

- **Git** no projeto (branch base `develop`, `main` ou `master`).
- **Graphify** (opcional, recomendado): `uv tool install graphifyy` (ou `pipx install graphifyy`). Sem ele, a spec usa leitura dirigida — o Pato nunca instala nem gera o grafo sem perguntar.
- **Playwright** para tarefas de tela: o `/pato/implement` faz o setup mínimo (`npm i -D @playwright/test`, `npx playwright install chromium`) quando o projeto não tiver.
- **MR/PR** (opcional): `glab` ou `gh` autenticado. Sem nenhum, a descrição é entregue pronta para colar.
- **Card** (opcional): MCP do serviço (Atlassian, GitHub, Linear...) conectado para ler o card e comentar/atualizar status no fechamento.
