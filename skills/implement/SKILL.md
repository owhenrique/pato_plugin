---
name: Implement (Pato)
description: Implementa uma spec de docs/specs/ em branch própria — triagem de complexidade com escolha do usuário (direto na janela ou agent-driven com subagente por tarefa), uma tarefa por commit, telas via Playwright CLI. Use quando o usuário pedir "/pato/implement", "implementa a spec", "implementa" ou "pode implementar" logo após o /pato/spec na mesma sessão.
---

# /pato/implement — Implementar a spec

## 1. Localizar a spec

O comando não recebe argumento: ele roda na mesma sessão do `/pato/spec`.

1. Use a spec criada ou revisada pelo `/pato/spec` nesta sessão. Não pergunte qual é.
2. Só se não houver spec nesta sessão (ex.: sessão nova): procure em `docs/specs/` as specs com `status: pendente` ou `em-andamento`. Se houver exatamente uma, use-a e diga qual; se houver várias, pergunte qual com o tool `question`; se não houver nenhuma, sugira `/pato/spec`.
3. Se a spec estiver `implementado`, avise e pare.
4. Leia a spec inteira antes de começar.

## 2. Preparar o git

1. Garanta que a árvore de trabalho está limpa (fora a própria spec). Se houver mudanças não relacionadas, pergunte o que fazer antes de seguir.
2. Descubra a branch base:

   ```bash
   git fetch origin --prune
   git ls-remote --exit-code --heads origin develop >/dev/null 2>&1 && echo develop || \
     (git ls-remote --exit-code --heads origin main >/dev/null 2>&1 && echo main || echo master)
   ```

   Sem remote, use `develop` local se existir, senão `main`/`master`.

3. Se a spec já tem `branch:` preenchida e a branch existe, faça checkout nela e continue de onde parou (tarefas já marcadas `[x]` estão prontas).
4. Senão, crie a branch a partir da base atualizada: `feat/<ID>-<slug>` (ex.: `feat/ZH-123-menu-inicial-bot`; sem chave de card, `feat/<slug>`); use `fix/` se a spec for de correção.
5. Atualize o frontmatter da spec: `status: em-andamento`, `branch: <nome>`. Faça o primeiro commit com a spec: `docs(spec): <ID> <título>`.

## 3. Confirmar o modo de implementação

1. Leia a **Triagem de implementação** da spec. Se ela não existir (spec antiga), monte-a agora com os mesmos critérios e registre na spec.
2. Pergunte ao usuário com o tool `question`, sem assumir — mostre o modo sugerido pela spec e a regra (direto só com 1 tarefa, ≤ 3 arquivos, ≤ 50 linhas de lógica e sem tela, migração, contrato de API ou dependência nova; qualquer coisa além é agent-driven):
   - **Direto (mesma janela)** — você implementa aqui mesmo.
   - **Agent-driven (subagente por tarefa)** — cada tarefa roda num subagente em contexto limpo; você orquestra, confere e commita.
3. Registre a escolha no frontmatter da spec (`modo: direto` ou `modo: agent-driven`).
4. Se o tool `subagent` não existir na sessão e o usuário escolher agent-driven, avise e ofereça o modo direto.

## 4. Modo direto (mesma janela)

**Regra de leitura mínima.** A exploração já foi feita no `/pato/spec`; aqui você lê só o estritamente necessário:

- a spec e os arquivos listados em "Arquivos que a mudança toca";
- testes diretamente ligados ao que está mudando e dependências imediatas (um type, um helper que o código da mudança importa);
- para localizar algo pontual, use busca por linha (`rg -n`, `grep -n`) e leia só o trecho (`sed -n` ou `offset`/`limit`), não o arquivo inteiro "por precaução";
- não re-explore o repositório (estrutura, pastas, arquivos fora da lista);
- se o grafo do graphify existir e estiver atualizado (`graphify check-update .`), responda dúvidas estruturais com `graphify explain`/`graphify affected` antes de abrir qualquer arquivo; rode `graphify update .` se você criou ou renomeou arquivos;
- tocar em arquivo **fora da lista** é mudança de escopo: pare e pergunte antes (tool `question`), registrando a decisão em "Decisões e respostas do usuário".

Para cada tarefa da seção **Tarefas**, em ordem:

