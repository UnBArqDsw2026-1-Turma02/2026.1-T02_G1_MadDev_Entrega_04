# Análise de Atualização da Documentação — Entrega Final

> **Documento de trabalho (não é página final do site).** Serve para a equipe **validar** quais informações estão desatualizadas antes de aplicar as mudanças.
>
> **Data:** 22/06/2026 · **Responsável pela análise:** Felipe Veríssimo

## Contexto

Os artefatos **mais atualizados** do projeto hoje são o **DAS** (`docs/ArquiteturaReutilizacao/4.1.DAS.md`) e, sobretudo, a **branch `game`** (implementação real em Godot 4.6). Os demais documentos (Roadmap, Backlog, GDD, Visão Geral) ficaram para trás em relação à evolução do código.

Foi feita uma varredura completa da branch `game` (81 scripts, 27 cenas, 14 resources) e de todo o DAS. **Descoberta principal:** a branch `game` está muito à frente da documentação — as **Issues 01–18 (toda a lógica de jogo)** estão concluídas e validadas em `godot --headless`; **só faltam assets** (sprites, música, SFX — Issues 19–22) e playtests manuais.

## Abordagem proposta

Em cada documento, **manter todo o conteúdo original** e **complementar** com um bloco **"🔄 Atualização — Entrega Final (jun/2026)"** descrevendo a evolução. **Nada é apagado** — as tabelas de status ganham os valores atuais ao lado dos antigos, evidenciando o progresso das entregas anteriores para esta.

---

## A. DAS (`4.1.DAS.md`) — defasagens vs. código atual

| # | Onde | Está no DAS | Realidade no código (branch `game`) |
|---|------|-------------|-------------------------------------|
| A1 | §3 e §10 | Resolução **320×180** | **640×360** (16:9; janela 1280×720; `stretch=canvas_items`, `aspect=keep`) |
| A2 | §4, §10 | Boss **"previsto" / não implementado** | **Boss implementado** (`enemy_boss.gd` + `enemy_boss.tscn`): 2 fases, gatilho a 50% de HP, multiplicadores ×1.6 velocidade / ×1.5 dano |
| A3 | §10 | Inimigos: **2 (melee, ranged)** | **3 (melee, ranged, boss)** |
| A4 | §5.2 (player) | Atributos antigos: `defense`, `resistance`, `dash_cooldown` | Migrou para **`PlayerStats`** (Resource): vida em **corações (base 3)**, dano base 10, velocidade base 200, **redução de cooldown de dash**; **dash por cargas** (2 cargas, recarga 1.6 s/carga) |
| A5 | §5.2 (items) | Consumíveis como **stub** (sem classe concreta) | Concretos: **Bomba, Chave, Poção, Status (+1 atributo/+1 XP), Benefício** (slot único) |
| A6 | §5.1/§5.2 | Raridade: **só `RareDecorator`** | **`RarityConfig`** completo: Comum/Incomum/Raro/Épico + cores (Flyweight) |
| A7 | (ausente) | — | **Economia & Loja**: moeda (`GameManager.currency`), **4 NPCs** (Armeiro/Equipador/Boticário/Mentor), baús (chave/bomba), recompensas de sala (item 15 / arma 25 / vitória 100) |
| A8 | §10/§4 | "sala 11 pré-boss" | Sequência real (12 salas): `empty, combat, combat, rest, combat, chest, combat, shop, rest, combat, combat, boss` |
| A9 | §10 | **~35 scripts, ~10 cenas** | **81 scripts, 27 cenas, 14 resources** |
| A10 | apêndice/§5.2 | Inconsistências internas: `EnemyBase` `resistance` vs `defense`; "EnemySpawner" vs **`EnemyFactory`**; apêndice omite `StudentProfileRegistry`; trechos "**template para preencher**" | Limpar / alinhar com o código |

### ⚠️ A11 — DECISÃO DA EQUIPE NECESSÁRIA: `GameMediator`

O DAS descreve um **barramento de eventos duplo** `GameMediator` + `SignalBus` (em §2, §5.1, §5.2 e nas **5 sequências §6.2–6.6**). Porém **`GameMediator` não existe no código** — há **6 autoloads** (`SignalBus`, `GameManager`, `AudioManager`, `GameFacade`, `AchievementManager`, `StudentProfileRegistry`) e o **`SignalBus` é o único mediador/event bus**.

Isso afeta vários diagramas (inclusive as sequências). Duas opções:

