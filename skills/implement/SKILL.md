---
name: Implement (Pato)
description: Implementa a spec de uma US de docs/specs/ em branch própria a partir da base — triagem de complexidade com escolha do usuário (direto na janela ou agent-driven com subagente por tarefa), uma tarefa por commit, limite de 500 linhas de lógica medido a cada tarefa, telas via Playwright CLI. Use quando o usuário pedir "/pato/implement", "implementa a spec", "implementa" ou "pode implementar" logo após o /pato/spec na mesma sessão.
---

# /pato/implement — Implementar a US

Cada spec é uma US: um entregável completo, numa branch própria, que vira um PR por repo tocado com até 500 linhas de lógica. Nada aqui divide a US em partes.

## 1. Localizar a spec

O comando não recebe argumento. Pode rodar na mesma sessão do `/pato/spec`, mas o recomendado é uma sessão nova: a spec é o contrato, e a janela começa sem a exploração da spec — cada passo fica mais barato e o modelo trabalha com o contexto limpo.

1. Use a spec criada ou revisada pelo `/pato/spec` nesta sessão. Não pergunte qual é.
2. Só se não houver spec nesta sessão (ex.: sessão nova): procure em `docs/specs/` as specs com `status: pendente` ou `em-andamento` (mapas de histórias não são specs). Se houver exatamente uma, use-a e diga qual; se houver várias, pergunte qual com o tool `question`; se não houver nenhuma, sugira `/pato/spec`.
3. Se a spec estiver `implementado`, avise e pare.
4. Leia a spec inteira antes de começar.
5. **Dependência:** se `depende_de:` apontar outra US, confirme que o PR dela já foi mergeado na base (`gh pr view <url> --json state`, `glab mr view <url>` ou pergunte). Não mergeado: pare, diga o que falta e ofereça esperar o merge ou implementar outra US do mapa que não dependa dela.

## 2. Preparar o git

1. Garanta que a árvore de trabalho está limpa (fora a própria spec e o mapa). Se houver mudanças não relacionadas, pergunte o que fazer antes de seguir.
2. Descubra a branch base:

   ```bash
   git fetch origin --prune
   git ls-remote --exit-code --heads origin develop >/dev/null 2>&1 && echo develop || \
     (git ls-remote --exit-code --heads origin main >/dev/null 2>&1 && echo main || echo master)
   ```

   Sem remote, use `develop` local se existir, senão `main`/`master`.

3. Se a spec já tem `branch:` preenchida e a branch existe, faça checkout nela e continue de onde parou (tarefas já marcadas `[x]` estão prontas).
4. Senão, crie a branch **a partir da base atualizada** — nunca da branch de outra US: `feat/<ID>-<slug>` (ex.: `feat/ZH-123-us1-listar-vendas`; sem chave de card, `feat/<slug>`); use `fix/` se a spec for de correção. Com mais de um repo tocado, a mesma branch em cada um.
5. Atualize o frontmatter da spec: `status: em-andamento`, `branch: <nome>`. Faça o primeiro commit com a spec (e o mapa, se for novo ou mudou): `docs(spec): <ID> <título>`.

## 3. Confirmar o modo de implementação

1. Leia a **Triagem de implementação** da spec. Se ela não existir (spec antiga), monte-a agora com os mesmos critérios e registre na spec.
2. Pergunte ao usuário com o tool `question`, sem assumir — mostre o modo sugerido pela spec e a regra (direto só com 1 tarefa, ≤ 3 arquivos, ≤ 50 linhas de lógica e sem tela, migração, contrato de API ou dependência nova; qualquer coisa além é agent-driven):
   - **Direto (mesma janela)** — você implementa aqui mesmo.
   - **Agent-driven (subagente por tarefa)** — cada tarefa roda num subagente em contexto limpo; você orquestra, confere e commita.
3. Registre a escolha no frontmatter da spec (`modo: direto` ou `modo: agent-driven`).
4. Se o tool `subagent` não existir na sessão e o usuário escolher agent-driven, avise e ofereça o modo direto.

## 4. Limite de 500 linhas (vale nos dois modos)

1. Depois do commit de cada tarefa, meça com o comando da seção "Limite de tamanho" da spec (em cada repo tocado, somando) e diga o placar: `<medido>/500 (estimado <N>)`. Spec sem essa seção (spec antiga): crie-a com este comando, ajustando a base e os repos:

   ```bash
   for repo in .; do                     # mais de um repo: for repo in server client; do
     git -C "$repo" diff --numstat <base>...HEAD
   done | awk -F'\t' '
     $1 == "-" { next }                                                             # binário
     $3 ~ /(^|\/)(tests?|__tests__|__snapshots__|e2e|docs|migrations)\// { next }  # pastas de teste, doc e gerados
     $3 ~ /\.(test|spec|e2e-spec)\.|_test\.|(^|\/)test_|-contract-test\./ { next } # arquivos de teste
     $3 ~ /\.(md|mdx|json|ya?ml|toml|lock|snap)$/ { next }                          # docs, config e dados
     { s += $1 } END { print s + 0 }'
   ```

