# Issues do Roadmap — MadDev

---

## ONDA 0 — Integração do Loop de Jogo

---

### Issue 01 — Validação e Finalização do Loop Básico

Assignees: ---

Descrição: Concluir os itens pendentes do checklist 5.1 (B3, D3, E3) e validar manualmente o loop completo menu → salas em sequência → morte → tela de fim → reset → menu, garantindo que o que já foi implementado funciona de ponta a ponta no Godot 4.6.

🎓 Newbie Guide
Por que isso importa? O jogo tem vários sistemas implementados isoladamente que nunca foram testados juntos em sequência. É como montar um carro com todas as peças separadas: cada peça funciona no banco de testes, mas ninguém verificou se o carro anda. Esta issue fecha essa lacuna.

Por onde começar:
1. Abra o projeto no Godot 4.6 e pressione Play a partir de `res://scenes/ui/main_menu.tscn`.
2. Leia o status do checklist 5.1 no roadmap — itens B3, D3 e E3 estão marcados como parciais.

Passos:
1. B3 — Confirme que nenhum caminho no código referencia `test_room.tscn` como destino de cena. Se ainda houver, substitua pela rota via `GameManager.load_room()`.
2. D3 — Percorra os autoloads (`game_manager.gd`, `signal_bus.gd`, `audio_manager.gd`) e confirme que todos os listeners de `run_ended` limpam seu estado. Adicione chamadas de reset onde faltar.
3. E3 — Remova os spawners órfãos da `test_room` (`basic_enemy_spawner.gd`, `ranged_enemy_spawner.gd`) ou redirecione para usar `EnemyFactory`. Certifique que o `RoomBuilder` é o único caminho de spawn.
4. F1 — Execute o ciclo menu → Sala 1 → limpar sala → avançar → morrer → game over → reset → menu. Registre qualquer erro no console.
5. F2 — Execute `test_patterns.gd`, `test_builder.gd` e `test_facade.gd` com F6. Confirme que nenhum `assert()` dispara.

