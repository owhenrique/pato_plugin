---
name: Verify (Pato)
description: Verificação independente de uma spec implementada — um subagente em contexto limpo confere o diff contra a spec e roda as suítes, só reportando. Use quando o usuário pedir "/pato/verify", "verifica a implementação", "verificação independente" ou "avalia o que foi implementado", normalmente logo após o /pato/implement na mesma sessão.
---

# /pato/verify — Verificação independente

Um agente novo, sem o contexto da implementação, confere o que foi feito contra a spec e roda as suítes. Ele **só reporta**: quem decide o que corrigir é o usuário. Você (agente principal) não faz a verificação — apenas dispara o verificador e apresenta o relatório.

## 1. Localizar a spec

O comando não recebe argumento e roda na mesma sessão do `/pato/implement`.

1. Use a spec implementada nesta sessão, sem perguntar qual é.
2. Só se não houver spec nesta sessão: use a spec `em-andamento` cujo `branch:` seja igual a `git branch --show-current`; se houver várias, pergunte com o tool `question`; se não houver nenhuma, sugira `/pato/implement`.
3. Se a spec estiver `implementado`, avise que já foi fechada e pergunte se quer re-verificar mesmo assim (ex.: depois de ajustes pedidos na revisão do MR).

## 2. Preparar a verificação

1. Confirme que está na branch da spec e que todas as tarefas estão `[x]`. Se houver tarefa aberta, o `/pato/implement` não terminou: pare e avise.
2. A verificação roda sobre commits: se houver mudanças não commitadas, pare e pergunte o que fazer.
3. Descubra a branch base:

   ```bash
   git ls-remote --exit-code --heads origin develop >/dev/null 2>&1 && echo develop || \
     (git ls-remote --exit-code --heads origin main >/dev/null 2>&1 && echo main || echo master)
   ```

   Sem remote, use `develop` local se existir, senão `main`/`master`.
4. Monte o prompt do verificador com dados objetivos: caminho da spec, diretório do projeto, branch e branch base. **Não** inclua sua narrativa da implementação, um resumo do diff feito por você, nem conclusões prévias — o verificador parte da spec e do código.

## 3. Disparar o verificador

Use o tool `subagent` (agente `general`, contexto limpo; em versões que o expõem como `task`, o equivalente) apontando para o diretório do projeto. O prompt segue este roteiro:

- Você é um verificador independente. **Não corrija, não commite, não faça push; só reporte.**
- Leia a spec inteira (objetivo, escopo, decisões, tarefas, critérios de aceite, telas E2E) antes de olhar o código.
- Revise `git log <base>..HEAD --oneline` e o diff completo (`git diff <base>...HEAD`, começando por `--stat`). Confira se cada tarefa `[x]` corresponde a mudança real e commit.
- Para cada critério de aceite: **atendido / parcial / não atendido**, com evidência (arquivo:linha, teste, comando).
- Rode as suítes de teste do projeto (descubra os comandos em `package.json`, `Makefile`, `pyproject.toml` etc.) e, se o escopo tem telas, a suíte Playwright via CLI (`npx playwright test`). Anexe o resultado bruto (nº de testes, falhas).
- Não confie no "Registro de testes" da spec como evidência: verifique você mesmo.
- Procure problemas que a implementação introduziu: escopo além da spec, critério sem teste, caso de borda do spec não tratado, contrato/API quebrado, segredo commitado, arquivo tocado fora da lista da spec sem registro.
- Se um teste falhar, investigue o suficiente para apontar a causa provável (arquivo:linha) e siga; não conserte.
- Relatório: veredito por critério (tabela), suítes rodadas com resultado, achados por severidade (Alta/Média/Baixa) com `arquivo:linha` e sugestão, e uma seção "não verificado" para o que não deu para checar.

## 4. Relatório e decisão

1. Apresente o resumo: veredito, suítes (nº de testes/falhas) e achados; aponte as evidências.
2. **Não corrija nada por conta própria.** Pergunte com o tool `question` o que fazer: corrigir os achados agora, aceitar como está ou parar.
3. Se o usuário mandar corrigir: siga o padrão do `/pato/implement` (commits atômicos na mesma branch, testes verdes antes de cada commit) e rode a verificação de novo ao terminar.

## 5. Registrar na spec

1. Com tudo decidido (correções feitas, se houve), preencha `verificada_em:` no frontmatter e a seção **"Verificação independente"** com data, suítes, veredito por critério, achados e a decisão do usuário.
2. Commit: `docs(spec): registro da verificação independente <ID>` — obrigatório para o `/pato/close-spec` não travar com árvore suja.
3. Indique o próximo passo: `/pato/close-spec`.
