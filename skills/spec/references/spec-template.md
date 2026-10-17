---
id: <ID>                    # chave do card (ex.: ZH-123) ou AAAA-MM-DD-slug; card com mais de uma US: <ID>-us<N>
card: <url do card ou "—">
mapa: <docs/specs/<ID>-mapa.md ou "—">   # só quando o card virou mais de uma US
depende_de: <US que precisa estar mergeada antes, ou "—">
titulo: <Título curto da US>
status: pendente            # pendente → em-andamento → implementado
modo:                       # direto | agent-driven (definido no /pato/implement)
criada_em: AAAA-MM-DD
implementada_em:
verificada_em:
branch:                     # mesmo nome em cada repo tocado
merge_request:              # um por repo tocado
---

# <ID> — <Título da US>

## História
Como <persona>, quero <capacidade>, para <benefício>.

## Contexto
Por que essa história existe, qual problema resolve e para quem. Resumo do card/pedido; com mapa, onde esta US entra.

## Critérios de aceite
- [ ] Dado ..., quando ..., então ...

## Escopo
**Dentro:**
- ...

**Fora** (fica para outra US do mapa ou fora do card):
- ... → US<N> | fora do card

## Decisões e respostas do usuário
Registro das perguntas feitas no refinamento e o que foi decidido.
- P: ... → R: ...

## Premissas
Somente o que o usuário pediu explicitamente para decidir automaticamente. Deixe vazio se não houver.

## Design técnico
- Modelos de dados / migrações
- Endpoints, contratos, mensagens ou telas
- Integrações externas e configuração (variáveis de ambiente, credenciais)
- Tratamento de erros e casos de borda

## Arquivos que a mudança toca
Caminhos exatos (criar/alterar/remover), os símbolos envolvidos e a estimativa de linhas de lógica. É o escopo de leitura do `/pato/implement` e do `/pato/verify`: fora desta lista, só dependências diretas.

- `caminho/do/arquivo.ext` — <o que muda / símbolos> — ~<N> linhas
- ...

## Limite de tamanho
A US inteira sai num PR por repo tocado, mergeável sozinho, com **até 500 linhas de lógica** adicionadas ou modificadas, somando os repos. Remoção não conta.

- **Estimativa:** ~<N> linhas (<repo>: ~<n>) — soma da lista acima.
- **Não contam:** testes, documentação, configuração e dados, lockfiles, migrations e código gerado — <arquivos gerados e o comando que os gera, ou "nenhum gerado">.
- **Medição**, sobre os commits da branch, somando os repos (o comando do `AGENTS.md` do projeto, se houver, substitui este):

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

Passou de 500? Não divida em partes nem abra mais de um PR por repo: reduza o escopo da US (os critérios cortados viram outra US no mapa) ou simplifique, decidindo com o usuário.

## Triagem de implementação
Preenchido no `/pato/spec`; o `/pato/implement` confirma o modo com o usuário antes de começar.

| Métrica | Valor |
| --- | --- |
| Tarefas | <nº> |
| Arquivos que a mudança toca | <nº> |
| Linhas de lógica estimadas | <nº> (ver "Limite de tamanho") |
| Toca em tela (E2E) | Sim/Não |
| Migração de dados | Sim/Não |
| Muda contrato de API | Sim/Não |
| Dependência nova | Sim/Não |
| Repos envolvidos | <nº> |

**Modo sugerido:** direto | agent-driven — <porquê em uma frase>.

## Tarefas
Passos (commits) desta US — todos entram no mesmo PR; tarefa não é entregável.
- [ ] 1. ...
- [ ] 2. ...
- [ ] 3. Testes

## Telas e fluxos E2E (Playwright)
Obrigatório quando o escopo toca telas; senão, escreva "Não se aplica".

| Fluxo | Pré-condição | Passos | Resultado esperado | Seletor principal | Evidência |
| --- | --- | --- | --- | --- | --- |
| ... | ... | ... | ... | role/label/`data-testid` | `test-results/<ID>/<fluxo>.png` |

Como rodar: `npx playwright test e2e/<arquivo>.spec.ts`

## Testes
Como validar: além dos fluxos de tela acima, testes automatizados a criar/rodar e verificação manual.

## Verificação independente
Preenchido no `/pato/verify`; o `/pato/close-spec` não começa sem esta seção.

- **Data:** AAAA-MM-DD
- **Verificador:** subagente em contexto limpo (agente `general`)
- **Suítes rodadas:** <comandos e resultado>
- **Critérios de aceite:** <atendidos / parciais / não atendidos, com evidência>
- **Entregável:** <a história funciona de ponta a ponta só com esta branch? a branch parte da base e só tem commits desta US?>
- **Linhas de lógica:** <medido>/500 (<por repo>)
- **Achados:** <por severidade, com `arquivo:linha` — ou "Nenhum">
- **Decisão do usuário:** <o que corrigir / o que aceitar>

## Registro de testes
Preenchido no `/pato/close-spec`.

| Data | Tipo | Quem testou | Ambiente | O que foi testado | Resultado | Evidência |
| --- | --- | --- | --- | --- | --- | --- |

## Riscos e pontos em aberto
- ...