1. Implemente seguindo os padrões do projeto e o design técnico da spec.
2. Escreva/atualize testes quando a tarefa pedir ou quando houver lógica nova.
3. **Se a tarefa mexe em tela — regra obrigatória (Playwright CLI):**
   1. Crie/atualize o teste E2E do Playwright cobrindo o fluxo alterado, seguindo a seção "Telas e fluxos E2E" da spec.
   2. Rode via CLI: `npx playwright test <arquivo> [--project=<...>]`. **Falha bloqueia o commit** — corrija antes de seguir.
   3. Guarde a evidência: screenshot do estado final do fluxo em `test-results/<ID>/` (ex.: `await page.screenshot({ path: 'test-results/<ID>/<fluxo>.png' })`) e, em caso de falha, o trace (`--trace on`).
   4. Se o projeto ainda não tem Playwright, faça o setup mínimo seguindo as convenções do repo: `npm i -D @playwright/test`, `npx playwright install chromium`, config + pasta e2e.
   5. Validação de tela é sempre pelo teste E2E rodado via CLI; não substitua por clique/verificação manual ad hoc.
4. Rode lint/testes relevantes do projeto (descubra os comandos em `package.json`, `Makefile`, `pyproject.toml`, etc.). Corrija falhas antes de seguir.
5. Marque a tarefa como `[x]` na spec.
6. Commit atômico com Conventional Commits, referenciando a spec, ex.: `feat(bot): envia menu inicial [ZH-123]`.

Regras:

- Não amplie o escopo além da spec. Melhorias percebidas vão para "Riscos e pontos em aberto" como sugestão.
- Se surgir ambiguidade ou a spec se mostrar errada/inviável no meio do caminho, **pare e pergunte** ao usuário (tool `question`). Registre a decisão em "Decisões e respostas do usuário" na spec antes de continuar.
- Nunca commite segredos (`.env`, tokens, credenciais).
- Não faça push nem abra MR/PR aqui; isso é do `/pato/close-spec`.

## 5. Modo agent-driven (subagente por tarefa)

Você é o orquestrador: mantém a janela principal leve e delega cada tarefa a um subagente novo, **em sequência** (a ordem da spec importa; não paralelize).

Para cada tarefa da seção **Tarefas**, em ordem:

1. Anuncie que a tarefa vai começar.
2. Dispare o subagente com o tool `subagent` (agente `general`, contexto limpo, foreground — espere terminar antes da próxima). O prompt leva:
   - o diretório do projeto e o caminho da spec;
   - a tarefa N e o texto exato dela;
   - os itens de "Arquivos que a mudança toca" ligados à tarefa;
   - a regra de leitura mínima, que vale para o subagente também: só a spec, esses arquivos, testes ligados e dependências diretas; busca por linha + trecho; sem re-explorar o repositório; graphify `explain`/`affected` se o grafo existir;
   - implementar **só esta tarefa**, seguindo os padrões do projeto (leia o `AGENTS.md` do repo) e o design técnico da spec;
   - rodar lint/testes relevantes da tarefa — e o E2E Playwright via CLI se mexer em tela (falha bloqueia);
   - **não commitar, não fazer push e não editar a spec** (o `[x]` e o status são seus);
   - reportar: status, arquivos alterados, comandos de teste com resultado, bloqueios e ambiguidades.
3. Confira o retorno com `git status --short` e `git diff --stat`: os arquivos devem casar com o escopo da tarefa. Não leia o diff inteiro.
4. Tarefa ok: marque `[x]` na spec e faça o commit atômico (só os caminhos da tarefa), ex.: `feat(bot): envia menu inicial [ZH-123]`.
5. Bloqueio, teste falhando ou escopo estourado: continue a sessão do subagente com o tool `subagent` (`sessionID`) passando o feedback específico; se for algo simples, corrija você mesmo e rode o teste da tarefa. Ambiguidade na spec → pare e pergunte.
6. Não deu para resolver em uma rodada: pare, mostre o que aconteceu e pergunte como seguir.

Valem as mesmas regras do modo direto.

## 6. Fechamento do passo

1. Rode a suíte de testes completa (incluindo a suíte Playwright via CLI se houver telas) e verifique os critérios de aceite; marque os que foram atendidos.
2. Mostre ao usuário: tarefas concluídas, testes rodados e resultado (com os arquivos de evidência), e qualquer pendência.
3. Indique o próximo passo: `/pato/verify` (verificação independente); o `/pato/close-spec` só depois dela.