- **(a)** Consolidar a narrativa no `SignalBus`, com nota *"o `GameMediator` foi previsto no design e consolidado no `SignalBus` na implementação"* — **atualiza os diagramas das sequências** para refletir o código.
- **(b)** Manter `GameMediator` como **conceito de arquitetura** documentado e apenas anotar que o código o consolidou no `SignalBus` — **mantém os diagramas** como estão, com a ressalva.

> **Validar:** ( ) opção (a)  ( ) opção (b)

---

## B. Roadmap (`Documentacao/Roadmap.md`) — **o documento mais desatualizado**

- **B1 — §1.1 "Estado real jogável":** afirma que *"o build é uma única cena hardcoded `test_room`"*, *"geração de salas é código morto"*, *"morte não tem efeito"*, *"nenhuma run completa existe"*. **Tudo isso foi resolvido** — o loop completo funciona: **menu → seleção de personagem → 12 salas em sequência → morte → game over → reset → menu**.
- **B2 — Tabela §2 (US → código):** dezenas de itens marcados ❌/🟡 **agora são ✅**: level-up, dash, atributos (PlayerStats), consumíveis, equipáveis, raridade, geração de 12 salas, baús, loja, boss, economia, menu de fim, seleção de personagem.
- **B3 — O que realmente falta:** apenas **assets** (Issues 19–22: sprites, música, SFX) e **playtests manuais** de teclado/mouse.

---

## C. GDD (`GDD/GameDesignDocument.md`) — alinhar com o implementado

| # | Item | No GDD (conceito/arte) | Implementado |
|---|------|------------------------|--------------|
| C1 | Dash | "cooldown fixo reduzível" | **modelo de cargas** (2 cargas, recarga) |
| C2 | Boss | **3 fases** (binário / senoidal / kernel panic) — *direção de arte* | **2 fases** (gatilho 50% HP, multiplicadores) |
| C3 | Armas | catálogo de arte: Lápis, Caneta, Régua, Baralho, Bola, Guarda-Chuva | **2 implementadas**: Caderno (longo alcance), Régua (curto/bumerangue) |
| C4 | Consumíveis | catálogo de arte (7): Bomba, Chave, Poção, Café, Cola, Gummy, Cigarro | **5 implementados**: Bomba, Chave, Poção, Status, Benefício |
| C5 | Salas / atributos | "12 salas (1 vazia, 2-10, 11 pré-boss, 12 boss)" | sequência real (ver A8); atributos base reais (3 corações, dano 10, vel 200; perfis com multiplicadores) |

> Manter o catálogo de arte como **"planejado/direção de arte"** e marcar claramente o que já está **implementado**.

---

## D / E — Ajustes menores

- **D — Visão Geral do Produto:** adicionar status "jogo jogável de ponta a ponta; resta produção de arte/áudio".
- **E — Backlog:** nota de rastreabilidade *"implementado na Entrega Final (branch `game`)"*; observação sobre o dash por cargas (US-07/53).
- **E — Padrões (Entrega 3):** o código adicionou **Flyweight** (`rarity_config.gd`, `*_data.gd`) além dos padrões documentados — pode ser complementado.

---

## Perfis de personagem (referência — valores reais no código)

| Perfil | Vida (×) | Velocidade (×) | Dano (×) |
|--------|---------|----------------|----------|
| Calouro | 1.0 | 1.1 | 0.9 |
| Veterano | 1.2 | 1.0 | 1.2 |
| Jubilado | 1.5 | 0.85 | 1.0 |
| Cara da Atlética | 1.1 | 1.25 | 1.1 |

---

## Checklist de validação (para a equipe marcar)

- [ ] Abordagem dos blocos "🔄 Atualização — Entrega Final" aprovada (complementar, sem apagar)
- [ ] **A11 (GameMediator):** decidir opção (a) ou (b)
- [ ] DAS — itens A1–A10 aprovados
- [ ] Roadmap — itens B1–B3 aprovados
- [ ] GDD — itens C1–C5 aprovados
- [ ] Ajustes D/E aprovados
- [ ] Definir se aplica **tudo** ou um **subconjunto priorizado** (ex.: DAS + Roadmap primeiro)

## Histórico de Versionamento

| Nome | Alteração | Versão | Data |
|------|-----------|--------|------|
| [Felipe Veríssimo](https://github.com/verissimoo) | Levantamento dos pontos de atualização (varredura da branch `game` + DAS) | v1.0 | 22/06/2026 |
