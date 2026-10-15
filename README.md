# 🦆 Pato

Fluxo de desenvolvimento orientado a spec para OpenCode, em três comandos:

| Comando | O que faz |
| --- | --- |
| `/pato/spec <url, chave ou descrição>` | Lê o card/pedido, explora o repositório, **pergunta toda ambiguidade** e escreve `docs/specs/<ID>-slug.md` com `status: pendente`. |
| `/pato/implement` | Cria a branch `feat/<ID>-slug` a partir de `develop` (ou `main`), implementa tarefa por tarefa com commits atômicos; telas ganham teste E2E rodado via Playwright CLI. Status `em-andamento`. |
| `/pato/close-spec` | Valida tarefas/testes, **pergunta se houve teste (manual/QA) e registra na spec**, marca `status: implementado`, faz push e abre/atualiza o MR/PR (via `glab`, `gh` ou texto pronto); atualiza o card se estiver acessível. |

## Instalação

```bash
cd ~/Work/pato && ./install.sh
```

O instalador cria symlinks no `~/.config/opencode` global:

- `~/.config/opencode/skills/{spec,implement,close-spec}` → skills deste repo (o modelo também descobre e carrega sozinho, sem comando);
- `~/.config/opencode/commands/pato` → commands deste repo (o TUI ganha `/pato/spec`, `/pato/implement` e `/pato/close-spec`).

Alternativa sem symlink: adicione `~/Work/pato/skills` ao array `skills` do `~/.config/opencode/opencode.json`.

## Uso

Tudo na mesma sessão do OpenCode; só o primeiro comando recebe argumento:

```
/pato/spec https://suaempresa.atlassian.net/browse/ZH-123
/pato/implement
/pato/close-spec
```

A entrada do `/pato/spec` é agnóstica: URL de card (Jira, GitHub, Linear...), chave, ou o texto colado. Sem MCP conectado para o tracker, o Pato pede o conteúdo e, no fechamento, entrega o texto do comentário pronto para colar.

Se abrir uma sessão nova no meio do fluxo, os comandos encontram a spec em andamento pela branch atual ou perguntam qual usar.

## Regra de telas — Playwright CLI

Tarefa que mexe em tela não fecha sem teste E2E:

1. **spec** planeja os fluxos (passos, seletores por role/label/test-id e evidência esperada);
2. **implement** cria/atualiza o teste, roda `npx playwright test <arquivo>` (falha bloqueia o commit) e salva screenshot em `test-results/<ID>/`;
3. **close-spec** roda a suíte completa via CLI e registra a evidência no Registro de testes.

## Ciclo de status da spec

`pendente` → `em-andamento` → `implementado`

## Requisitos

- **Git** no projeto (branch base `develop`, `main` ou `master`).
- **Playwright** para tarefas de tela: o `/pato/implement` faz o setup mínimo (`npm i -D @playwright/test`, `npx playwright install chromium`) quando o projeto não tiver.
- **MR/PR** (opcional): `glab` ou `gh` autenticado. Sem nenhum, a descrição é entregue pronta para colar.
- **Card** (opcional): MCP do serviço (Atlassian, GitHub, Linear...) conectado para ler o card e comentar/atualizar status no fechamento.
