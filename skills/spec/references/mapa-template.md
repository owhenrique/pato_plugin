---
id: <ID>                    # chave do card (ex.: ZH-123) ou AAAA-MM-DD-slug
card: <url do card ou "—">
titulo: <Título do card>
tipo: mapa-de-historias     # não é spec: o status de cada US fica na spec dela
criado_em: AAAA-MM-DD
---

# <ID> — <Título> (mapa de histórias)

## Contexto
O problema, quem é afetado e o resultado esperado do card como um todo.

## Personas
- **<persona>** — quem é e o que precisa.

## Decisões gerais
Perguntas e respostas que valem para todas as US; as de uma US só ficam na spec dela.
- P: ... → R: ...

## Histórias
Em ordem de entrega. Cada US é um entregável: fatia vertical, mergeável sozinha, com até 500 linhas de lógica (soma dos repos) — uma spec, uma branch e um PR por repo tocado. A coluna "Spec" já traz o caminho da spec de cada US; enquanto o arquivo não existe, a US ainda não foi detalhada.

| US | História | Estimativa | Depende de | Spec |
| --- | --- | --- | --- | --- |
| US1 | Como <persona>, quero <capacidade>, para <benefício>. | ~<N> | — | `docs/specs/<ID>-us1-<slug>.md` |
| US2 | Como <persona>, quero <capacidade>, para <benefício>. | ~<N> | US1 | `docs/specs/<ID>-us2-<slug>.md` |

### US1 — <título>
Como <persona>, quero <capacidade>, para <benefício>.

- Dado ..., quando ..., então ...

Fica para outra US: ... (US2)

### US2 — <título>
Como <persona>, quero <capacidade>, para <benefício>.

- Dado ..., quando ..., então ...

## Fora do card
- ...
