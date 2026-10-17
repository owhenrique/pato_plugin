---
name: Close Spec (Pato)
description: Fecha a spec de uma US implementada — exige a verificação independente registrada e o limite de 500 linhas de lógica, valida testes, registra teste manual/QA, faz push, abre/atualiza um MR ou PR por repo tocado (glab/gh ou texto pronto) com a história na descrição e atualiza o card quando acessível. Use quando o usuário pedir "/pato/close-spec", "fecha a spec", "abre o MR/PR" ou "finaliza" logo após o /pato/verify na mesma sessão.
---

# /pato/close-spec — Fechar a spec, abrir MR/PR e atualizar o card

## 1. Localizar e validar

1. O comando não recebe argumento. Use a spec verificada pelo `/pato/verify` nesta sessão, sem perguntar qual é. Só se não houver spec nesta sessão, use a spec `em-andamento` cujo `branch:` seja igual a `git branch --show-current`; se ainda assim houver dúvida, pergunte.
2. Confirme que está na branch da spec e que não há mudanças não commitadas.
3. Descubra a branch alvo (seção 4) e verifique:
   - todas as tarefas marcadas `[x]`;
   - critérios de aceite atendidos;
   - testes passando (rode a suíte; se o escopo tem telas, rode a suíte Playwright via CLI: `npx playwright test`).
   Se algo faltar, mostre o que está pendente e pergunte se deve fechar mesmo assim. Não prossiga sem confirmação.
4. Bloqueios — sem estes itens, **não prossiga**: pare, mostre o que falta e ofereça o caminho.
   - **Verificação independente registrada:** `verificada_em:` preenchido e a seção "Verificação independente" com a decisão do usuário. Falta → ofereça `/pato/verify`. A dispensa é exceção: só com ordem explícita do usuário, registrada nessa seção.
   - **Limite de 500 linhas:** meça com o comando da seção "Limite de tamanho" da spec (em cada repo tocado, somando). Acima de 500 → não abra o MR/PR nem divida em vários; ofereça voltar ao `/pato/implement` para reduzir o escopo da US. Só siga com exceção explícita do usuário já registrada em "Decisões e respostas do usuário".
   - **Branch só desta US:** `git log --oneline <alvo>..HEAD` mostra só commits desta spec. Commit de outra US por baixo (branch empilhada) → pare e mostre.

## 2. Perguntar sobre os testes (OBRIGATÓRIO)

Antes de fechar, pergunte ao usuário com o tool `question` se houve teste além da suíte automatizada:

- **Houve teste?** Opções: "Sim, testei manualmente", "Sim, QA/cliente testou", "Só os testes automatizados", "Não foi testado".
- Se houve teste manual/QA, peça também: quem testou, em qual ambiente (local, homologação, produção), o que foi testado e o resultado (aprovado / aprovado com ressalvas / reprovado), além de evidências (prints, links, vídeo) se houver.

Não presuma resposta e não pule esta etapa. Se o resultado for **reprovado**, não feche a spec: mostre o que falhou e pergunte como seguir.

Registre na seção **Registro de testes** da spec (crie a seção antes de "Riscos e pontos em aberto" se não existir), uma linha por teste:

```markdown
## Registro de testes

| Data | Tipo | Quem testou | Ambiente | O que foi testado | Resultado | Evidência |
| --- | --- | --- | --- | --- | --- | --- |
| AAAA-MM-DD | Automatizado | local/CI | local | <suíte rodada, nº de testes> | Aprovado | — |
| AAAA-MM-DD | Playwright (CLI) | local | local | <fluxo E2E verificado> | Aprovado | `test-results/<ID>/<fluxo>.png` |
| AAAA-MM-DD | Verificação independente | subagente (contexto limpo) | local | <diff contra a spec + suítes rodadas> | Aprovado | seção "Verificação independente" |
| AAAA-MM-DD | Manual | <nome> | homologação | <fluxos verificados> | Aprovado | <link> |
```

As linhas de testes automatizados e Playwright vêm da execução feita no passo 1, e a de verificação independente, da seção preenchida pelo `/pato/verify`. Se o usuário disser que não houve teste manual, registre uma linha "Manual | — | — | Não realizado".

## 3. Atualizar a spec

1. No frontmatter: `status: implementado`, `implementada_em: <data de hoje AAAA-MM-DD>`.
2. Commit (inclui o registro de testes): `docs(spec): marca spec <ID> como implementada`.

## 4. Branch alvo

Use `develop` se existir no remote, senão `main` (ou `master`):

```bash
git ls-remote --exit-code --heads origin develop >/dev/null 2>&1 && echo develop || \
  (git ls-remote --exit-code --heads origin main >/dev/null 2>&1 && echo main || echo master)
```

## 5. Texto do MR/PR

**Um MR/PR por repo tocado, todos desta US** — nunca dois da mesma US no mesmo repo, nem MRs por faixa de commits. A US é revisada como uma entrega.

Monte a partir da spec e de `git log <alvo>..HEAD` e `git diff --stat <alvo>...HEAD`. Título: `<ID> <tipo>: <título da spec>` quando houver chave de card (a chave no início do título e da branch facilita o vínculo automático no GitLab/GitHub); sem chave, `<tipo>: <título>`. Descrição em português, neste formato:

