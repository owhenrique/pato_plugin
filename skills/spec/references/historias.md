# Histórias de usuário (US) — como quebrar o trabalho

Uma US é a menor entrega que alguém que usa o sistema percebe. No Pato, cada US vira uma spec, uma branch e um PR (um por repo tocado), com até 500 linhas de lógica.

## Formato

```markdown
**US<N> — <título curto que descreve a capacidade>**

Como <persona>, quero <capacidade>, para <benefício>.

- Dado <contexto>, quando <ação>, então <resultado observável>.
```

- **Persona** é quem usa: cliente, organizador, admin, atendente, outro sistema que consome a API. Nunca "o sistema" nem "o backend".
- **Capacidade** é o que a pessoa passa a conseguir fazer, não a peça técnica: "ver quanto cada um paga", não "criar o endpoint `GET /split`".
- **Benefício** diz por que importa — é ele que permite cortar escopo sem perder o valor.
- **Critérios** são verificáveis por quem usa (tela, resposta da API para quem a consome, arquivo gerado) e viram os testes da US.

## Checagem de cada US

Uma US só vai para o usuário, e depois para spec, se passar em todos os itens:

1. **Valor sozinha:** mergeada só ela, a persona consegue fazer algo novo ou o problema some — os critérios de aceite provam isso.
2. **Fatia vertical:** atravessa todas as camadas que o comportamento exige (dados, regra, API, tela). Não é "só o back", "só a tela", "só o modelo", "só o contrato" nem "só os testes".
3. **Base coerente:** com a US mergeada (todos os PRs dela), nada fica pela metade — sem endpoint que ninguém usa, sem tela chamando o que não existe, sem `TODO` de "próxima parte", sem flag escondendo meia funcionalidade.
4. **Independente:** depende no máximo de US anteriores, que precisam estar mergeadas antes de esta começar — nunca de uma branch em aberto.
5. **Pequena:** estimativa de até ~400 linhas de lógica (soma dos repos); medida, nunca passa de 500.
6. **Testável:** critérios Dado/Quando/Então que o `/pato/verify` consegue conferir.

## Como fatiar por valor

Comece pelo caminho mais fino de ponta a ponta e acrescente comportamento nas US seguintes:

| Técnica | Primeira US | US seguintes |
| --- | --- | --- |
| Passos do fluxo | o caminho mínimo do início ao fim | passos opcionais, atalhos, confirmações |
| Regras de negócio | a regra principal | exceções e regras extras, uma por US |
| Variações de dados | um tipo ou formato (ex.: só valor fixo) | os demais (percentual, outras moedas, importação) |
| Operações | criar e ver | editar, excluir, histórico |
| Caminho feliz | o fluxo principal, com os erros básicos tratados (nada quebra) | casos de borda, mensagens específicas, recuperação |
| Interface | a versão simples e utilizável | filtros, ordenação, máscaras, atalhos |
| Persona | um papel (ex.: organizador) | outros papéis (ex.: jogador) |
| Desempenho | funcionar | otimizar, quando o ganho é perceptível |

- Incerteza técnica que impede estimar: investigue antes, com o usuário (ler código, testar uma ideia descartável). A investigação não vira PR.
- **US técnica** (refatoração sem mudança de comportamento, atualização de dependência, infraestrutura) só quando se sustenta sozinha e o usuário aprova: "Como time de desenvolvimento, quero ..., para ...", com o ganho no benefício. Nunca como camada de uma funcionalidade ("Como dev, quero o endpoint X para a tela usar depois").

## Anti-padrões (proibidos)

- **Parte 1/2/3** do mesmo comportamento — também disfarçada de a/b/c, P1/P2, `E2/server` + `E2/client`, "base" + "tela".
- **Fatia por camada:** back numa US e front noutra; modelo e migration numa, regra noutra.
- **Fatia por tipo de trabalho:** código numa US e testes noutra.
- **PRs por faixa de commits**, ou branch reescrita para separar MRs de uma mesma US.
- **PR empilhado:** branch de uma US criada a partir da branch de outra ainda não mergeada.
- **Flag para mergear meia funcionalidade.**
- **Burlar a medição:** mover lógica para arquivos que não contam (`.json`, `.yml`, `*.test.*`), marcar como gerado código escrito à mão, compactar a formatação ou mudar o formatter do projeto.

**Mais de um repo** (ex.: `server` e `client`): a US que atravessa os dois tem um PR em cada, os dois da mesma US e com a mesma descrição. O limite de 500 vale para a soma, e a ordem de merge (ex.: API antes, com contrato aditivo) vai na descrição. Isso não é parte 1/2: os PRs são revisados e mergeados juntos, como uma entrega.

## Exemplo

Card: "Cupons de desconto no checkout" — ~1.200 linhas estimadas.

Errado (partes técnicas):

- Parte 1 — modelo, migration e CRUD de cupons na API
- Parte 2 — tela de cadastro de cupons
- Parte 3 — aplicar o cupom no checkout

Certo (histórias):

| US | História | Estimativa | Depende de |
| --- | --- | --- | --- |
| US1 | Como cliente, quero aplicar um cupom de valor fixo no checkout, para pagar menos. (O admin cadastra o cupom num formulário mínimo: código e valor.) | ~380 | — |
| US2 | Como admin, quero criar cupom percentual, para fazer campanhas de "% off". | ~150 | US1 |
| US3 | Como admin, quero definir validade e limite de usos, para controlar o custo da campanha. | ~250 | US1 |
| US4 | Como admin, quero listar e desativar cupons, para encerrar uma campanha. | ~200 | US1 |

Cada linha, mergeada, deixa o checkout funcionando e entrega algo que alguém percebe.
