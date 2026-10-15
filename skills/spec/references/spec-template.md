---
id: <ID>                    # chave do card (ex.: ZH-123) ou AAAA-MM-DD-slug
card: <url do card ou "—">
titulo: <Título curto da tarefa>
status: pendente            # pendente → em-andamento → implementado
modo:                       # direto | agent-driven (definido no /pato/implement)
criada_em: AAAA-MM-DD
implementada_em:
verificada_em:
branch:
merge_request:
---

# <ID> — <Título>

## Contexto
Por que essa tarefa existe, qual problema resolve e para quem. Resumo do card/pedido.

## Objetivo
O resultado esperado em uma ou duas frases.

## Escopo
**Dentro:**
- ...

**Fora:**
- ...

## Decisões e respostas do usuário
Registro das perguntas feitas durante a spec e o que foi decidido.
- P: ... → R: ...

## Premissas
Somente o que o usuário pediu explicitamente para decidir automaticamente. Deixe vazio se não houver.

## Design técnico
- Modelos de dados / migrações
- Endpoints, contratos, mensagens ou telas
- Integrações externas e configuração (variáveis de ambiente, credenciais)
- Tratamento de erros e casos de borda

## Arquivos que a mudança toca
Caminhos exatos (criar/alterar/remover) e os símbolos envolvidos. É o escopo de leitura do `/pato/implement` e do `/pato/verify`: fora desta lista, só dependências diretas.

- `caminho/do/arquivo.ext` — <o que muda / símbolos>
- ...

## Triagem de implementação
Preenchido no `/pato/spec`; o `/pato/implement` confirma o modo com o usuário antes de começar.

| Métrica | Valor |
| --- | --- |
| Tarefas | <nº> |
| Arquivos que a mudança toca | <nº> |
| Linhas de lógica estimadas | <nº> |
| Toca em tela (E2E) | Sim/Não |
| Migração de dados | Sim/Não |
| Muda contrato de API | Sim/Não |
| Dependência nova | Sim/Não |
| Repos envolvidos | <nº> |

**Modo sugerido:** direto | agent-driven — <porquê em uma frase>.

## Tarefas
- [ ] 1. ...
- [ ] 2. ...
- [ ] 3. Testes

## Critérios de aceite
- [ ] Dado ..., quando ..., então ...

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
- **Achados:** <por severidade, com `arquivo:linha` — ou "Nenhum">
- **Decisão do usuário:** <o que corrigir / o que aceitar>

## Registro de testes
Preenchido no `/pato/close-spec`.

| Data | Tipo | Quem testou | Ambiente | O que foi testado | Resultado | Evidência |
| --- | --- | --- | --- | --- | --- | --- |

## Riscos e pontos em aberto
- ...
