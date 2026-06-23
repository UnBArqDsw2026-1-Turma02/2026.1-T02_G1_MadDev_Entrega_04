# Roadmap de Desenvolvimento — Jogo
 
## O que é este documento?
 
Este roadmap mapeia **o que já está implementado** no projeto (Godot 4.6) contra o
[Backlog](1.2.8.Backlog.md) e organiza **o que falta** em ondas de desenvolvimento ordenadas por
dependência de gameplay. Serve como guia de priorização para tornar o jogo jogável de ponta a ponta.
 
A análise foi feita por varredura do código em `jogo/scripts/`, `jogo/scenes/`, `jogo/resources/` e
`jogo/art/`. O backlog define 70 histórias de usuário (US-01..US-72, sem US-58/US-61), 20 épicos e 6 temas.
 
> **Sobre os padrões GoF:** os 23 padrões eram requisito da **Entrega 03**. Neste roadmap eles aparecem
> apenas como **referência** (inventário do que já existe) e como sugestão *opcional* de implementação —
> **não** são a regra que guia a priorização. O foco é a jogabilidade (Must-Have por dependência).
 
> ⚠️ **Ressalva de verificação:** os status ✅/🟡/❌ foram revisados **lendo o código real** (não só a
> existência de arquivos). A distinção importante é entre *"a mecânica existe em algum script"* e
> *"a mecânica está integrada e funciona no jogo que efetivamente roda"*. Veja a seção **1.1** — há um
> descompasso grande entre o código escrito e o que está ligado ao loop jogável.

## 🔄 Atualização — Entrega Final (jun/2026)

> Esta seção **complementa** o roadmap (nada abaixo foi removido). A análise da §1.1 descrevia o estado **no início** desta fase — **a maior parte daquele descompasso já foi resolvida**. Onde houver divergência, **prevalece esta atualização**.

**O loop jogável está completo e validado** em `godot --headless` (Godot 4.6): menu → seleção de personagem → 12 salas em sequência → combate → morte/vitória → tela de fim → reset → menu. Os pontos críticos da §1.1 foram resolvidos:

- ✅ **Geração de salas ligada ao jogo** — `run.gd` carrega as 12 salas da sequência sob demanda via `GameManager`; `test_room.tscn` deixou de ser o destino do Play.
- ✅ **Morte com efeito** — dano letal passa por `GameFacade.kill_player()` → `end_run(false)` → tela de game over; reset total (RNF-07).
- ✅ **Transição entre salas** — porta destrancada (`Area2D`) avança para a próxima sala; o player persistente é reposicionado no `player_start`.
- ✅ **Trava de porta por combate** e **Chain of Responsibility** de dano ligadas ao jogo real.

**Cobertura por onda (Issues do `tasks.md` da branch `game`):**

| Onda | Status |
|------|--------|
| 0 — Integração do loop | ✅ concluída (Issue 01) |
| 1 — Fundação de progressão (PlayerStats, XP/level-up, dash, tabelas) | ✅ concluída (Issues 02–04) |
| 2 — Itens (consumíveis, equipáveis, raridade, inventário/HUD) | ✅ concluída (Issues 05–09) |
| 3 — Estrutura da run (12 salas, salas seguras, baús, portas) | ✅ concluída (Issues 10–12) |
| 4 — Boss, economia e loja | ✅ concluída (Issues 13–16) |
| 5 — UI e fechamento (seleção de personagem, fim de jogo) | ✅ concluída (Issues 17–18) |
| 6 — **Assets** (sprites, música, SFX) | ❌ pendente (Issues 19–22 — produção de arte/áudio) |
| 7 — Limpeza arquitetural | 🟡 parcial (Issue 23) |

**O que realmente falta para a Entrega Final:** os **assets** (Issues 19–22) e **playtests manuais** de teclado/mouse. A tabela de rastreabilidade da §2 abaixo reflete o estado *inicial*; a maioria dos ❌/🟡 já é **✅** hoje (level-up, dash, atributos via `PlayerStats`, consumíveis, equipáveis, raridade, geração de 12 salas, baús, loja, boss, economia, menu de fim e seleção de personagem).
 
---
 
## 1. Sumário Executivo
 
| Eixo | Estado | Cobertura |
| --- | --- | --- |
| T-01 Assets | ❌ Crítico | ~5% — só `tile_floor`/`tile_wall` + tileset; sem sprites de entidades, sem música, sem SFX |
| T-02 Player | ✅ Bom | ~70% — vida/ataque/movimento/perfis prontos; dash, stats discretos e level-up faltando |
| T-03 Inimigos | ✅ Muito bom | ~83% — vida/resistência/ataque/mira/movimento prontos; falta entidade Boss |
| T-04 Itens | ⚠️ Inicial | ~25% — Decorator/Iterator prontos; consumíveis, lógica de equip e cores de raridade faltando |
| T-05 Game Design | ⚠️ Inicial | ~20% — Builder/Director + validator escritos mas **desconectados do jogo** (ver 1.1); geração de 12 salas, baús, loja, economia, armas e tabelas faltando |
| T-06 UI | ⚠️ Parcial | ~60% — menus principal/pausa + HUD base prontos; falta menu de fim de jogo e inventário/descarte |
| GoF (23) | ⚠️ (referência) | 13/23 sólidos, ~4 parciais, ~6 ausentes |
 
