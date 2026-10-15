# 🦆 Pato

Fluxo de desenvolvimento orientado a spec para OpenCode, em quatro comandos:

| Comando | O que faz |
| --- | --- |
| `/pato/spec <url, chave ou descrição>` | Lê o card/pedido, explora o repositório **via graphify** (pergunta antes de instalar/gerar o grafo; sem graphify, leitura dirigida), **pergunta toda ambiguidade**, escreve `docs/specs/<ID>-slug.md` e metrifica a tarefa (triagem) sugerindo o modo de implementação. Status `pendente`. |
| `/pato/implement` | Confirma com você o modo da triagem — **direto** (mesma janela) ou **agent-driven** (subagente por tarefa) —, cria a branch `feat/<ID>-slug` a partir de `develop` (ou `main`) e implementa tarefa por tarefa com commits atômicos **lendo só os arquivos listados na spec** (mais dependências diretas); telas ganham teste E2E rodado via Playwright CLI. Status `em-andamento`. |
| `/pato/verify` | Dispara um subagente em contexto limpo: ele confere o diff contra a spec, roda as suítes (incluindo Playwright CLI) e **só reporta** — não corrige. Registra `verificada_em` e a seção "Verificação independente" na spec. |
| `/pato/close-spec` | Exige a verificação independente registrada, valida tarefas/testes, **pergunta se houve teste (manual/QA) e registra na spec**, marca `status: implementado`, faz push e abre/atualiza o MR/PR (via `glab`, `gh` ou texto pronto); atualiza o card se estiver acessível. |

## Instalação

```bash
cd ~/Work/pato && ./install.sh
```

O instalador cria symlinks no `~/.config/opencode` global:

- `~/.config/opencode/skills/{spec,implement,verify,close-spec}` → skills deste repo (o modelo também descobre e carrega sozinho, sem comando);
- `~/.config/opencode/commands/pato` → commands deste repo (o TUI ganha `/pato/spec`, `/pato/implement`, `/pato/verify` e `/pato/close-spec`).

Alternativa sem symlink: adicione `~/Work/pato/skills` ao array `skills` do `~/.config/opencode/opencode.json`.

## Uso

Tudo na mesma sessão do OpenCode; só o primeiro comando recebe argumento:

```
/pato/spec https://suaempresa.atlassian.net/browse/ZH-123
/pato/implement
/pato/verify
/pato/close-spec
```

A entrada do `/pato/spec` é agnóstica: URL de card (Jira, GitHub, Linear...), chave, ou o texto colado. Sem MCP conectado para o tracker, o Pato pede o conteúdo e, no fechamento, entrega o texto do comentário pronto para colar.

Se abrir uma sessão nova no meio do fluxo, os comandos encontram a spec em andamento pela branch atual ou perguntam qual usar.

## Economia de leitura — graphify

- **`/pato/spec`** consulta o grafo do projeto (`graphify query`, `path`, `explain`, `affected`) em vez de ler arquivos, e abre só os trechos que o grafo apontar. Sem graphify instalado ou sem grafo, o Pato pergunta se deve instalar (`uv tool install graphifyy` ou `pipx install graphifyy`) e gerar (`graphify extract . --code-only`, offline e só código) — ou segue com leitura dirigida.
- **`/pato/implement`** lê só a spec, os arquivos listados em "Arquivos que a mudança toca", testes ligados e dependências imediatas; consultas pontuais com `rg`/trecho, sem re-explorar o repositório. No modo agent-driven a mesma regra vale para o subagente, e a janela principal só confere o `--stat` e commita.
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

Depois do `/pato/implement`, o `/pato/verify` spawna um subagente novo (sem o contexto da implementação) que lê a spec, revisa `git diff base...HEAD`, dá veredito por critério de aceite, roda as suítes e reporta achados por severidade com `arquivo:linha`. Ele não corrige nada: você decide o que ajustar. O `/pato/close-spec` exige esse registro (com sua decisão) antes de fechar.

## Ciclo de status da spec

`pendente` → `em-andamento` → `implementado`, com `verificada_em` preenchido pelo `/pato/verify` antes do fechamento.

## Requisitos

- **Git** no projeto (branch base `develop`, `main` ou `master`).
- **Graphify** (opcional, recomendado): `uv tool install graphifyy` (ou `pipx install graphifyy`). Sem ele, a spec usa leitura dirigida — o Pato nunca instala nem gera o grafo sem perguntar.
- **Playwright** para tarefas de tela: o `/pato/implement` faz o setup mínimo (`npm i -D @playwright/test`, `npx playwright install chromium`) quando o projeto não tiver.
- **MR/PR** (opcional): `glab` ou `gh` autenticado. Sem nenhum, a descrição é entregue pronta para colar.
- **Card** (opcional): MCP do serviço (Atlassian, GitHub, Linear...) conectado para ler o card e comentar/atualizar status no fechamento.