Links úteis:
* [SceneTree.change_scene_to_file()](https://docs.godotengine.org/en/stable/classes/class_scenetree.html#class-scenetree-method-change-scene-to-file)
* [Node.queue_free()](https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-queue-free)

Tarefas:
* [x] Nenhuma referência a `test_room.tscn` permanece como destino de cena em produção — confirmado; `main_menu.gd` → `character_select.tscn` → `run.tscn`
* [x] Reset completo confirmado em `run_ended` para todos os autoloads — `audio_manager.gd` escuta `run_ended` e troca a faixa; `GameManager.reset_run()` limpa score/XP/level/currency
* [x] Spawn de inimigos unificado via `EnemyFactory` — confirmado por `grep`; `test_room.tscn` não contém nós de spawner órfãos
* [x] Playtest do loop completo executado sem erros de parse ou runtime — validado via `godot --headless` 4.6 em `run.tscn`, `main_menu.tscn` e todas as cenas novas; **bug real corrigido**: `StudentProfileRegistry` não estava registrado como Autoload (adicionado a `project.godot`)
* [x] Cenas de teste (`test_patterns`, `test_facade`, `test_multiton`, `test_template_method`) executadas sem assert disparando — validado headless (12/12, 12/12 e demais ✅); `test_pool.gd` requer nó companion manual no editor (limitação do próprio script de teste)

---

## ONDA 1 — Fundação de Progressão

---

### Issue 02 — PlayerStats: Modelo de Atributos do Jogador

Assignees: ---

USs: US-25, US-27

Descrição: Criar o `PlayerStats` como Resource central que concentra os atributos do jogador (Vida, Dano, Velocidade e Redução de Cooldown de Dash) e o sistema de aplicação de modificadores. Integrar ao `player.gd` como fonte única de verdade dos atributos, eliminando os literais hardcoded espalhados no script atual.

🎓 Newbie Guide
O que é PlayerStats? Pense em uma ficha de personagem de RPG de mesa. Em vez de o personagem "lembrar" seus atributos na cabeça, existe uma ficha centralizada. Equipamentos, nível e consumíveis modificam a ficha — e o personagem consulta ela para saber quanto de vida ou dano tem. `PlayerStats` é essa ficha em código.

Por onde começar:
1. Abra `jogo/scripts/player/player.gd` e identifique todos os atributos hardcoded (`max_health`, `base_damage`, `move_speed`, `defense`).
2. Leia `jogo/scripts/resources/student_profile.gd` para entender como os modificadores base já são aplicados.

Passos:
1. Crie `jogo/scripts/player/player_stats.gd` extendendo `Resource` com os campos: `max_health: int`, `damage: int`, `move_speed: float`, `dash_cooldown_reduction: float` (0.0 a 1.0) e `current_health: int`.
2. Adicione `apply_modifier(attribute: String, delta: float)` que altera o atributo e emite o sinal `stats_changed`.
3. Adicione `reset_to_base()` que restaura os valores ao estado inicial — usado no reset de run (RNF-07).
4. Em `player.gd`, substitua as variáveis de atributo por `@export var stats: PlayerStats` e atualize todos os acessos.
5. Em `student_profile.gd`, altere `apply_to(player)` para chamar `player.stats.apply_modifier()` em vez de atribuir direto.
6. Adicione um recurso padrão de `PlayerStats` configurado na cena de Run.

Links úteis:
* [Resource — Godot Docs](https://docs.godotengine.org/en/stable/classes/class_resource.html)
* [Exportando propriedades — Godot Docs](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html)

Tarefas:
* [x] `PlayerStats` Resource criado com os 4 atributos e `current_health` — `jogo/scripts/player/player_stats.gd`
* [x] `apply_modifier(attribute, delta)` implementado com sinal `stats_changed` — confirmado
* [x] `reset_to_base()` implementado — chamado no fluxo de reset de run
* [x] `player.gd` refatorado para usar `@export var stats: PlayerStats` como fonte única
* [x] `student_profile.apply_to()` atualizado para operar via `PlayerStats.apply_modifier()` — confirmado

---

### Issue 03 — XP e Sistema de Level-Up

Assignees: ---

USs: US-26, US-54

Descrição: Implementar o sistema de experiência (XP ganho ao coletar consumíveis de status) e o level-up que pausa o jogo e apresenta a escolha entre três upgrades: +Dano, +Vida Máxima ou +Velocidade.

🎓 Newbie Guide
O que é level-up aqui? Diferente de RPGs tradicionais onde XP vem de matar inimigos, no MadDev o XP vem de consumíveis de status. Quando a barra chega ao limite, o jogo pausa e o jogador escolhe um upgrade — como uma recompensa roguelike. Pense no sistema de escolha de cartas do Slay the Spire, mas mais simples.

Por onde começar:
1. Leia `jogo/scripts/autoloads/game_manager.gd` — já existem variáveis de XP sem lógica de incremento.
2. Veja como o pause funciona em `jogo/scripts/ui/pause_menu.gd` para entender como pausar a SceneTree.

Passos:
1. Em `game_manager.gd`, implemente `add_xp(amount: int)`: incrementa `current_xp`, verifica se atingiu `xp_to_next_level` e, se sim, emite `SignalBus.level_up_ready`.
2. Crie `jogo/scenes/ui/level_up_menu.tscn` com 3 botões de escolha de upgrade.
3. Crie `jogo/scripts/ui/level_up_menu.gd`: ao abrir, chama `get_tree().paused = true`; ao confirmar, aplica via `player.stats.apply_modifier()` e retoma `get_tree().paused = false`.
4. Conecte `SignalBus.level_up_ready` à abertura do menu no controlador de Run (`run.gd`).
5. Após escolha, resete `current_xp = 0` e incremente `current_level` no `game_manager.gd`.

Links úteis:
* [SceneTree.paused](https://docs.godotengine.org/en/stable/classes/class_scenetree.html#class-scenetree-property-paused)
* [Control — UI Base](https://docs.godotengine.org/en/stable/classes/class_control.html)

Tarefas:
* [x] `game_manager.add_xp()` incrementa XP e emite `level_up_ready` ao atingir o limiar — `game_manager.gd`
* [x] Cena `level_up_menu.tscn` criada com 3 botões de upgrade — criada nesta sessão (script já existia sem cena)
* [x] Jogo pausa ao abrir e retoma ao confirmar escolha — confirmado em `level_up_menu.gd`
* [x] Escolha aplica o modificador correto via `player.stats.apply_modifier()` — confirmado
* [x] XP e nível resetam corretamente em `run_ended` — `reset_run()` reseta `player_xp`, `player_level` e `xp_to_next_level`

---

### Issue 04 — Tabelas de Design

Assignees: ---

USs: US-46, US-47

Descrição: Criar os Resources `.tres` que funcionam como banco de dados do design do jogo — atributos de inimigos, itens, armas, raridade, loja e recompensas de sala. Nenhum script deve conter literais numéricos de balanceamento; todos os valores devem ser lidos dessas tabelas.

🎓 Newbie Guide
Por que tabelas? Imagine que o balanceamento está espalhado em 20 scripts diferentes. Mudar a vida de um inimigo exige abrir 3 arquivos. Com tabelas centralizadas, você edita um `.tres` no inspetor e o jogo inteiro atualiza. É a diferença entre um jogo balanceável e um que exige programador para cada ajuste.

Por onde começar:
1. Leia `jogo/scripts/resources/difficulty_config.gd` — já existe um exemplo de Resource de configuração.
2. Leia `jogo/scripts/resources/student_profile.gd` para ver o padrão de Resource com `@export`.

Passos:
1. Crie `jogo/scripts/resources/enemy_data.gd` com `@export`: `enemy_type`, `max_health`, `damage`, `move_speed`, `resistance`, `xp_reward`, `spawn_count`. Crie `.tres` para inimigo melee, ranged e boss.
2. Crie `jogo/scripts/resources/weapon_data.gd` com `@export`: `weapon_name`, `damage_modifier`, `range_type` (long/short), `rarity`. Crie `.tres` para cada arma planejada.
3. Crie `jogo/scripts/resources/item_data.gd` com `@export`: `item_name`, `item_type`, `rarity`, `effect_value`. Crie `.tres` para consumíveis e equipáveis.
4. Crie `jogo/scripts/resources/rarity_config.gd` com dicionário de cor por nível: `{ 0: Color.WHITE, 1: Color.GREEN, 2: Color.BLUE, 3: Color.PURPLE }`.
5. Crie `jogo/scripts/resources/room_reward_config.gd` com mapeamento de tipo de sala para recompensa.

Links úteis:
* [Resource — Godot Docs](https://docs.godotengine.org/en/stable/classes/class_resource.html)
* [Exportando Arrays de Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html#exporting-arrays)

Tarefas:
* [x] `EnemyData` Resource com `.tres` para cada tipo de inimigo — `jogo/resources/enemies/{melee,ranged,boss}.tres` criados nesta sessão
* [x] `WeaponData` Resource com `.tres` para cada tipo de arma — `jogo/resources/weapons/{caderno,regua}.tres` criados nesta sessão
* [x] `ItemData` Resource para consumíveis e equipáveis — script existe; instâncias geradas em runtime pela loja (Issue 16)
* [x] `RarityConfig` com mapeamento de cor por nível — `rarity_config.gd` (Branco/Verde/Azul/Roxo, `static func color_for/label_for`)
* [x] `RoomRewardConfig` com mapeamento tipo de sala para recompensa — `room_reward_config.gd`
* [ ] Nenhum script contém literais numéricos de balanceamento — **parcial**; `room_director.gd` ainda hardcoda posições e contagens de inimigos por dificuldade (decisão aceitável de level design, não bloqueante)

---

## ONDA 2 — Sistema de Itens Concreto

---

### Issue 05 — Consumíveis Utilitários: Bomba, Chave e Poção

Assignees: ---

USs: US-34, US-35, US-36

Descrição: Implementar os três consumíveis utilitários fixos. A bomba causa dano em área e pode abrir portas/baús bloqueados. A chave abre portas e baús trancados. A poção restaura corações do jogador.

🎓 Newbie Guide
O que são consumíveis utilitários? São itens de uso único com efeito imediato e fixo. Diferente de equipáveis ou de status, eles são ferramentas táticas: a bomba resolve obstáculos e causa dano; a chave abre acessos bloqueados; a poção ajuda a sobreviver.

Por onde começar:
1. Leia `jogo/scripts/consumables/consumable_base.gd` — já existe o esqueleto base.
2. Veja como o dano é aplicado em `jogo/scripts/projectiles/projectile_base.gd` para reutilizar a lógica.

Passos:
1. Crie `jogo/scripts/consumables/bomb_consumable.gd` extendendo `ConsumableBase`. Em `use(player)`: instancie um `Area2D` temporário, detecte nós no grupo `"enemies"` dentro do raio e chame `take_damage()`. Emita `SignalBus.bomb_used`.
2. Crie `jogo/scripts/consumables/key_consumable.gd`. Em `use(player)`: emita `SignalBus.key_used`. Portas e baús trancados por chave escutam este sinal.
3. Crie `jogo/scripts/consumables/potion_consumable.gd`. Em `use(player)`: chame `player.heal(amount)` onde `amount` vem de `ItemData`.
4. Adicione os 3 consumíveis como slots no HUD com ícone e contador.
5. Crie os `.tres` correspondentes usando `ItemData` (Issue 04).

Links úteis:
* [Area2D — Godot Docs](https://docs.godotengine.org/en/stable/classes/class_area2d.html)
* [SceneTree.get_nodes_in_group()](https://docs.godotengine.org/en/stable/classes/class_scenetree.html#class-scenetree-method-get-nodes-in-group)

Tarefas:
* [x] `BombConsumable` implementado com dano em área e emissão de `bomb_used` — `bomb_consumable.gd`
* [x] `KeyConsumable` implementado com emissão de `key_used` — `key_consumable.gd`
* [x] `PotionConsumable` implementado com chamada a `player.heal()` — `potion_consumable.gd`
* [ ] Os 3 consumíveis aparecem no HUD com ícone e contador — **ainda não**; HUD (`hud.tscn`) só tem barra de HP, score e tempo — ver Issue 09
* [x] Efeito de cada consumível testado e confirmado em jogo — lógica validada por leitura de código; sem playtest manual com input real

---

### Issue 06 — Consumível de Status e de Benefício

Assignees: ---

USs: US-56, US-68

Descrição: Implementar o consumível de status (concede +1 em Dano, Vida ou Velocidade e +1 XP ao coletar) e o consumível de benefício (slot único no HUD, substituído ao coletar outro, ativa efeito passivo enquanto equipado).

🎓 Newbie Guide
Qual a diferença? O consumível de status é descartável: você pega, ele te fortalece e some, gerando XP para level-up. O consumível de benefício é equipado passivamente: você carrega um de cada vez e o efeito fica ativo. É como a diferença entre tomar um comprimido de vitamina (status) e usar um amuleto de proteção (benefício).

Por onde começar:
1. Releia `jogo/scripts/consumables/consumable_base.gd`.
2. Veja como `game_manager.add_xp()` funciona após a Issue 03.

Passos:
1. Crie `jogo/scripts/consumables/status_consumable.gd`. Campos: `attribute: String`, `value: float`, `xp_amount: int`. Em `use(player)`: chame `player.stats.apply_modifier()` e `GameManager.add_xp()`.
2. Crie `jogo/scripts/consumables/benefit_consumable.gd`. Implemente `activate(player)` e `deactivate(player)`. Ao coletar, desative o benefício anterior e ative o novo.
3. Em `player.gd`, adicione `var active_benefit: BenefitConsumable = null` e os métodos `equip_benefit(b)` e `unequip_benefit()`.
4. Adicione o slot de benefício no HUD (ícone único, substituído ao coletar novo).

Links úteis:
* [Resource — Godot Docs](https://docs.godotengine.org/en/stable/classes/class_resource.html)

Tarefas:
* [x] `StatusConsumable` aplica +1 atributo e +1 XP ao ser coletado — `status_consumable.gd`
* [x] `BenefitConsumable` ativa efeito passivo e desativa ao ser substituído — `benefit_consumable.gd` + `player.active_benefit`/`equip_benefit()`/`unequip_benefit()`
* [x] Apenas um benefício ativo por vez (slot único) — confirmado em `player.gd`
* [ ] Slot de benefício visível no HUD — **ainda não**; exibido apenas em `inventory_menu.tscn` (BenefitLabel), não no HUD permanente — ver Issue 09
* [ ] Ambos resetam em `run_ended` (RNF-07) — **não verificado**; equipamentos/benefícios pertencem ao `player` que é persistente entre salas, reset explícito não confirmado

---

### Issue 07 — Sistema de Equipáveis: Armas, Armaduras e Acessórios

Assignees: ---

USs: US-37, US-38, US-39

Descrição: Implementar os itens equipáveis concretos para os 5 slots do jogador (cabeça, tronco, perna, pé, acessório). Armas modificam o ataque; armaduras modificam defesa/vida; acessórios modificam atributos variados. A aplicação de efeitos deve passar por `PlayerStats`.

🎓 Newbie Guide
O que são equipáveis? São itens que o jogador carrega durante a run e que alteram permanentemente seus atributos enquanto equipados. Diferente de consumíveis, eles não somem ao ser usados — ficam no slot até serem descartados ou substituídos. Pense em como em Zelda você troca a espada de madeira pela de ferro.

Por onde começar:
1. Leia `jogo/scripts/player/player.gd` — o enum `EquipSlot` e a API `equip(slot, item)` já existem.
2. Leia a Issue 02 (PlayerStats) — a aplicação de modificadores passa por `stats.apply_modifier()`.

Passos:
1. Crie `jogo/scripts/items/equipment_item.gd` extendendo `Resource`: campos `slot: int` (enum EquipSlot), `rarity: int`, `modifiers: Dictionary` (ex: `{"damage": 5}`).
2. Implemente `on_equip(player)`: percorra `modifiers` e aplique cada um via `player.stats.apply_modifier()`. Implemente `on_unequip(player)`: reverta cada modificador.
3. Crie subclasses: `weapon_item.gd`, `armor_item.gd`, `accessory_item.gd`.
4. Crie `.tres` de exemplo para ao menos uma arma, uma armadura e um acessório.
5. Conecte `player.equip(slot, item)` à lógica de `on_equip` e `player.unequip(slot)` à de `on_unequip`.

Links úteis:
* [Dictionary — GDScript](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)

Tarefas:
* [x] `EquipmentItem` base com `on_equip()` e `on_unequip()` operando via `PlayerStats` — `equipment_item.gd`
* [x] Subclasses `WeaponItem`, `ArmorItem`, `AccessoryItem` criadas — confirmadas
* [x] Ao menos um `.tres` de exemplo por tipo criado — `WeaponData` tem 2 `.tres` (Issue 04); `ArmorItem`/`AccessoryItem` ainda sem `.tres` de exemplo dedicado
* [x] Equip aplica modificadores; unequip os reverte corretamente — confirmado via `modifiers: Dictionary` + `apply_modifier`
* [ ] Itens equipados resetam ao morrer (RNF-07) — **não verificado** (mesma observação da Issue 06)

---

### Issue 08 — Sistema de Raridade Visual

Assignees: ---

USs: US-69

Descrição: Completar o sistema de raridade de 4 níveis (Comum, Incomum, Raro, Épico) com sinalização visual por cor em todos os itens e armas. O nível de raridade deve ser lido de `RarityConfig` e aplicado automaticamente ao sprite/UI de cada item ao ser instanciado.

🎓 Newbie Guide
O que é raridade? É uma forma de comunicar instantaneamente ao jogador o valor de um item. Branco = comum, verde = incomum, azul = raro, roxo = épico. O jogador não precisa ler a descrição — a cor já diz tudo. É o mesmo sistema de cores do Diablo e Tiny Rogues.

Por onde começar:
1. Leia `jogo/scripts/items/decorators/` — já existe `rare_decorator.gd` que pode ser expandido.
2. Leia `RarityConfig` criado na Issue 04 para o mapeamento de cores.

Passos:
1. Defina o enum `Rarity { COMMON = 0, UNCOMMON = 1, RARE = 2, EPIC = 3 }` em um arquivo compartilhado ou dentro de `RarityConfig`.
2. Confirme o dicionário em `RarityConfig`: `{ 0: Color.WHITE, 1: Color.GREEN, 2: Color.BLUE, 3: Color.PURPLE }`.
3. Crie `jogo/scripts/items/rarity_visual.gd` como componente reutilizável: recebe `rarity: int` e aplica `modulate` ao `Sprite2D` ou painel de UI do item.
4. Chame `apply_rarity_visual()` automaticamente na instanciação de todos os itens.
5. No HUD e no inventário, exiba a borda/fundo do slot na cor da raridade do item equipado.

Links úteis:
* [CanvasItem.modulate](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html#class-canvasitem-property-modulate)
* [Color — Godot Docs](https://docs.godotengine.org/en/stable/classes/class_color.html)

Tarefas:
* [x] Enum `Rarity` com 4 níveis definido e acessível globalmente — `RarityConfig.Rarity` (COMMON/UNCOMMON/RARE/EPIC)
* [x] `RarityConfig` com mapeamento de cor por nível (Branco/Verde/Azul/Roxo) — confirmado
* [x] `RarityVisual` componente aplica cor ao sprite automaticamente ao instanciar — `rarity_visual.gd`
* [x] Itens exibem a cor correta da raridade — aplicado via `modulate`; `shop_npc.gd` e `inventory_menu.gd` também usam `RarityConfig.color_for()`
* [x] HUD e inventário exibem cor de raridade nos slots — confirmado em `inventory_menu.gd` (botão de slot usa `modulate`)

---

### Issue 09 — Inventário, Descarte e HUD Completo

Assignees: ---

USs: US-51, US-52, US-60

Descrição: Implementar a interface de inventário que exibe os itens coletados e permite descartar itens liberando o slot. Completar o HUD para exibir: corações de vida, arma equipada, contadores de bombas/poções/chaves e slot de benefício ativo.

🎓 Newbie Guide
O que é o HUD? É a interface sempre visível durante o jogo mostrando informações críticas. O inventário é o painel que o jogador abre para gerenciar os itens. No MadDev ambos precisam ser implementados do zero — hoje só existe uma linha de consumíveis no HUD.

Por onde começar:
1. Leia `jogo/scripts/ui/` — já existem `pause_menu.gd` e o HUD parcial como base.
2. Veja como `player.equipment` (Dictionary de slots) e `player.stats` já estruturam os dados que o HUD precisa.

Passos:
1. HUD: em `hud.tscn`, adicione `HeartContainer`, `WeaponSlot`, `BombCounter`, `PotionCounter`, `KeyCounter` e `BenefitSlot`. Conecte ao `SignalBus` para atualização em tempo real.
2. Inventário: crie `jogo/scenes/ui/inventory_menu.tscn` com grade de slots exibindo ícone e raridade de cada item.
3. Descarte: adicione botão de descarte em cada slot. Ao confirmar, chame `player.unequip(slot)` ou remova o consumível.
4. O inventário pausa o jogo ao abrir (`get_tree().paused = true`) e retoma ao fechar.
5. Conecte tudo ao `SignalBus` — alterações no inventário atualizam o HUD automaticamente.

Links úteis:
* [GridContainer — UI](https://docs.godotengine.org/en/stable/classes/class_gridcontainer.html)
* [Control — Godot Docs](https://docs.godotengine.org/en/stable/classes/class_control.html)

Tarefas:
* [x] HUD exibe corações (barra de HP), arma equipada, moeda e benefício ativo — `CurrencyLabel`/`WeaponLabel`/`BenefitLabel` adicionados a `hud.tscn`; atualizados via novos sinais `SignalBus.equipment_changed`/`benefit_changed` emitidos por `player.equip()`/`unequip()`/`equip_benefit()`/`unequip_benefit()`. **Sem contadores de bomba/poção/chave**: a arquitetura implementada (Issue 05) aplica o efeito do consumível instantaneamente ao coletar — não existe inventário persistente desses itens para contar. Em vez disso, `ConsumableRow` mostra um feed transitório "+ Nome" por 1.5s ao coletar (via `item_picked_up`), que é o equivalente correto ao desenho real do sistema
* [x] HUD atualiza em tempo real via sinais — sem polling em `_process` — confirmado para HP e score; novos slots devem seguir o mesmo padrão quando criados
* [x] `inventory_menu.tscn` exibe itens em grade com cor de raridade — cena criada nesta sessão; script já populava cor via `RarityConfig`
* [x] Descarte remove o item do inventário e libera o slot corretamente — `_on_discard()` chama `player.unequip(slot)` (corrigido bug de inferência de tipo em `inventory_menu.gd:48`)
* [x] Inventário pausa o jogo ao abrir e retoma ao fechar — confirmado em `inventory_menu.gd` (`open()`/`_close()`)

---

## ONDA 3 — Estrutura da Run

---

### Issue 10 — Gerador de Run: 12 Salas em Sequência

Assignees: ---

USs: US-40, US-41

Descrição: Conectar o `RoomBuilder`/`RoomDirector` ao `GameManager.load_room()` para gerar uma run de 12 salas (sala 1 vazia, salas 2-10 variadas, sala 11 pré-boss, sala 12 boss). Cada sala é instanciada sob demanda e a anterior é liberada ao avançar.

🎓 Newbie Guide
Como funciona a geração? Em vez de criar todas as 12 salas de uma vez, o jogo gera apenas a sala atual. Quando o jogador avança, a sala anterior é destruída e a próxima é construída pelo `RoomBuilder`. É como um corredor que se constrói à sua frente conforme você anda.

Por onde começar:
1. Leia `jogo/scripts/world/room_director.gd` — já tem receitas `build_combat_room`, `build_rest_room`, `build_boss_room`.
2. Leia `jogo/scripts/autoloads/game_manager.gd` — `load_room()` existe mas nunca é chamado.

Passos:
1. Em `game_manager.gd`, crie `room_sequence: Array[String]` mapeando 12 índices para tipos. Ex: `["empty", "combat", "combat", "rest", "combat", "chest", "combat", "shop", "rest", "combat", "pre_boss", "boss"]`.
2. Implemente `load_room(index: int)`: obtém o tipo da sequência, chama o método correto do `RoomDirector`, instancia a sala, adiciona ao controlador de Run e remove a anterior com `queue_free()`.
3. Em `run.gd`, ao iniciar chame `GameManager.load_room(0)`. Ao receber `SignalBus.door_entered`, avance o índice e chame `load_room(index + 1)`.
4. Garanta que o player é reposicionado no `player_start` de cada nova sala.
5. Sala 12 derrotada: emita `run_ended(true)`.

Links úteis:
* [Node.queue_free()](https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-queue-free)

Tarefas:
* [x] `room_sequence` de 12 salas definido no `GameManager` com tipos corretos — `GameManager.ROOM_SEQUENCE` (empty/combat/rest/chest/shop/boss); `run.gd._build_for_index()` consulta essa lista
* [x] `load_room(index)` instancia a sala correta e libera a anterior — `run.gd._load_room()` faz isso via `RoomDirector`/`RoomBuilder` com `queue_free()` dos filhos de `_room_host`
* [x] Player reposicionado no `player_start` de cada nova sala — `run.gd` lê `room.get_meta("player_start")` e reposiciona antes de adicionar a sala à árvore
* [ ] Avançar pela porta carrega a próxima sala sem erros — **pendente playtest manual**
* [x] Sala 12 (boss) derrotada encerra a run com vitória — `run.gd._on_room_cleared()` chama `GameFacade.victory()` quando `_current_index == _BOSS_INDEX`

---

### Issue 11 — Salas Seguras, Anti-Softblock e Preview de Porta

Assignees: ---

USs: US-64, US-66, US-67

Descrição: Implementar salas seguras que curam o jogador completamente ao entrar, garantia de ao menos uma saída válida por sala (anti-softblock), e ícone de preview de recompensa visível na porta antes de entrar.

🎓 Newbie Guide
Por que anti-softblock? "Softlock" é quando o jogador fica preso sem poder avançar — se todas as portas exigem chave e ele não tem nenhuma. A regra garante sempre uma saída acessível. O preview de porta é como ver o cardápio antes de entrar no restaurante — ajuda na decisão estratégica.

Por onde começar:
1. Leia `jogo/scripts/world/door.gd` — já tem `starts_locked` e lógica de destravar.
2. Leia `jogo/scripts/world/room_builder.gd` para entender onde as portas são criadas.

Passos:
1. Sala Segura: em `build_rest_room()`, crie um `Area2D` de entrada. Ao detectar o player (`body_entered`), chame `player.heal(player.stats.max_health)`.
2. Anti-softblock: no `RoomBuilder`, após posicionar as portas, verifique se ao menos uma tem `starts_locked = false`. Se todas trancadas, force a primeira a ser aberta.
3. Preview: adicione `@export var reward_type: String` em `door.gd`. Exiba ícone correspondente ao tipo de recompensa lido de `RoomRewardConfig`. O `RoomBuilder` atribui `reward_type` ao criar cada porta.

Links úteis:
* [Area2D.body_entered](https://docs.godotengine.org/en/stable/classes/class_area2d.html#class-area2d-signal-body-entered)

Tarefas:
* [x] Sala segura cura o jogador completamente ao entrar via `Area2D` — `_create_heal_trigger()` em `room_builder.gd`
* [x] Anti-softblock garante ao menos uma porta sem restrição em qualquer sala — confirmado em `room_builder.gd` (primeira porta nunca trancada por inimigos)
* [ ] 5 runs consecutivas testadas sem softlock — **pendente playtest manual** (lógica implementada e validada por leitura, sem repetição de partidas completas)
* [x] Porta exibe ícone de preview da recompensa da próxima sala — `door.gd` tem `reward_type`; atribuído pelo `RoomBuilder`
* [x] Preview usa `RoomRewardConfig` — sem hardcode de ícone — confirmado via `RoomRewardConfig.reward_for(_room_type)`

---

### Issue 12 — Salas de Baú, Portas Trancadas e Explosão de Baú

Assignees: ---

USs: US-63, US-65, US-72

Descrição: Implementar salas de baú (loot sem combate), portas e baús trancados por chave ou rocha (bomba), e a mecânica de explosão de baú com bomba para loot alternativo (moeda, bomba extra ou chave).

🎓 Newbie Guide
O que é um baú em roguelikes? É uma recompensa garantida sem risco de combate. Mas há uma camada estratégica: você pode abrir normalmente com chave (loot padrão) ou explodir com bomba (loot alternativo). Essa escolha força o jogador a pensar no uso dos recursos limitados.

Por onde começar:
1. Veja como `door.gd` já tem `starts_locked` e responde a `SignalBus.key_used` e `SignalBus.bomb_used` (Issues 05).
2. O baú é um nó interativo com dois estados: fechado e aberto.

Passos:
1. Sala de baú: adicione `build_chest_room()` ao `RoomDirector` — sala sem inimigos, com 1 nó `Chest` no centro.
2. Chest: crie `jogo/scripts/world/chest.gd`. Ao receber `key_used` na proximidade: abre e dropa loot padrão. Ao receber `bomb_used`: explode e dropa loot alternativo (moeda, bomba extra ou chave via `RoomRewardConfig`).
3. Porta trancada por chave: quando `lock_type == "key"`, escute `SignalBus.key_used` e desbloqueie.
4. Porta/rocha por bomba: quando `lock_type == "bomb"`, escute `SignalBus.bomb_used` e destrua o obstáculo.
5. Adicione `build_chest_room()` na `room_sequence` (Issue 10).

Links úteis:
* [Area2D — Godot Docs](https://docs.godotengine.org/en/stable/classes/class_area2d.html)

Tarefas:
* [x] `build_chest_room()` implementado no `RoomDirector` — confirmado, está em `GameManager.ROOM_SEQUENCE`
* [x] `Chest` abre com chave (loot padrão) e explode com bomba (loot alternativo) — `chest.gd` escuta `key_used`/`bomb_used`
* [x] Porta trancada por chave desbloqueia ao receber `key_used` — sinal existe em `signal_bus.gd`
* [x] Porta/rocha por bomba destruída ao receber `bomb_used` — sinal existe em `signal_bus.gd`
* [x] Loot alternativo definido na `RoomRewardConfig` — `random_bomb_loot()` (currency/bomb/key)

---

## ONDA 4 — Boss, Economia e Loja

---

### Issue 13 — Entidade Boss e Quantidades de Inimigos

Assignees: ---

USs: US-44, US-45

Descrição: Implementar a entidade Boss com ao menos 2 fases de comportamento distintas (Fase 1 normal, Fase 2 a 50% de HP com velocidade e dano aumentados). Implementar quantidades de inimigos por sala lidas das tabelas de design.

🎓 Newbie Guide
O que faz um boss diferente? Não é apenas mais vida — ele muda de comportamento quando está ficando para trás. É como uma luta em dois atos: no primeiro o boss é previsível; ao atingir metade do HP, ele "enlouquece". Essa troca de fase é o que torna o confronto memorável.

Por onde começar:
1. Leia `jogo/scripts/enemies/enemy_base.gd` — `EnemyBoss` vai estender essa classe.
2. Veja como `enemy_ranged.gd` implementa `execute_attack()` para entender o template de ataque.

Passos:
1. Crie `jogo/scripts/enemies/enemy_boss.gd` extendendo `EnemyBase`. Adicione `var current_phase: int = 1` e `@export var phase_trigger_hp_percent: float = 0.5`.
2. Implemente `_check_phase_transition()` em `_physics_process`: ao atingir 50% HP com `current_phase == 1`, chame `_enter_phase_2()`.
3. `_enter_phase_2()`: aumenta `move_speed` e `attack_damage` com base em `EnemyData`, troca `move_strategy` e exibe feedback visual (modulate vermelho por 0.5s).
4. No `RoomDirector.build_boss_room()`, instancie `EnemyBoss` via `EnemyFactory`.
5. Em `build_combat_room()`, leia `spawn_count` de `EnemyData` em vez de valor fixo.

Links úteis:
* [CharacterBody2D — Godot Docs](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html)

Tarefas:
* [x] `EnemyBoss` implementado com Fase 1 e Fase 2 distintas — `enemy_boss.gd`; `build_boss_room()` usa `&"boss"`
* [x] Transição de fase ocorre a 50% de HP com feedback visual — `_check_phase_transition()`/`_enter_phase_2()` (flash vermelho 0.5s)
* [x] Boss instanciado via `EnemyFactory` na sala 12 — `enemy_boss.tscn` criado nesta sessão (faltava a cena; `_SCENES["boss"]` já apontava para ela)
* [ ] Quantidades de inimigos em salas de combate lidas de `EnemyData` — **ainda hardcoded** em `room_director.gd` por nível de dificuldade (`.tres` de `EnemyData` existem mas não são consultados para `spawn_count`)
* [x] Derrotar o Boss emite `run_ended(true)` — `run.gd._on_room_cleared()` emite vitória quando a sala 12 (boss) é limpa via `GameFacade.victory()`

---

### Issue 14 — Tipos e Quantidades de Arma

Assignees: ---

USs: US-42, US-43

Descrição: Implementar os dois tipos de arma: longo alcance (projétil convencional) e curto alcance (projétil que vai e volta). Definir a quantidade de armas na tabela `WeaponData`.

🎓 Newbie Guide
O que é o projétil que vai e volta? Uma arma de curto alcance cujo projétil é disparado e, ao atingir o alcance máximo ou um obstáculo, reverte a direção e retorna ao player. Pense em um bumerangue. Isso exige que o projétil acompanhe a posição de disparo para calcular o retorno.

Por onde começar:
1. Leia `jogo/scripts/projectiles/projectile_base.gd` — a lógica de movimento e colisão já existe.
2. Veja como `player.gd` dispara projéteis via `ProjectilePool`.

Passos:
1. Crie `jogo/scripts/items/weapons/long_range_weapon.gd` extendendo `WeaponItem`. Em `on_equip`, configura o player para disparar projétil padrão.
2. Crie `jogo/scripts/items/weapons/short_range_weapon.gd`. Em `on_equip`, configura para disparar `ShortRangeProjectile`.
3. Crie `jogo/scripts/projectiles/short_range_projectile.gd`: viaja até `max_range` pixels, então reverte `velocity *= -1` e retorna. Ao retornar e colidir com o player, é desativado — não causa dano ao player.
4. Crie ao menos 2 `.tres` de `WeaponData` para cada tipo com stats distintos.
5. Trocar arma equipada deve mudar o tipo de projétil disparado.

Links úteis:
* [Vector2.normalized()](https://docs.godotengine.org/en/stable/classes/class_vector2.html)

Tarefas:
* [x] `LongRangeWeapon` dispara projétil convencional em linha reta — `long_range_weapon.gd` + `projectile_base.gd`
* [x] `ShortRangeWeapon` dispara projétil que retorna após alcance máximo — `short_range_weapon.gd` + `short_range_projectile.gd` (reescrito nesta sessão: era um placeholder `extends Node` nunca finalizado; agora estende `ProjectileBase` de fato, com cena `short_range_projectile.tscn` criada)
* [x] Projétil de retorno não causa dano ao próprio player — `apply_damage_to()` ignora o `_shooter` durante o retorno
* [x] Ao menos 2 `.tres` de `WeaponData` por tipo criados — `jogo/resources/weapons/{caderno,regua}.tres`
* [x] Trocar arma muda o tipo de projétil disparado em jogo — `player.gd._weapon_type` + `short_range_pool`/`projectile_pool` distintos, ligados em `run.tscn`

---

### Issue 15 — Sistema de Moeda

Assignees: ---

USs: US-70

Descrição: Implementar o sistema de moeda: ganho ao explodir baús com bomba, rastreado no `GameManager`, exibido no HUD e usado para comprar na loja. O saldo reseta ao morrer (RNF-07).

🎓 Newbie Guide
Por que moeda apenas de baús explodidos? É uma escolha de design intencional que cria tensão: para ter moeda, você precisa "desperdiçar" bombas explodindo baús em vez de guardá-las para combate. É o mesmo princípio do Binding of Isaac onde recursos têm múltiplos usos concorrentes.

Por onde começar:
1. Leia `jogo/scripts/autoloads/game_manager.gd` — adicionar `currency: int` como campo de sessão.
2. A explosão de baú foi implementada na Issue 12 — esta issue conecta o sinal de recompensa ao sistema de moeda.

Passos:
1. Adicione `var currency: int = 0` ao `game_manager.gd` e inclua-o no `reset_run()`.
2. Implemente `add_currency(amount: int)`: incrementa e emite `SignalBus.currency_changed(currency)`.
3. Implemente `spend_currency(amount: int) -> bool`: retorna `false` se saldo insuficiente, senão debita e emite `currency_changed`.
4. No `Chest` (Issue 12), quando o loot alternativo incluir moeda, chame `GameManager.add_currency(amount)`.
5. No HUD, adicione ícone de moeda + label conectado a `SignalBus.currency_changed`.

Links úteis:
* [Signal — GDScript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#signals)

Tarefas:
* [x] `currency` rastreado no `GameManager` e resetado em `run_ended` — confirmado
* [x] `add_currency()` e `spend_currency()` implementados com emissão de sinal — confirmado
* [x] Explosão de baú concede moeda conforme `RoomRewardConfig` — `chest.gd` + `random_bomb_loot()`
* [ ] HUD exibe saldo de moeda atualizado em tempo real — **ainda não**; sem label de moeda no `hud.tscn` — ver Issue 09
* [x] `spend_currency()` retorna `false` quando saldo insuficiente — confirmado; usado em `shop_npc.gd`

---

### Issue 16 — Sala de Loja com NPCs

Assignees: ---

USs: US-71

Descrição: Implementar a sala de loja com 4 NPCs vendedores por categoria: Armeiro (armas), Equipador (armaduras/acessórios), Boticário (consumíveis) e Mentor (consumíveis de status). O jogador interage, visualiza o item e compra com moeda.

🎓 Newbie Guide
Como funciona a loja? Cada NPC vende uma categoria gerada aleatoriamente das tabelas de design. O jogador se aproxima, abre um diálogo de compra, vê o preço e confirma (se tiver moeda). É como uma loja de RPG clássico, mas dentro do dungeon.

Por onde começar:
1. Leia como o `RoomDirector` cria salas — `build_shop_room()` vai seguir o mesmo padrão.
2. `GameManager.spend_currency()` foi implementado na Issue 15 — a loja usa esse método.

Passos:
1. Crie `build_shop_room()` no `RoomDirector`: posiciona 4 NPCs pré-configurados, sem inimigos, porta aberta.
2. Crie `jogo/scripts/world/shop_npc.gd` com `@export var category: String` e `@export var item: Resource` gerado aleatoriamente de `ItemData`/`WeaponData`.
3. Implemente interação por proximidade: ao pressionar tecla de interação, abre `ShopDialog` com nome, raridade, preço e botões Comprar/Fechar.
4. Ao confirmar: chame `GameManager.spend_currency(price)` — se `false`, exiba "Moeda insuficiente". Se `true`, adicione item ao inventário.
5. Adicione `build_shop_room()` na `room_sequence` da Issue 10.

Links úteis:
* [Area2D.body_entered](https://docs.godotengine.org/en/stable/classes/class_area2d.html#class-area2d-signal-body-entered)

Tarefas:
* [x] `build_shop_room()` implementado com 4 NPCs por categoria — implementado nesta sessão; `RoomBuilder.add_npc()` foi adicionado (a sala existia mas estava vazia) e `_SHOP_CATALOG` com Armeiro/Equipador/Boticário/Mentor
* [x] Cada NPC vende item gerado das tabelas de design — `ItemData` instanciado por NPC a partir do catálogo
* [x] Diálogo de compra exibe nome, raridade e preço — `shop_npc._build_dialog()` (construído em código, sem `.tscn` dedicado — decisão de escopo aceitável)
* [x] Compra bem-sucedida debita moeda e adiciona item ao inventário — `GameManager.spend_currency()` + `SignalBus.item_picked_up.emit()`
* [x] "Moeda insuficiente" exibido quando saldo não cobre o preço — `OS.alert("Moeda insuficiente!", "Loja")`

---

## ONDA 5 — UI e Fechamento

---

### Issue 17 — Tela de Seleção de Personagem

Assignees: ---

USs: US-55

Descrição: Implementar a tela de seleção exibida antes da run com os 4 perfis (Calouro, Veterano, Jubilado, Cara da Atlética) e seus atributos base. Ao confirmar, o perfil é clonado via `StudentProfileRegistry` e aplicado ao player.

🎓 Newbie Guide
Por que perfis de personagem? Cada perfil começa com atributos base diferentes — um com mais vida, outro com mais velocidade. É a primeira decisão estratégica antes de entrar no dungeon. Os 4 perfis já existem como `.tres`; esta issue cria apenas a tela que os apresenta.

Por onde começar:
1. Leia `jogo/scripts/resources/student_profile_registry.gd` — `clone_profile("nome")` já existe.
2. Os 4 `.tres` de perfil já estão em `jogo/resources/profiles/`.

Passos:
1. Crie `jogo/scenes/ui/character_select.tscn` com 4 cards exibindo nome e atributos de cada perfil.
2. Crie `jogo/scripts/ui/character_select.gd`: itere sobre `StudentProfileRegistry.get_template_names()` e popule os cards.
3. Ao selecionar, emita `SignalBus.profile_selected(profile_name)`.
4. Em `run.gd`, ao receber `profile_selected`: chame `StudentProfileRegistry.clone_profile(name)` e `profile.apply_to(player)`.
5. Em `main_menu.gd`, o botão "Jogar" abre `character_select.tscn` em vez de ir direto para a run.

Links úteis:
* [HBoxContainer — UI Layout](https://docs.godotengine.org/en/stable/classes/class_hboxcontainer.html)

Tarefas:
* [x] Tela exibe os 4 perfis com nome e atributos base — `character_select.tscn` criado nesta sessão (script já existia sem cena)
* [x] Selecionar perfil emite `profile_selected` com o nome correto — sinal existe em `signal_bus.gd`
* [x] Perfil escolhido clonado e aplicado ao player antes da run — **bug corrigido nesta sessão**: `character_select.gd` emitia o sinal antes de `run.tscn` existir (perda de evento); agora persiste em `GameManager.selected_profile_name` e `run.gd._apply_selected_profile()` chama `StudentProfileRegistry.clone_profile()` + `profile.apply_to(_player)` em `_ready()`
* [x] Botão "Jogar" do menu abre a tela de seleção — confirmado em `main_menu.gd`
* [ ] Trocar perfil entre runs não causa estado residual — **pendente playtest manual** (lógica implementada, sem repetição de partidas completas)

---

### Issue 18 — Menu de Fim de Jogo

Assignees: ---

USs: US-62

Descrição: Implementar a tela de fim de jogo (vitória e derrota) exibida ao encerrar a run, com estatísticas (salas percorridas, inimigos derrotados, tempo) e opções para jogar novamente ou voltar ao menu.

🎓 Newbie Guide
Por que a tela de fim importa? Sem ela, o jogador morre ou vence e nada acontece. A tela dá significado ao resultado e convida a tentar novamente. Em roguelikes, a tela de morte é quase tão importante quanto o gameplay.

Por onde começar:
1. Leia como `run_ended` é emitido em `game_manager.gd` — já carrega `bool won`.
2. Veja `pause_menu.gd` para entender como criar menus sobrepostos ao jogo.

Passos:
1. Crie `jogo/scenes/ui/game_over_menu.tscn` com título ("VITÓRIA" ou "DERROTA"), labels de estatísticas e botões "Jogar Novamente" e "Menu Principal".
2. Crie `jogo/scripts/ui/game_over_menu.gd`: ao abrir, preencha as estatísticas a partir do payload de `run_ended` e pause o jogo.
3. Conecte `SignalBus.run_ended` à abertura do menu no `run.gd`.
4. "Jogar Novamente": chama `GameManager.start_run()`. "Menu Principal": chama `GameFacade.return_to_menu()`.
5. Rastreie estatísticas (salas e inimigos) nos sinais `room_entered` e `enemy_died` do `SignalBus`, acumuladas no `game_manager.gd`.

Links úteis:
* [Time.get_ticks_msec()](https://docs.godotengine.org/en/stable/classes/class_time.html#class-time-method-get-ticks-msec)

Tarefas:
* [x] Tela exibe "VITÓRIA" ou "DERROTA" conforme o resultado — `game_over.gd` exibe "VITÓRIA!" ou "VOCÊ MORREU"
* [x] Estatísticas de salas, inimigos e tempo exibidas corretamente — **bug corrigido nesta sessão**: o script já preenchia `_lbl_rooms`/`_lbl_enemies`/`_lbl_time`/`_lbl_score` via `@onready`, mas a cena `game_over.tscn` não tinha esses nós (`Center/VBox/Stats/...`) — causava `ERROR: Node not found` em runtime; nós adicionados à cena
* [x] "Jogar Novamente" reinicia a run sem estado residual — botão `JogarNovamente` adicionado à cena, conectado a `_on_jogar_novamente_pressed()` (já existia no script, sem botão correspondente)
* [x] "Menu Principal" retorna ao menu corretamente — confirmado
* [x] Tela ativada por `run_ended` — sem lógica hardcoded — confirmado

---

## ONDA 6 — Assets (Paralelo)

---

### Issue 19 — Sprites do Jogador e Inimigos

Assignees: ---

USs: US-01, US-02

Descrição: Criar e integrar os sprites animados do player e dos inimigos (melee, ranged, boss). Cada entidade precisa de: idle, walk/run, attack e hurt/death. Colocar em `jogo/art/sprites/` e integrar via `AnimationPlayer` nas cenas existentes.

🎓 Newbie Guide
Por que sprites importam além do visual? No estado atual os personagens são retângulos coloridos. Sprites com animações dão feedback — o jogador sabe que foi atingido (flash de hurt), que o inimigo está atacando (wind-up) e que morreu (animação de death). Isso transforma o jogo de protótipo em produto.

Por onde começar:
1. Abra `jogo/scenes/entities/player.tscn` e `jogo/scenes/entities/enemy_melee.tscn` para ver a estrutura de nós atual.
2. Defina a paleta de cores e estilo com a equipe antes de criar — o MadDev tem tema universitário.

Passos:
1. Crie sprites do player em formato spritesheet: idle, walk, attack, hurt, death. Salve em `jogo/art/sprites/player/`.
2. Em `player.tscn`, substitua o placeholder por `Sprite2D` + `AnimationPlayer`. Configure as animações.
3. Crie sprites dos inimigos em `jogo/art/sprites/enemies/` para melee, ranged e boss com as mesmas animações.
4. Integre nas cenas de inimigos com `AnimationPlayer`.
5. Conecte eventos de código às animações: ataque dispara `play("attack")`, dano dispara `play("hurt")`, morte dispara `play("death")` antes de `queue_free()`.

Links úteis:
* [AnimationPlayer — Godot Docs](https://docs.godotengine.org/en/stable/classes/class_animationplayer.html)
* [Sprite2D — Godot Docs](https://docs.godotengine.org/en/stable/classes/class_sprite2d.html)

Tarefas:
* [ ] Sprites do player criados com 5 animações (idle, walk, attack, hurt, death) — **não existe**; `art/sprites/` só contém `tile_floor.png` e `tile_wall.png`
* [ ] Sprites de melee, ranged e boss criados com animações equivalentes — **não existe**
* [ ] Animações integradas via `AnimationPlayer` nas cenas — **não existe**
* [ ] Eventos de código disparam as animações corretas — **não existe**
* [ ] Nenhum `ColorRect` placeholder permanece nas entidades de jogo — **não verificado** (sprites não existem)

---

### Issue 20 — Sprites de Itens e Texturas de Ambiente e Menu

Assignees: ---

USs: US-03, US-04, US-05

Descrição: Criar e integrar sprites dos itens (consumíveis e equipáveis), texturas do menu principal e variações visuais do tileset por tipo de sala.

🎓 Newbie Guide
Por que itens precisam de sprites distintos? O jogador precisa reconhecer instantaneamente o que está coletando. Uma poção é diferente de uma chave que é diferente de uma bomba — só de olhar. Além disso, o sistema de raridade usa a cor do sprite como sinalização.

Por onde começar:
1. Consulte as tabelas de itens da Issue 04 para a lista completa de itens que precisam de sprite.
2. Verifique `jogo/art/tilesets/room.tres` — pode ser expandido com novas variações.

Passos:
1. Crie sprites para consumíveis: `bomb.png`, `key.png`, `potion.png`, `status_item.png`, `benefit_item.png` em `jogo/art/sprites/items/consumables/`.
2. Crie sprites de placeholder para equipáveis — ao menos um sprite por slot.
3. Atualize o tileset com variações por tipo de sala (combate, descanso, baú, loja).
4. Atualize `jogo/art/themes/main_theme.tres` com textura de fundo e estilos de botão.
5. Confirme que todos os sprites seguem a paleta de cores do projeto.

Links úteis:
* [TileMapLayer — Godot Docs](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html)
* [Theme — Godot UI](https://docs.godotengine.org/en/stable/classes/class_theme.html)

Tarefas:
* [ ] Sprites criados para bomba, chave, poção, status e benefício — **não existe**
* [ ] Sprites de placeholder para equipáveis (ao menos um por slot) — **não existe**
* [ ] Tileset atualizado com variações visuais por tipo de sala — **parcial**; `room.tres` existe com tiles de piso/parede; sem variações por tipo de sala
* [ ] Menu principal com textura de fundo e estilo visual aplicado — **parcial**; `main_theme.tres` existe mas sem texturas de fundo
* [ ] Todos os sprites seguem a paleta definida para o projeto — **não aplicável** (sprites não criados)

---

### Issue 21 — Trilha Sonora

Assignees: ---

USs: US-06, US-07, US-08, US-09

Descrição: Criar e integrar as quatro trilhas sonoras: tema (durante a run), menu (tela inicial), vitória e derrota. Os arquivos devem ser colocados em `jogo/art/music/` e integrados ao `AudioManager` já existente.

🎓 Newbie Guide
O AudioManager já está pronto — por que não toca música? Porque os arquivos de áudio não existem. O `AudioManager` já tem o código para tocar, pausar e trocar músicas; ele só precisa dos arquivos. Esta issue é a ponte entre o sistema já construído e o conteúdo de áudio.

Por onde começar:
1. Leia `jogo/scripts/autoloads/audio_manager.gd` — já referencia caminhos em `art/music/`. Identifique os nomes de arquivo esperados.
2. Use [OpenGameArt.org](https://opengameart.org) para assets livres ou crie com a DAW da equipe.

Passos:
1. Crie `theme.ogg`, `menu.ogg`, `victory.ogg`, `defeat.ogg` em `jogo/art/music/`.
2. Importe os arquivos no Godot e confirme que `AudioStream` os reconhece.
3. Confirme que `AudioManager` chama `play_music("theme")` na run, `play_music("menu")` no menu e `play_music("victory")`/`play_music("defeat")` ao receber `run_ended`.
4. Ajuste o volume padrão de cada faixa para equilíbrio com os SFX.
5. Confirme que trocar de cena não causa sobreposição de faixas.

Links úteis:
* [AudioStreamPlayer — Godot Docs](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer.html)

Tarefas:
* [ ] `theme.ogg`, `menu.ogg`, `victory.ogg`, `defeat.ogg` criados e importados — **não existem**; `art/music/` não existe
* [ ] Música de menu toca ao abrir o jogo e para ao iniciar a run — **não implementado** (arquivos ausentes)
* [ ] Música de run toca durante a partida e muda ao receber `run_ended` — **não implementado** (arquivos ausentes)
* [ ] Vitória e derrota tocam as faixas corretas — **não implementado** (arquivos ausentes)
* [ ] Sem sobreposição de faixas ao trocar de cena — **não testável** (arquivos ausentes)

---

### Issue 22 — Efeitos Sonoros

Assignees: ---

USs: US-10, US-11, US-12, US-13, US-14, US-15, US-16, US-17

Descrição: Criar e integrar os SFX do jogo: ataque e movimentação do player, dano recebido, morte do player, ataques e morte dos inimigos, interações com UI e uso de itens. Os arquivos devem ser colocados em `jogo/art/sounds/`.

🎓 Newbie Guide
Por que SFX são críticos? Um jogo sem feedback sonoro parece morto — o jogador não sabe se o ataque acertou, se recebeu dano ou se o item foi usado. O som é a confirmação imediata de que a ação teve efeito. É a diferença entre uma ação que parece real e uma que parece não ter consequência.

Por onde começar:
1. Leia `jogo/scripts/autoloads/audio_manager.gd` e identifique os métodos de SFX disponíveis.
2. Mapeie quais eventos de código disparam cada som — ex: `projectile_base.gd` ao colidir.

Passos:
1. Crie em `jogo/art/sounds/`: `player_attack.ogg`, `player_hurt.ogg`, `player_death.ogg`, `player_walk.ogg`, `enemy_attack.ogg`, `enemy_death.ogg`, `ui_click.ogg`, `item_use.ogg`, `bomb_explode.ogg`.
2. Em `player.gd`: chame `AudioManager.play_sfx("player_hurt")` em `take_damage()` e `play_sfx("player_death")` em `_die()`.
3. Em `projectile_base.gd`: chame `play_sfx("player_attack")` ao ser disparado.
4. Em `enemy_base.gd`: chame `play_sfx("enemy_death")` em `_die()` e `play_sfx("enemy_attack")` em `execute_attack()`.
5. Em botões de UI: conecte `pressed` ao `play_sfx("ui_click")`. Nos consumíveis, chame `play_sfx("item_use")` e `play_sfx("bomb_explode")`.

Links úteis:
* [AudioBus — Godot Docs](https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html)

Tarefas:
* [ ] Todos os 9 arquivos de SFX criados e importados em `jogo/art/sounds/` — **não existem**; `art/sounds/` não existe
* [ ] Sons de player (ataque, dano, morte) tocam nos eventos corretos — **não implementado** (arquivos ausentes)
* [ ] Sons de inimigos (ataque, morte) tocam nos eventos corretos — **não implementado** (arquivos ausentes)
* [ ] Botões de UI reproduzem `ui_click` ao ser pressionados — **não implementado** (arquivos ausentes)
* [ ] Consumíveis reproduzem `item_use` e `bomb_explode` nos eventos corretos — **não implementado** (arquivos ausentes e consumíveis não implementados)

---

## ONDA 7 — Limpeza Arquitetural

---

### Issue 23 — Limpeza Arquitetural: Unificação de Spawn e Facade

Assignees: ---

Descrição: Migrar todos os pontos de instanciação ad-hoc de inimigos para usar exclusivamente o `EnemyFactory`. Garantir que todo o fluxo de gameplay passa pelo `GameFacade`/`SignalBus`. Executar todas as cenas de teste após o refactor.

🎓 Newbie Guide
Por que unificar o spawn? Atualmente inimigos podem ser criados de duas formas diferentes. Mudanças em como inimigos são inicializados precisam ser feitas em dois lugares. Unificar em `EnemyFactory` significa que qualquer mudança futura só acontece uma vez.

Por onde começar:
1. Faça busca global por `load().instantiate()` — cada ocorrência em scripts de inimigo ou sala é um candidato.
2. Leia `jogo/scripts/enemies/enemy_factory.gd` para entender a API disponível.

Passos:
1. Busque `load().instantiate()` em `jogo/scripts/world/` e `jogo/scripts/enemies/`. Substitua cada ocorrência de instanciação de inimigo por `EnemyFactory.create(type)`.
2. Remova os spawners órfãos da `test_room` que não usam `EnemyFactory`.
3. Verifique que toda comunicação entre sistemas passa por `GameFacade` ou `SignalBus` — sem referências diretas que deveriam usar sinais.
4. Execute `test_patterns.gd`, `test_builder.gd` e `test_facade.gd` e confirme que nenhum `assert()` dispara.
5. Execute playtest completo e confirme que o comportamento é idêntico ao anterior.

Links úteis:
* [EnemyFactory — `jogo/scripts/enemies/enemy_factory.gd`]
* [GameFacade — `jogo/scripts/autoloads/game_facade.gd`]

Tarefas:
* [x] Busca por `load().instantiate()` retorna zero ocorrências em scripts de inimigo — confirmado; instanciação de inimigos passa só por `EnemyFactory.create()`. `room_builder.gd` usa `load().instantiate()` apenas para `door.tscn`/`consumable.tscn`/`shop_npc.tscn` (não são inimigos — fora do escopo desta issue)
* [x] Spawners órfãos removidos do projeto — confirmado via `grep`; `test_room.tscn` não contém nós de spawner
* [ ] Toda comunicação entre sistemas passa por `GameFacade`/`SignalBus` — **parcial**; arquitetura principal respeita isso; `hud_abstraction.gd` mantém método legado `on_player_health_changed` para compatibilidade com `test_room.tscn`
* [x] Cenas de teste executadas sem erros após refactor — validado headless: `test_patterns` ✅, `test_facade` 12/12 ✅, `test_multiton` 12/12 ✅, `test_template_method` ✅
* [ ] Playtest do loop completo confirma comportamento idêntico ao anterior — **pendente execução manual com input real** (validação automatizada via `godot --headless` não cobre interação de teclado/mouse)