```markdown
## História
Como <persona>, quero <capacidade>, para <benefício>.

## O que foi feito
<resumo em 2–4 frases do que a persona consegue fazer agora — o resultado entregue, não o processo>

## Mudanças
- <mudança relevante 1, com o módulo/arquivo>
- <mudança relevante 2>

## Como testar
1. <passo>
2. <resultado esperado>
<!-- para telas, use os comandos reais, ex.: npx playwright test e2e/<arquivo>.spec.ts -->

## Testes realizados
<resumo do Registro de testes da spec: automatizados, Playwright CLI, manuais/QA, ambiente e resultado>

## Critérios de aceite
- [x] <critério da spec>

## Tamanho
<N> linhas de lógica de 500 (medido com o comando da spec; por repo, se mais de um)<; exceção autorizada pelo usuário: <motivo>, se houver>

## Observações
<migrações, variáveis de ambiente novas, riscos, pontos em aberto — ou "Nenhuma">

Card: <url do card ou "—">
Spec: `<caminho da spec>`<; mapa: `<caminho do mapa:>` — próxima US: <US e título, ou "nenhuma">>
```

Com mais de um repo, todos os MRs/PRs levam a mesma descrição e, no topo, a ordem de merge (ex.: server antes do client) e os links dos outros — ao abrir o último, atualize a descrição dos anteriores.

Salve a descrição em um arquivo temporário (ex.: `$(mktemp)`), fora do repositório.

## 6. Push e abertura do MR/PR

Em cada repo tocado:

1. `git push -u origin <branch>`.
2. Abra o MR/PR pelo que estiver disponível:
   - `glab` instalado e autenticado (`glab auth status`):

     ```bash
     glab mr create --source-branch "<branch>" --target-branch "<alvo>" \
       --title "<título>" --description "$(cat <arquivo>)" --remove-source-branch --yes
     ```

   - senão, `gh` instalado e autenticado (`gh auth status`):

     ```bash
     gh pr create --base "<alvo>" --head "<branch>" --title "<título>" --body-file <arquivo>
     ```

   - senão, entregue a descrição ao usuário pronta para colar e explique que o MR/PR precisa ser aberto manualmente.
3. Se já existir MR/PR para a branch, atualize a descrição (`glab mr update` / `gh pr edit`) em vez de criar outro.

## 7. Registrar o link na spec

Preencha `merge_request:` na spec com a URL do MR/PR (uma por repo tocado), commit `docs(spec): link do MR da spec <ID>` e push.

## 8. Atualizar o card (só se acessível)

Só faça este passo se o card foi lido de um serviço com MCP conectado e permissão de escrita (Jira/Atlassian, GitHub, Linear...). Se não houver, entregue o texto abaixo pronto para o usuário colar no card e encerre.

1. **Comentar o link.** Antes, leia os comentários do card: se já houver um comentário seu com a URL deste MR/PR (ex.: o comando foi rodado de novo), edite-o em vez de criar outro. Corpo em Markdown:

   ```markdown
   Merge Request aberto: <url do MR/PR>

   - **História:** Como <persona>, quero <capacidade>, para <benefício>.
   - **Branch:** `<branch>` → `<alvo>`
   - **O que foi feito:** <resumo em 1–3 frases, o mesmo da descrição>
   - **Testes:** <resumo do Registro de testes: automatizados, Playwright CLI, manuais/QA, ambiente e resultado>
   - **Spec:** `<caminho da spec>`
   - **Próximas histórias:** <US ainda não entregues do mapa, ou "nenhuma — o card está completo">
   ```

2. **Mover o status para revisão.**
   1. Liste as transições disponíveis do card. Não presuma o nome: o workflow varia por projeto.
   2. Escolha a transição cujo status de destino seja o de revisão de código (ex.: "Code Review", "Em revisão", "In Review"). O card ainda não foi mergeado: nunca sugira um status de concluído ("Done", "Concluído", "Fechado").
   3. Se o mapa ainda tiver US não entregues, o card segue em andamento: a opção recomendada é "Não mover". A transição para revisão é a recomendada só quando esta for a última US do card.
   4. Confirme com o usuário via tool `question` antes de mover: a opção recomendada primeiro, as demais transições disponíveis como alternativas e a opção "Não mover". Se nenhuma transição parecer de revisão, não sugira nenhuma como recomendada; só liste as disponíveis.
   5. Se o card já estiver no status de destino, diga isso e não faça a transição.
   6. Se a transição exigir campos obrigatórios que você não tem como preencher, pergunte os valores ao usuário em vez de inventar.
3. Não altere mais nada no card (responsável, sprint, campos, descrição) sem pedido do usuário.

Se a chamada falhar, não desfaça nada: o MR/PR continua válido. Avise o usuário e entregue o texto do comentário pronto para colar no card.

## 9. Finalizar

Responda ao usuário com o link do MR/PR (um por repo tocado), a branch alvo, as linhas medidas contra o limite de 500 e o que foi feito no card: comentário (adicionado, editado, não feito) e status (de qual para qual, ou que não foi movido). Com mapa — ou com uma US cortada registrada em "Fora" da spec —, diga qual é a próxima US e o comando para detalhá-la: `/pato/spec <chave do card>` (sem chave, `/pato/spec <caminho do mapa ou da spec>`).