2. Se a medição já passou da estimativa ou as tarefas que faltam claramente levam além de 500, avise antes de começar a próxima.
3. **Passou de 500: pare.** Não comece a próxima tarefa; mostre a medição por arquivo (`git diff --numstat <base>...HEAD`) e pergunte com o tool `question`:
   - **Reduzir o escopo desta US (recomendado):** escolham juntos os critérios de aceite que saem — esta US precisa continuar entregando valor sozinha. Os cortados viram uma nova US: acrescente-a ao mapa (sem mapa, registre-a em "Fora" da spec; o próximo `/pato/spec` do card cria o mapa). Remova da branch o código desses critérios — remoção não conta — e atualize a spec: critérios, escopo, tarefas, arquivos e estimativa.
   - **Simplificar:** o mesmo comportamento com menos código (reusar o que já existe, tirar duplicação). Nunca compactar a formatação.
   - **Parar e replanejar** com `/pato/spec`.
4. **Nunca**: dividir a US em parte 1/2/3, abrir mais de um PR por repo, separar MRs por faixa de commits, reescrever a branch para dividir, empilhar branches, mover lógica para arquivos que não contam, marcar código como gerado ou compactar a formatação. Não ofereça "entregar acima de 500" como opção; se o próprio usuário mandar, registre a exceção em "Decisões e respostas do usuário" — o `/pato/close-spec` leva para a descrição do PR.

## 5. Modo direto (mesma janela)

**Regra de leitura mínima.** A exploração já foi feita no `/pato/spec`; aqui você lê só o estritamente necessário:

- a spec e os arquivos listados em "Arquivos que a mudança toca" — o que você vai alterar, leia inteiro antes de editar (arquivo muito grande: o símbolo que muda e o entorno); editar sem ver o arquivo é onde a qualidade cai;
- testes diretamente ligados ao que está mudando e dependências imediatas (um type, um helper que o código da mudança importa);
- para consultar algo pontual fora da lista, use busca por linha (`rg -n`, `grep -n`) e leia só o trecho (`sed -n` ou `offset`/`limit`), não o arquivo inteiro "por precaução";
- não re-explore o repositório (estrutura, pastas, arquivos fora da lista);
- se o grafo do graphify existir no repo, responda dúvidas estruturais por símbolo com `graphify explain`/`graphify affected` antes de abrir qualquer arquivo; rode `graphify update .` (segundos, sem LLM) se você criou ou renomeou arquivos;
- tocar em arquivo **fora da lista** é mudança de escopo: pare e pergunte antes (tool `question`), registrando a decisão em "Decisões e respostas do usuário".

Para cada tarefa da seção **Tarefas**, em ordem:

1. Implemente seguindo os padrões do projeto e o design técnico da spec.
2. Escreva/atualize testes quando a tarefa pedir ou quando houver lógica nova.
3. **Se a tarefa mexe em tela — regra obrigatória (Playwright CLI):**
   1. Crie/atualize o teste E2E do Playwright cobrindo o fluxo alterado, seguindo a seção "Telas e fluxos E2E" da spec.
   2. Rode via CLI: `npx playwright test <arquivo> [--project=<...>]`. **Falha bloqueia o commit** — corrija antes de seguir.
   3. Guarde a evidência: screenshot do estado final do fluxo em `test-results/<ID>/` (ex.: `await page.screenshot({ path: 'test-results/<ID>/<fluxo>.png' })`) e, em caso de falha, o trace (`--trace on`).
   4. Se o projeto ainda não tem Playwright, faça o setup mínimo seguindo as convenções do repo: `npm i -D @playwright/test`, `npx playwright install chromium`, config + pasta e2e.
   5. Validação de tela é sempre pelo teste E2E versionado, rodado via CLI — o `/pato/verify` roda o mesmo arquivo. Não substitua por clique/verificação manual ad hoc: navegação interativa (CLI ou MCP de navegador) só para descobrir seletores, em poucos passos, porque cada passo reenvia o contexto inteiro.
   6. Se o `AGENTS.md` do projeto exigir validação interativa, siga o projeto: um único subagente por US, com roteiro fechado tirado da spec e screenshot só do estado final de cada fluxo.
