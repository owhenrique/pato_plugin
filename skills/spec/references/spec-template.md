---
id: <ID>                    # chave do card (ex.: ZH-123) ou AAAA-MM-DD-slug
card: <url do card ou "—">
titulo: <Título curto da tarefa>
status: pendente            # pendente → em-andamento → implementado
criada_em: AAAA-MM-DD
implementada_em:
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
- Arquivos/módulos afetados
- Modelos de dados / migrações
- Endpoints, contratos, mensagens ou telas
- Integrações externas e configuração (variáveis de ambiente, credenciais)
- Tratamento de erros e casos de borda

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

## Registro de testes
Preenchido no `/pato/close-spec`.

| Data | Tipo | Quem testou | Ambiente | O que foi testado | Resultado | Evidência |
| --- | --- | --- | --- | --- | --- | --- |

## Riscos e pontos em aberto
- ...