- **Must-Have com mecânica funcional (mesmo que isolada):** ~15-17; mas **nenhuma run completa existe**
  (ver 1.1). A massa restante está parcial ou desconectada do loop.
- **Arquitetura** (gameplay → GameFacade → SignalBus → listeners): a estrutura existe, mas é parcialmente
  *bypassada* no jogo real (ex.: `player.gd` emite `player_died` direto em vez de `GameFacade.kill_player`).
---
 
## 1.1 Estado real jogável (verificado por leitura de código)
 
> Esta seção é o ponto mais importante: o que está escrito ≠ o que está ligado ao jogo que roda.
 
**O build jogável é uma única cena hardcoded.** [main_menu.gd:5](../scripts/ui/main_menu.gd#L5) chama
`change_scene_to_file("res://scenes/world/test_room.tscn")`. Logo:
 
1. **Geração de salas é código morto no fluxo de jogo.** `GameManager.load_room()`
   ([game_manager.gd:58](../scripts/autoloads/game_manager.gd#L58)) e todo o Builder/Director/`EnemyFactory`
   via builder **nunca são chamados** em runtime (confirmado por busca: `load_room` não tem chamador).
   A "estrutura de 12 salas" (US-41) **não existe na prática** — há uma sala fixa.
2. **Não há transição entre salas.** A porta ([door.gd](../scripts/world/door.gd)), ao destrancar, apenas
   desabilita a colisão (fica atravessável) — não há `Area2D` de passagem nem troca de sala. Andar na porta
   não leva a lugar nenhum. As únicas trocas de cena são menu↔test_room↔menu.
3. **Morte do jogador não tem efeito.** [player.gd:151](../scripts/player/player.gd#L151) `_die()` só emite
   `SignalBus.player_died`. O **único** listener desse sinal está numa cena de teste
   ([test_facade.gd](../scenes/test_facade.gd)) — não no jogo. Existe `GameFacade.kill_player()` (que
   chamaria `end_run`), mas **ninguém o chama**. Resultado: ao zerar a vida, nada acontece (sem game over,
   sem permadeath/reset). → **US-20 quebrado em runtime**; RNF-07 (reset ao morrer) não ocorre.
4. **Trava de porta por combate não funciona na cena jogada.** Em `test_room.tscn` a porta inicia
   destrancada e o `RoomValidator` é criado **sem** `managed_door_ids`, então a varredura de portas roda
   sobre lista vazia. O mecanismo existe (via RoomBuilder, que não roda). → **US-57 não integrado**.
5. **Cadeia de dano (CoR) não está ligada ao player.** Em `test_room.tscn` o nó Player não tem
   `damage_chain` atribuído → `take_damage` aplica dano cru. A CoR só é exercida pelo `DamageTester`
   (@tool de editor) e pela cena de teste, não no combate real.
**O que de fato roda em `test_room.tscn`:** movimento + colisão do player; tiro via ProjectilePool na
direção do mouse; spawners instanciando inimigos melee e ranged ([enemy_spawner.gd:8](../scripts/enemies/enemy_spawner.gd#L8));
inimigos perseguindo/mirando/atirando e aplicando dano; morte de inimigos; HUD de vida; menu de pausa (ESC).
 
**Conflito GDD × Backlog — RESOLVIDO (02/06/2026):** o backlog foi consolidado ao modelo do GDD. Atributos
do jogador = **Vida / Dano / Velocidade (+ Cooldown de Dash)**; o level-up oferece **+Dano / +Vida Máxima /
+Velocidade** (US-54). As USs que citavam Força/Destreza/Inteligência (US-25/42/53/68) foram reescritas
(backlog v1.1). Resta apenas **implementar** esses atributos no `player.gd` (hoje tem `max_health`,
`base_damage`, `move_speed`, `defense`, `resistance`).
 
---
 
## 2. Rastreabilidade US → código
 
Legenda: ✅ Feito · 🟡 Parcial · ❌ Ausente
 
| US | Épico | MoSCoW | Status | Evidência / lacuna |
| --- | --- | --- | --- | --- |
| US-01 sprite player | E-01 | Must | ❌ | `jogo/art/sprites/` só tem `tile_floor.png`, `tile_wall.png` |
| US-02 sprite inimigos | E-01 | Must | ❌ | sem assets |
| US-03 sprite itens | E-01 | Must | ❌ | sem assets |
| US-04 textura menu | E-01 | Must | 🟡 | `art/themes/main_theme.tres` existe; sem texturas |
| US-05 textura ambiente | E-01 | Should | 🟡 | `art/tilesets/room.tres` + 2 tiles |
| US-06..09 músicas | E-02 | Should | ❌ | AudioManager pronto, sem `.wav` em `art/music/` |
| US-10..17 SFX | E-03 | Must/Should | ❌ | sem `art/sounds/`; [audio_manager.gd](../scripts/autoloads/audio_manager.gd) busca arquivos inexistentes |
| US-18 vida em corações | E-04 | Must | 🟡 | vida em int + ProgressBar ([player.gd:17](../scripts/player/player.gd#L17)); não em corações visuais |
| US-19 cura | E-04 | Must | 🟡 | `heal()` existe ([player.gd:146](../scripts/player/player.gd#L146)) mas **nada o chama** (sem poções/sala segura ligadas) |
| US-20 morte | E-04 | Must | 🟡 | `_die()` emite `player_died` ([player.gd:151](../scripts/player/player.gd#L151)) mas **nada escuta** no jogo → morte sem efeito (ver 1.1) |
| US-21 dano ataque | E-05 | Must | ✅ | [projectile_base.gd:72](../scripts/projectiles/projectile_base.gd#L72) (funciona na test_room; CoR do player não ligada) |
| US-22 projéteis | E-05 | Must | ✅ | [player.gd:115](../scripts/player/player.gd#L115) + ProjectilePool (sem retorno melee do GDD §2.2) |
| US-23 movimentar | E-06 | Must | ✅ | [player.gd:63](../scripts/player/player.gd#L63) |
| US-24 colisões | E-06 | Must | ✅ | `player.tscn` CharacterBody2D + CollisionShape |
| US-25 atributos (Vida/Dano/Vel) | E-07 | Must | 🟡 | atributos-base existem no player; falta camada de progressão/modificadores estruturada |
| US-26 XP por consumíveis | E-07 | Must | ❌ | [game_manager.gd:14](../scripts/autoloads/game_manager.gd#L14) tem vars, sem incremento |
| US-27 modificadores | E-07 | Must | 🟡 | [student_profile.gd:18](../scripts/resources/student_profile.gd#L18) aplica modificadores base; sem modificadores dinâmicos por item/level |
| US-28 vida inimigos | E-08 | Must | ✅ | [enemy_base.gd:11](../scripts/enemies/enemy_base.gd#L11) |
| US-29 resistência | E-08 | Must | ✅ | [resistance_handler.gd](../scripts/damage/resistance_handler.gd) (Chain of Responsibility) |
| US-30 ataque+colisão | E-09 | Must | ✅ | [enemy_ranged.gd:49](../scripts/enemies/enemy_ranged.gd#L49), [enemy_melee.gd:38](../scripts/enemies/enemy_melee.gd#L38) |
| US-31 mira | E-09 | Must | ✅ | [enemy_ranged.gd:20](../scripts/enemies/enemy_ranged.gd#L20) |
| US-32 movimento | E-10 | Must | ✅ | [enemy_base.gd:63](../scripts/enemies/enemy_base.gd#L63) |
| US-33 padrões variados | E-10 | Must | ✅ | melee (chase) vs ranged (kite) |
| US-34 bombas | E-11 | Must | ❌ | só skeleton [consumable_base.gd](../scripts/consumables/consumable_base.gd) |
| US-35 chaves | E-11 | Must | ❌ | sem concreto |
| US-36 poções | E-11 | Must | ❌ | sem concreto |
| US-37 equipar armas | E-12 | Must | 🟡 | enum slots + API equip ([player.gd:36](../scripts/player/player.gd#L36)); sem armas concretas |
| US-38 equipar armaduras | E-12 | Must | 🟡 | slots existem; sem itens |
| US-39 equipar acessórios | E-12 | Must | 🟡 | slot existe; sem itens |
| US-40 tipos de sala | E-13 | Should | 🟡 | 4 receitas no [room_director.gd](../scripts/world/room_director.gd); **código morto** (não chamado em runtime) |
| US-41 estrutura 12 salas | E-13 | Must | ❌ | Builder existe mas `load_room` nunca é chamado; jogo roda 1 sala fixa, sem transição (ver 1.1) |
| US-42 tipos de arma por alcance | E-14 | Must | ❌ | sem armas concretas nem classificação longo/curto alcance |
| US-43 quantidades de armas | E-14 | Must | ❌ | sem tabela |
| US-44 tipos de inimigo + chefe | E-15 | Must | 🟡 | 3 tipos; "Sala do Chefão" sem entidade Boss ([room_director.gd:50](../scripts/world/room_director.gd#L50)) |
| US-45 quantidades de inimigos | E-15 | Must | 🟡 | hardcoded no director |
| US-46/47 tabelas de design | E-16 | Must | ❌ | só `profiles/*.tres` + [difficulty_config.gd](../scripts/resources/difficulty_config.gd) |
| US-48 menu principal | E-17 | Must | ✅ | [main_menu.gd](../scripts/ui/main_menu.gd) / `main_menu.tscn` |
| US-49 pausar | E-17 | Must | ✅ | [pause_menu.gd](../scripts/ui/pause_menu.gd) |
| US-50 retomar | E-17 | Must | ✅ | [pause_menu.gd:14](../scripts/ui/pause_menu.gd#L14) |
| US-51 inventário | E-18 | Must | 🟡 | só linha de consumíveis no HUD; sem inventário real |
| US-52 descartar itens | E-18 | Must | ❌ | sem UI de descarte |
| US-53 dash reduzível por atributo | E-06 | Must | 🟡 | dash ok ([player.gd:101](../scripts/player/player.gd#L101)); cooldown fixo, sem redução por modificador |
| US-54 level-up (+Dano/+Vida/+Vel) | E-07 | Must | ❌ | inexistente |
| US-55 seleção de personagem | E-07 | Must | 🟡 | 4 perfis `.tres` + registry; tela de seleção não confirmada |
| US-56 consumível de benefício | E-11 | Must | 🟡 | slot no HUD; sem lógica de substituição/efeito |
| US-57 saídas bloqueadas | E-13 | Must | 🟡 | mecanismo existe (validator + door), mas na test_room a porta inicia destrancada e o validator roda sem `managed_door_ids` (ver 1.1) |
| US-59 sair do menu | E-17 | Must | ✅ | [main_menu.gd:7](../scripts/ui/main_menu.gd#L7) |
| US-60 HUD completo | E-17 | Must | 🟡 | HP/score/time ok; faltam slots de arma/bomba/poção/chave/benefício |
| US-62 menu fim de jogo | E-17 | Must | ❌ | sem cena de game over/vitória |
| US-63 salas de baú | E-13 | Must | ❌ | sem classe/receita |
| US-64 salas seguras (cura total) | E-13 | Must | 🟡 | `build_rest_room()` existe; sem cura aplicada |
| US-65 portas trancadas/rochas | E-13 | Should | 🟡 | `door.starts_locked`; sem chave/bomba |
| US-66 anti-softblock | E-13 | Must | ❌ | sem garantia algorítmica |
| US-67 preview de recompensa na porta | E-13 | Must | ❌ | [door.gd](../scripts/world/door.gd) sem campo reward |
| US-68 consumível de status (+1 atributo/+1XP) | E-11 | Must | ❌ | sem script |
| US-69 raridade + cor | E-19 | Must | 🟡 | só `rare_decorator`; faltam Comum/Incomum/Épico + cores |
| US-70 moeda ao explodir baús | E-20 | Must | ❌ | sem sistema de moeda |
| US-71 loja com NPCs | E-20 | Must | ❌ | sem loja/NPCs |
| US-72 explodir baú (loot alt.) | E-11 | Must | ❌ | sem baú |
 
---
 
## 3. Inventário dos padrões GoF (referência, não prioridade)
 
> Mapa do que já existe no código. **Não** dita a ordem do roadmap. Aplicar padrão novo apenas quando ele
> simplificar a feature, nunca por obrigação.
 
**Sólidos (13):** Factory Method ([enemy_factory.gd](../scripts/enemies/enemy_factory.gd)), Builder + Director
([room_builder.gd](../scripts/world/room_builder.gd) / [room_director.gd](../scripts/world/room_director.gd)),
Singleton ([game_manager.gd](../scripts/autoloads/game_manager.gd), [audio_manager.gd](../scripts/autoloads/audio_manager.gd)),
Facade ([game_facade.gd](../scripts/autoloads/game_facade.gd)), Bridge ([hud_abstraction.gd](../scripts/ui/hud_abstraction.gd) + `renderers/`),
Decorator (`items/decorators/`), Chain of Responsibility (`damage/`), Iterator (`iterators/`),
Mediator ([signal_bus.gd](../scripts/autoloads/signal_bus.gd)), Observer (listeners do SignalBus),
Strategy (movimento de inimigos / `door`), Template Method (`consumable_base.gd`, `enemy_base.attack_sequence`),
Visitor ([room_validator.gd](../scripts/world/room_validator.gd)).
 
> Extras úteis fora dos 23 GoF clássicos: Multiton ([student_profile_registry.gd](../scripts/resources/student_profile_registry.gd))
> e Object Pool ([projectile_pool.gd](../scripts/world/projectile_pool.gd)).
 
**Parciais a consolidar (4):** Prototype, Adapter, Command, State.
 
**Ausentes (6):** Abstract Factory, Composite, Flyweight, Proxy, Interpreter, Memento.
 
> Onde *poderiam* encaixar de forma natural, **se** a feature pedir (sugestão, não meta): Composite → UI de
> slots de inventário; Flyweight → dados de tipo de item/inimigo nas tabelas; State → fases do boss / estado
> da run; Memento → snapshot do level-up. Implementar só se for o caminho mais simples.
 
---
 
## 4. Análise de Lacunas (por dependência)
 
1. **Atributos do jogador (Vida/Dano/Velocidade + Cooldown de Dash)** são pré-requisito de: level-up
   (US-54), redução de cooldown de dash (US-53), consumíveis de status (US-68), modificadores (US-27).
   → **fundação**.
2. **Sistema de itens concreto** (consumíveis + equipáveis) é pré-requisito de: HUD completo (US-60),
   inventário/descarte (US-51/52), baús (US-63), loja (US-71), raridade (US-69).
3. **Geração de run (12 salas)** é pré-requisito de: tipos de sala (US-40), baús (US-63), salas seguras
   (US-64), anti-softblock (US-66), preview de porta (US-67), boss (US-44).
4. **Economia (moeda)** depende de baús explodíveis (US-72/70) e habilita a loja (US-71).
5. **Tabelas de design** (US-46/47) sustentam balanceamento e são fonte única de valores para
   stats/itens/inimigos.
6. **Assets (T-01)** são ortogonais e podem correr em paralelo, mas bloqueiam os RNFs de clareza/feedback.
**Riscos de arquitetura a corrigir:** [room_builder.gd](../scripts/world/room_builder.gd) instancia cenas
via `load().instantiate()` ad-hoc; spawners (`basic_enemy_spawner.gd`, `ranged_enemy_spawner.gd`) não usam
`EnemyFactory`.
 
---
 
## 5. Roadmap em Ondas (foco: jogo jogável)
 
> Ordenado por dependência de gameplay, priorizando Must-Have. Esforço relativo: **P** (pequeno) ·
> **M** (médio) · **G** (grande). DoD = *Definition of Done*. Padrões GoF aparecem só como sugestão
> *opcional* quando simplificam — nunca como meta.
 
### Onda 0 — Integração do loop de jogo (pré-requisito de tudo)

> Hoje o jogo é uma sala fixa sem morte e sem progressão (ver 1.1). Sem isto, as demais ondas não compõem uma run.
- **Transição entre salas**: dar comportamento de passagem à porta destrancada (Area2D → carregar próxima sala) e ligar `GameManager.load_room()` ao fluxo (US-41 base). [M]
- **Morte → fim de run**: fazer o dano letal passar por `GameFacade.kill_player()` (emite `player_died` + `end_run(false)`) e exibir game over (liga US-20/US-62 e RNF-07 reset). [P]
- **Ligar o que já existe ao jogo real**: usar as salas do Builder em vez da `test_room` hardcoded; atribuir `managed_door_ids` ao validator (US-57) e `damage_chain` ao player. [M]

**DoD — Onda 0:**
- [ ] O loop completo menu → sala → progressão → morte → tela de fim → menu foi executado no Godot 4.6 sem erros de parse ou runtime
- [ ] A morte do player aciona `GameFacade.kill_player()` e exibe a tela de game over (sem o bug de "morte sem efeito" da seção 1.1)
- [ ] A transição entre salas ocorre via `GameManager.load_room()` — `test_room.tscn` hardcoded não é mais o destino do Play
- [ ] O `RoomValidator` recebe `managed_door_ids` e a porta tranca com inimigos vivos e destranca ao limpar a sala
- [ ] A `damage_chain` está atribuída ao player e a Chain of Responsibility processa o dano no combate real
- [ ] As cenas de teste existentes (`test_facade.gd`, `test_builder.gd`, `test_patterns.gd`) rodam sem `assert` disparando
- [ ] O código foi revisado por ao menos um outro membro da equipe via PR

### Onda 1 — Fundação de progressão (desbloqueia o resto do jogo)

- **Modelo de stats — DECIDIDO** (Vida/Dano/Velocidade + Cooldown de Dash, conforme GDD; backlog consolidado v1.1). Implementar esses atributos no player + progressão. [P]
- **Atributos no Player** (US-25, US-27) — `PlayerStats` como Resource + integração no `player.gd`. [M]
- **XP + Level-up congelando o jogo + escolha de stat** (US-26, US-54) — usar pause + UI de escolha. [M]
- **Dash com cooldown reduzível por Destreza** (US-53) — derivar de `PlayerStats`. [P]
- **Tabelas de design** (US-46, US-47) — Resources `.tres` (atributos, inimigos, itens, raridade, loja, recompensas) como fonte única de valores. [M]

**DoD — Onda 1:**
- [ ] `PlayerStats` existe como Resource e é a fonte única de Vida, Dano, Velocidade e Cooldown de Dash no `player.gd` (sem literais numéricos de balanceamento hardcoded)
- [ ] Subir de nível pausa o jogo, exibe UI de escolha de stat e aplica a alteração na mesma run
- [ ] O cooldown de dash é derivado do stat de Velocidade e reduz visivelmente ao aumentá-lo (US-53)
- [ ] Todos os valores de stats, inimigos e itens são lidos de tabelas `.tres` — busca por literais numéricos de balanceamento no código retorna zero ocorrências
- [ ] Testado manualmente: completar ao menos 2 ondas de inimigos, subir de nível e confirmar que o stat escolhido altera o comportamento do player
- [ ] O código foi revisado por ao menos um outro membro da equipe via PR

### Onda 2 — Sistema de itens concreto

- **Consumíveis**: bombas, chaves, poções (US-34/35/36), status +1/+1XP (US-68), benefício slot único (US-56). [M]
- **Equipáveis**: armas/armaduras/acessórios nos 5 slots com aplicação de modificadores (US-37/38/39). [M]
- **Raridade 4 níveis + cor** (US-69) — completar Comum/Incomum/Épico + mapa de cores (reaproveita os decorators existentes). [M]
- **Inventário + descarte + HUD completo** (US-51/52/60). [M]

**DoD — Onda 2:**
- [ ] Bomba, chave e poção são coletáveis, aparecem no HUD e produzem efeito ao ser usados (dano em área / abre porta trancada / restaura vida)
- [ ] Equipar arma, armadura e acessório altera o stat correspondente do player em runtime e o HUD reflete a mudança
- [ ] Os 4 níveis de raridade (Comum, Incomum, Raro, Épico) são visualmente distinguíveis por cor nos sprites ou UI
- [ ] O HUD exibe corretamente bombas, poções, chaves, arma equipada e benefício ativo (US-60)
- [ ] Descartar item do inventário remove-o e libera o slot sem causar erro (US-52)
- [ ] Testado manualmente: coletar, usar e equipar ao menos um item de cada tipo em uma run
- [ ] O código foi revisado por ao menos um outro membro da equipe via PR

### Onda 3 — Estrutura da run

- **Gerador de 12 salas** (US-41) com seleção variada 2-10 (US-40), salas seguras com cura (US-64), anti-softblock (US-66). [G]
- **Portas com chave/bomba** (US-65) + **preview de recompensa** na porta (US-67). [M]
- **Salas de baú** (US-63) + explodir baú com bomba → loot alternativo (US-72). [M]

**DoD — Onda 3:**
- [ ] Uma run gera exatamente 12 salas em sequência com tipos variados (combate, segura, baú, pré-boss, boss) conforme GDD §4.4
- [ ] Salas seguras restauram a vida total do player ao entrar
- [ ] Nenhuma run de teste encerra em softlock — ao menos 5 runs consecutivas têm sempre uma saída válida (US-66)
- [ ] A porta exibe preview da recompensa da próxima sala antes de ser atravessada (US-67)
- [ ] Baús existem e contêm loot; explodir com bomba libera loot alternativo (US-72)
- [ ] Portas trancadas por chave não abrem sem o item correto (US-65)
- [ ] O código foi revisado por ao menos um outro membro da equipe via PR

### Onda 4 — Boss, economia e loja

- **Entidade Boss** `enemy_boss.gd` (US-44) com fases de comportamento e quantidades por tabela (US-45). [M]
- **Moeda** ao explodir baús (US-70) — campo no GameManager + SignalBus. [P]
- **Sala de loja com NPCs** (Armeiro, Equipador, Boticário, Mentor) (US-71). [G]
- **Tipos de arma por stat** Pesada/Ágil/Intelectual (US-42, US-43). [M]

**DoD — Onda 4:**
- [ ] O Boss possui ao menos 2 fases de comportamento distintas e sua derrota exibe tela de vitória e encerra a run
- [ ] Explodir baús gera moeda contabilizada corretamente no `GameManager` e exibida no HUD (US-70)
- [ ] A loja exibe itens compráveis com preço e desconta a moeda corretamente ao confirmar compra (US-71)
- [ ] Os tipos de arma têm stats distintos lidos das tabelas de design (US-42/43)
- [ ] Testado manualmente: completar uma run de 12 salas com derrota do boss e ao menos uma compra na loja
- [ ] O código foi revisado por ao menos um outro membro da equipe via PR

### Onda 5 — UI e fechamento

- **Menu de fim de jogo** (vitória/derrota) (US-62). [P]
- **Tela de seleção de personagem** ligada ao registry de perfis (US-55). [P]

**DoD — Onda 5:**
- [ ] A tela de seleção de personagem exibe os perfis disponíveis e aplica o perfil escolhido ao iniciar a run (US-55)
- [ ] A tela de fim de jogo (vitória e derrota) exibe ao menos o número de salas percorridas e inimigos derrotados (US-62)
- [ ] O ciclo completo menu → seleção de personagem → run → fim → reset executa sem erros ou estado residual entre runs
- [ ] Inventário, XP e moeda estão zerados ao iniciar uma nova run (RNF-07)
- [ ] O código foi revisado por ao menos um outro membro da equipe via PR

### Onda 6 — Assets (paralelo desde o início)

- Sprites de player/inimigos/itens (US-01/02/03); texturas (US-04/05). [G]
- Músicas (US-06..09) e SFX (US-10..17) — só faltam arquivos; AudioManager já integra. [M]

**DoD — Onda 6:**
- [ ] Todos os sprites de player, inimigos e itens Must-Have estão visíveis nas cenas do jogo (sem placeholder de cor sólida)
- [ ] Ao menos uma música de fundo toca no menu e no jogo (arquivos `.wav` presentes em `art/music/`)
- [ ] SFX de tiro, dano recebido e morte do inimigo tocam nos eventos correspondentes
- [ ] O `AudioManager` não emite erros de arquivo não encontrado no console do Godot durante uma run completa
- [ ] Os RNF-01 a RNF-04 foram verificados manualmente em uma run completa por ao menos dois membros da equipe

### Onda 7 — Limpeza arquitetural (oportunística)

- Migrar `room_builder.gd`/spawners para usar `EnemyFactory` e centralizar os `load().instantiate()`. [M]
- *(Opcional)* Se durante as ondas algum padrão GoF tornar a feature mais limpa, aplicá-lo — sem virar meta separada.

**DoD — Onda 7:**
- [ ] Nenhum inimigo é instanciado fora do `EnemyFactory` — busca por `load().instantiate()` em scripts de inimigo/sala retorna zero ocorrências
- [ ] Os spawners da `test_room` foram removidos ou unificados ao `RoomBuilder`
- [ ] Todo fluxo de gameplay passa por `GameFacade`/`SignalBus` — sem chamadas diretas entre sistemas que deveriam usar sinais
- [ ] As cenas de teste existentes (`test_patterns.gd`, `test_builder.gd`, `test_facade.gd`) rodam sem erros após o refactor
- [ ] O código foi revisado por ao menos um outro membro da equipe via PR
---
 
## 5.1 Checklist Pré-Onda 1 (passos detalhados da Onda 0)
 
> Ordem sugerida. Marque cada passo ao concluir. Sem isto, não há run jogável e as ondas seguintes não compõem um jogo.
 
> **Status de execução (02/06/2026):** núcleo da Onda 0 implementado e validado (rodou no Godot 4.6 sem
> erros de parse/runtime). **Feito:** B1, B2, B4 (controlador `run.gd`/`run.tscn` com player/HUD/pausa/pool
> persistentes; `RoomBuilder` não cria mais player/HUD/pausa); C1-C3 (porta com `Area2D` de passagem →
> `SignalBus.door_entered`; sequência 0→11 mapeada por índice); D1-D2 (morte via `GameFacade.kill_player()`;
> tela de fim Game Over/Vitória); E1 (portas trancam com inimigos + entram no grupo `doors`; validator
> destranca ao limpar); E2 (`damage_chain` ligado ao player). **Parcial/pendente:** B3 (`test_room.tscn`
> apenas desreferenciada, arquivo mantido); D3 (reset acontece no próximo `start_run`; revisar limpeza por
> sistema em `run_ended`); E3 (builder usa `EnemyFactory`, mas os spawners da `test_room` seguem órfãos);
> F1-F2 (playtest manual do loop completo e rodar as cenas de teste — **pendente, requer você**).
> **Tilemap resolvido:** `RoomBuilder._paint_room()` agora pinta piso (source 0) com borda de paredes
> (source 1, com colisão) — salas têm visual e contenção. Refinamento (formato/aberturas alinhadas às
> portas, sprites temáticos) fica para depois.
 
### A. Decisões de equipe (ambas RESOLVIDAS em 02/06/2026)
- [x] **A1 — Modelo de stats. RESOLVIDO (02/06/2026):** atributos canônicos = **Vida/Dano/Velocidade (+ Cooldown de Dash)** e level-up = **+Dano/+Vida/+Velocidade**, conforme GDD. Backlog consolidado (v1.1): RF-07/08/10/13 e US-25/42/53/68 reescritas. Resta implementar no `player.gd`.
- [x] **A2 — Progressão de salas. RESOLVIDO (02/06/2026):** sequência linear 1→12 (GDD §4.4); o **player é persistente** e pertence ao controlador de Run (não à sala). Ao avançar de porta, a sala anterior é liberada e a próxima é carregada, **reposicionando o player existente** no `player_start` — vida/inventário/stats/XP são preservados entre salas e só resetam ao morrer (RNF-07).
### B. Estrutura de cena / dono do loop
- [ ] **B1 — Criar uma cena/controlador de "Run" persistente** que hospede o **player**, a sala atual, o HUD, a camada de pausa e o `ProjectilePool` (hoje tudo está embutido na `test_room` hardcoded). O player vive aqui, fora da sala (decisão A2).
- [ ] **B4 — `RoomBuilder` deixa de instanciar o player** ([room_builder.gd:70](../scripts/world/room_builder.gd#L70) e [:117](../scripts/world/room_builder.gd#L117)). A sala passa a expor apenas o `player_start`; o controlador de Run reposiciona o player persistente nele a cada carga.
- [ ] **B2 — `start_run()` deve carregar a Sala 1** via `GameManager.load_room()` em vez de `main_menu.gd` ir direto para `test_room.tscn`.
- [ ] **B3 — Aposentar/transformar `test_room.tscn`** em template preenchido pelo `RoomBuilder` (ou usar as salas do Director). Eliminar o caminho hardcoded.
### C. Transição entre salas
- [ ] **C1 — Adicionar gatilho de passagem na porta** (`Area2D` em `door.tscn`) que, com a porta destrancada e o player entrando, avisa o `GameManager`.
- [ ] **C2 — `GameManager` avança `current_room_index`** e chama `load_room()` da próxima sala da sequência (emitir `room_entered`).
- [ ] **C3 — Mapear índice → tipo de sala** (1 vazia, 2-10 variável, 11 pré-boss, 12 boss), nem que seja com um placeholder simples por enquanto.
### D. Morte, fim de run e permadeath
- [ ] **D1 — Dano letal passa por `GameFacade.kill_player()`** (que emite `player_died` + `end_run(false)`), em vez de `player.gd._die()` emitir o sinal cru. *(Alternativa: conectar `player_died` → `end_run`.)*
- [ ] **D2 — Criar tela de fim de jogo** (Game Over / Vitória) reagindo a `run_ended` (US-62), com botão "voltar ao menu".
- [ ] **D3 — Garantir reset em `run_ended`**: `GameManager.reset_run()` + sistemas que ouvem `run_ended` limpam seu estado (RNF-07). Validar que nada persiste entre runs.
### E. Religar o que já existe ao jogo real
- [ ] **E1 — `RoomBuilder` atribui `managed_door_ids` ao `RoomValidator`** e tranca portas quando a sala tem inimigos (US-57). Tratar caso de sala sem inimigos (porta começa aberta — `_is_room_cleared()` exige `_total_enemies > 0`).
- [ ] **E2 — Atribuir `damage_chain` ao player** na cena para a Chain of Responsibility rodar no combate real (hoje é nulo).
- [ ] **E3 — Unificar o caminho de spawn de inimigos** (RoomBuilder via `EnemyFactory` × spawners da `test_room`): escolher um só e remover o outro.
### F. Validação
- [ ] **F1 — Playtest manual do loop:** menu → Sala 1 → limpar sala → porta destranca → próxima sala → morrer → game over → reset → menu.
- [ ] **F2 — Rodar as cenas de teste de padrões** (`test_patterns.gd`, `test_builder.gd`, `test_facade.gd`, etc.) após o refactor para garantir que nada quebrou.
**DoD da Onda 0:** existe uma run jogável de ponta a ponta (mesmo que com salas placeholder), a morte encerra a run com reset e tela de fim, e o Builder/validator/CoR estão de fato no caminho do jogo.
 
---
 
## 6. Verificação
 
- Não há test runner/CI; a validação é feita no editor **Godot 4.6** (cena principal
  `res://scenes/ui/main_menu.tscn`, botão Play).
- Padrões: cenas de teste em [jogo/scenes/](../scenes/) (`test_patterns.gd`, `test_builder.gd`, etc.) — **F6**
  para rodar a cena atual; "passa" quando os `assert()` não disparam e a saída bate com os comentários.
- Para cada nova feature, adicionar/usar um tester (`@tool` ou cena standalone) seguindo o padrão existente.

---

## Referências

- [Backlog de Desenvolvimento](1.2.8.Backlog.md)
- Documentos de design em [jogo/docs/](.)

## Histórico de Versionamento

| Nome | Alteração | Versão | Data |
| --- | --- | --- | --- |
|[Mateus Vieira](https://github.com/matix0) e  [Vinícius Rufino](https://github.com/RufinoVfR)| Criação do roadmap a partir da varredura do código vs. backlog | v1.0 | 01/06/2026 |
| [Vinícius Rufino](https://github.com/RufinoVfR) | Expansão dos DoDs de frase única para listas de verificação estruturadas | v1.1 | 08/06/2026 |
| [Felipe Veríssimo](https://github.com/verissimoo) | Seção "🔄 Atualização — Entrega Final": loop jogável completo e cobertura por onda (Issues 01–18 concluídas; restam assets 19–22) | v1.2 | 22/06/2026 |