4. Rode lint/testes relevantes do projeto (descubra os comandos em `package.json`, `Makefile`, `pyproject.toml`, etc.). Corrija falhas antes de seguir.
5. Marque a tarefa como `[x]` na spec.
6. Commit atômico com Conventional Commits, referenciando a spec, ex.: `feat(bot): envia menu inicial [ZH-123]`.
7. Meça as linhas (seção 4) antes de seguir para a próxima tarefa.

Regras:

- Não amplie o escopo além da spec. Melhorias percebidas vão para "Riscos e pontos em aberto" como sugestão.
- Se surgir ambiguidade ou a spec se mostrar errada/inviável no meio do caminho, **pare e pergunte** ao usuário (tool `question`). Registre a decisão em "Decisões e respostas do usuário" na spec antes de continuar.
- Nunca commite segredos (`.env`, tokens, credenciais).
- Não faça push nem abra MR/PR aqui; isso é do `/pato/close-spec`.

## 6. Modo agent-driven (subagente por tarefa)

Você é o orquestrador: mantém a janela principal leve e delega cada tarefa a um subagente novo, **em sequência** (a ordem da spec importa; não paralelize).

Na janela principal, leia só a spec, `git status`/`git diff --stat` e os relatórios dos subagentes — não leia nem explore código aqui. Cada passo do orquestrador reenvia a janela inteira, então uma leitura feita aqui custa muito mais do que dentro de um subagente. Correção que surgir depois (achado da verificação, bug do teste manual) também vai para um subagente; só um ajuste trivial que o usuário mandar fazer direto fica na janela.

Para cada tarefa da seção **Tarefas**, em ordem:

1. Anuncie que a tarefa vai começar.
2. Dispare o subagente com o tool `subagent` (agente `general`, contexto limpo, foreground — espere terminar antes da próxima). O prompt leva:
   - o diretório do projeto e o caminho da spec, com a instrução de **ler a spec inteira uma vez, no começo** — a história, os critérios, as decisões e o que está fora de escopo evitam erro de interpretação;
   - a tarefa N, o texto exato dela e o **contrato** que ela precisa cumprir, detalhado a partir da spec: tipos, assinaturas, regras e casos de teste;
   - os itens de "Arquivos que a mudança toca" ligados à tarefa, com a estimativa de linhas de cada um;
   - a regra de leitura mínima, que vale para o subagente também: só a spec, esses arquivos (inteiros os que vai alterar), testes ligados e dependências diretas; busca por linha + trecho só para consulta pontual; sem re-explorar o repositório; graphify `explain`/`affected` se o grafo existir;
   - implementar **só esta tarefa**, seguindo os padrões do projeto (leia o `AGENTS.md` do repo) e o design técnico da spec, com o mínimo de código que cumpre a tarefa;
   - rodar lint/testes relevantes da tarefa — e, se mexer em tela, escrever/atualizar o teste Playwright versionado e rodá-lo via CLI (falha bloqueia), seguindo a regra de telas do modo direto;
   - **não commitar, não fazer push e não editar a spec** (o `[x]` e o status são seus);
   - reportar: status, arquivos alterados, comandos de teste com resultado, bloqueios e ambiguidades.
3. Confira o retorno com `git status --short` e `git diff --stat`: os arquivos devem casar com o escopo da tarefa. Não leia o diff inteiro.
4. Tarefa ok: marque `[x]` na spec, faça o commit atômico (só os caminhos da tarefa), ex.: `feat(bot): envia menu inicial [ZH-123]`, e meça as linhas (seção 4).
5. Bloqueio, teste falhando ou escopo estourado: continue a sessão do subagente com o tool `subagent` (`sessionID`) passando o feedback específico — ele já tem os arquivos no contexto, e corrigir aqui traria o código para a janela principal. Ambiguidade na spec → pare e pergunte.
6. Não deu para resolver em uma rodada: pare, mostre o que aconteceu e pergunte como seguir.

Valem as mesmas regras do modo direto.

## 7. Fechamento do passo

1. Rode a suíte de testes completa (incluindo a suíte Playwright via CLI se houver telas) e verifique os critérios de aceite; marque os que foram atendidos.
2. Meça as linhas uma última vez (seção 4). Acima de 500 sem exceção registrada, o passo não está fechado.
3. Commite a spec atualizada (`docs(spec): registra a implementação <ID>`), para o `/pato/verify` começar com a árvore limpa.
4. Mostre ao usuário: tarefas concluídas, testes rodados e resultado (com os arquivos de evidência), linhas medidas contra o limite de 500 e qualquer pendência.
5. Indique o próximo passo: `/pato/verify` (verificação independente); o `/pato/close-spec` só depois dela.
