# Contexto de Implementação — MadDev (jogo de Arquitetura)

Atualizado em 2026-06-20. Ver `tasks.md` para o checklist detalhado por issue
(Backlog/Roadmap em `docs/Documentacao/`).

## Branch e estado do git

Trabalho corrente está na branch **`game`** (não `main`). Convenção de commit:
prefixo `[SETUP]`/`[FEAT]`/`[FIX]`/`[DOC]`, **sem** `Co-Authored-By` ou
qualquer referência a Claude/IA nas mensagens — instrução explícita e
permanente do usuário. `CLAUDE.md` nunca é versionado (está no `.gitignore`).

Últimos commits relevantes (mais recente primeiro):
```
9df116f [FIX] Adapta UI para nova resolução base 640x360 (16:9 responsivo)
37c1565 [FIX] Recompensa de sala não era concedida, sem preview e diálogo da loja preso
c4fc66a [FEAT] Issue 09 — Completa HUD com moeda, arma equipada e benefício ativo
```

Há edições **não commitadas e intencionais do próprio usuário** (ajustadas à
mão no editor Godot, NÃO reverter sem ele pedir):
- `jogo/scenes/enemies/enemy.tscn`, `enemy_melee.tscn`, `enemy_ranged.tscn`
- `jogo/scenes/player/player.tscn`
São ajustes de raio de colisor e escala de `Sprite2D` (ex.: enemy radius
8.0→25.0, scale 0.125→0.4; player capsule radius 31→19, scale 0.5→0.35) —
tuning visual feito olhando o jogo rodando, relacionado à nova resolução
640x360. Continue sem tocar nesses arquivos até o usuário confirmar que
terminou o ajuste.

Há também arquivos não rastreados sem uso aparente no código (nenhuma cena/
script referencia): `jogo/art/thumbjogo.jpg(.import)`, `jogo/art/sprites/
item.png(.import)`. Não foram comitados nem apagados — presumivelmente
assets que o usuário está preparando para uso futuro.

## Resolução / responsividade 16:9 (mudança desta sessão)

Usuário alterou o canvas de referência de 320x180 para **640x360** (mesma
proporção 16:9), mantendo a janela final em 1280x720
(`window/stretch/mode="canvas_items"`). Isso reduz o fator de stretch de 4x
para 2x — qualquer UI com tamanho de pixel absoluto (fontes, offsets fixos de
`Control`) renderiza na metade do tamanho visual anterior se não compensada.

Compensação aplicada (commit `9df116f`):
- `project.godot`: `window/stretch/aspect="keep"` adicionado; nova seção
  `[gui]` com `theme/default_font_size=32` (dobro do padrão 16) — corrige a
  maioria dos menus de uma vez, já que eles usam `anchors_preset=15` ou
  containers com `grow`.
- `hud.tscn`: offsets do `VBoxContainer` dobrados (200→400, 120→240) e
  `HealthBar.custom_minimum_size` dobrado (120→240).
- `door.tscn` / `shop_npc.tscn`: o `RewardLabel` e o `RichTextLabel` de fala
  do NPC são rótulos no **espaço do mundo** (anexados ao sprite, não à
  camada de UI) — receberam `theme_override_font_sizes` fixo em 10px para
  não herdar o novo tamanho global de 32px e ficarem desproporcionais a um
  tile pequeno.

Deliberadamente **não tocado**: `Camera2D.zoom` (player.tscn, ainda
`Vector2(0.4, 0.4)`) e colisores/escalas de sprite — o usuário está
ajustando isso manualmente no editor em paralelo (ver seção acima). Se ao
testar o mundo parecer desproporcional à nova resolução, os números de
spawn/posicionamento de sala são gerados em `room_builder.gd`/
`room_director.gd` (não há como tunar isso no editor, é código).

## Estado geral

Issues 01–18 (lógica de jogo) estão **funcionalmente completas e validadas**
via `godot --headless` 4.6 (sem erros de parse/runtime nas cenas testadas).
Issues 19–22 (sprites, música, SFX) são puramente produção de arte/áudio —
nenhum arquivo existe em `jogo/art/sprites|music|sounds` além dos tiles
básicos; não é trabalho de código.

## Bugs reportados pelo usuário após playtest manual (corrigidos)

1. **Sem descrição de recompensa na porta** — `door.gd` já tinha o campo
   `reward_type`, mas nada o exibia. Adicionado `RewardLabel` em
   `door.tscn` + `RoomRewardConfig.description_for()`; `door._ready()`
   preenche o texto e esconde o label quando `reward_type == &"none"`.
2. **Salas não davam recompensa ao matar todos os inimigos** —
   `room_validator.gd` só desbloqueava portas e emitia `room_cleared`;
   nada concedia a recompensa em si. Adicionado
   `RoomRewardConfig.currency_for(reward)` e
   `run.gd._grant_room_reward()`, chamado em `_on_room_cleared()`: concede
   moeda (`GameManager.add_currency()`) conforme o tipo de sala atual em
   `GameManager.ROOM_SEQUENCE[_current_index]`. Salas sem inimigos (rest/
   chest/shop/empty) nunca emitem `room_cleared` (guard em
   `room_validator._is_room_cleared()`), então não há recompensa duplicada
   — chest/shop já entregam a própria recompensa por interação direta.
3. **Diálogo do NPC da loja não fechava** — `shop_npc._open_dialog()`
   pausa a árvore (`get_tree().paused = true`) antes de adicionar o
   diálogo, mas o `PanelContainer` criado em `_build_dialog()` não tinha
   `process_mode = ALWAYS`; com `process_mode` padrão (PAUSABLE), os
   botões "Comprar"/"Fechar" nunca recebiam input. Corrigido setando
   `root.process_mode = Node.PROCESS_MODE_ALWAYS` no diálogo construído.

## O que foi feito nesta sessão (além do já existente)

1. **Cenas `.tscn` faltantes** — vários scripts de UI/gameplay foram escritos
   em sessões anteriores mas nunca tiveram a cena correspondente criada,
   o que quebrava o jogo em runtime (`Node not found`, identificadores não
   resolvidos). Criadas:
   - `scenes/ui/character_select.tscn`
   - `scenes/ui/level_up_menu.tscn`
   - `scenes/ui/inventory_menu.tscn`
   - `scenes/enemies/enemy_boss.tscn`
   - `scenes/world/shop_npc.tscn`
   - `scenes/projectiles/short_range_projectile.tscn`

2. **Bugs reais corrigidos** (encontrados rodando `godot --headless` 4.6,
   não pelo relatório textual do tasks.md anterior, que estava desatualizado):
   - `StudentProfileRegistry` nunca foi registrado como Autoload em
     `project.godot` apesar do comentário no próprio script instruindo isso.
     Sem isso, `character_select.gd` falhava com
     `Identifier "StudentProfileRegistry" not declared`.
   - `game_over.tscn` não tinha os nós `Center/VBox/Stats/{Rooms,Enemies,Time,Score}`
     nem o botão "Jogar Novamente" que `game_over.gd` já esperava — causava
     `ERROR: Node not found` ao entrar em game over.
   - `inventory_menu.gd:48` tinha `var captured_slot := slot_key` com erro de
     inferência de tipo (Variant vindo de `Dictionary.keys()`) — trocado por
     `.bind(slot_key)`.
   - `character_select.gd` emitia `profile_selected` e mudava de cena antes
     de `run.tscn` existir — o sinal se perdia. Resolvido persistindo a
     escolha em `GameManager.selected_profile_name`, lido por
     `run.gd._apply_selected_profile()` em `_ready()`.
   - `short_range_projectile.gd` era um placeholder
     (`extends Node # Será substituído por ProjectileBase quando a cena for
     criada`) nunca finalizado — Issue 14 (arma de curto alcance) não
     funcionava de fato. Reescrito para estender `ProjectileBase`
     corretamente, com lógica de retorno (bumerangue) e sem dano ao atirador.

3. **Funcionalidade nova implementada** (a lógica existia parcialmente, mas
   faltavam peças para fechar o ciclo):
   - `RoomBuilder.add_npc()` / `_create_npc()` — a sala de loja
     (`build_shop_room()`) existia mas não populava nenhum `ShopNPC`.
     Adicionado catálogo fixo de 4 vendedores (Armeiro/Equipador/Boticário/Mentor)
     em `room_director.gd`.
   - Player agora tem `short_range_pool` além de `projectile_pool`; `_weapon_type`
     decide qual pool é usado em `_shoot()`. Os dois pools são ligados em
     `run.tscn` (`ProjectilePool` e `ShortRangePool`).
   - `.tres` de dados de balanceamento (Issue 04) criados:
     `resources/enemies/{melee,ranged,boss}.tres`,
     `resources/weapons/{caderno,regua}.tres`.

## Decisões de escopo (intencionais, não são bugs)

- **Diálogo da loja é construído em código** (`shop_npc._build_dialog()`),
  sem `.tscn` dedicado. Funciona, mas se quiser refinar visualmente, criar
  `scenes/ui/shop_dialog.tscn` e adaptar.
- **Quantidades de inimigos por sala continuam hardcoded** em
  `room_director.build_combat_room()` por nível de dificuldade, mesmo com
  `EnemyData.spawn_count` existindo nos `.tres`. Ligar isso é mecânico
  (ler `EnemyData` em vez do `match difficulty`) mas não foi feito — baixo
  risco, é só dado de design.
- **Reset de equipamento/benefício em `run_ended`** — confirmado e corrigido
  nesta sessão: `_on_run_ended()` em `player.gd` zerava os Dictionaries
  direto (`equipment[slot] = null`), pulando `on_unequip()`/`deactivate()`
  e os sinais. Trocado para chamar `unequip()`/`unequip_benefit()` (na
  ordem correta, antes de `stats.reset_to_base()`) para reverter
  modificadores e emitir os sinais que o HUD agora escuta.
- **Sem contador persistente de bomba/poção/chave no HUD** — os
  consumíveis (Issue 05) aplicam efeito instantâneo ao coletar
  (`ConsumableBase._on_pickup()` chama `_apply_effect()` e `queue_free()`
  na mesma chamada); não existe inventário/contagem desses itens em
  nenhum lugar do código. Implementar contadores reais exigiria redesenhar
  o sistema de consumíveis para "carregar e usar depois" — não fiz isso
  por ser uma mudança de arquitetura, não um bug. Em vez disso, o HUD
  mostra um feed transitório ("+ Nome do item" por 1.5s) via
  `SignalBus.item_picked_up`, que é a confirmação visual fiel ao desenho
  real implementado.

## HUD completo (Issue 09) — feito nesta sessão

`hud.tscn` ganhou `CurrencyLabel`, `WeaponLabel` e `BenefitLabel`.
Novos sinais no `SignalBus` (Mediator): `equipment_changed(slot, item)` e
`benefit_changed(benefit)`, emitidos por `player.equip()`/`unequip()`/
`equip_benefit()`/`unequip_benefit()`. `hud_abstraction.gd` escuta esses
sinais + `currency_changed` + `item_picked_up`, sem polling em `_process`.
`WeaponLabel` só reage ao slot 0 (`EquipSlot.HEAD`), que é o slot
reaproveitado por `WeaponItem` (ver comentário em `weapon_item.gd:9`) —
não existe um slot de arma dedicado no enum `EquipSlot` atual.
2. **Issues 19–22 (assets)** — sprites de player/inimigos/itens, música,
   SFX. Trabalho de produção de arte, não de programação.
3. **Playtest manual com input real** — toda a validação feita nesta sessão
   foi via `godot --headless` (carregamento de cena, parse, testes
   automatizados com assert). Nenhum teste cobriu input de teclado/mouse
   (mover, atirar, dar dash, abrir inventário com tecla, comprar na loja
   pressionando "ui_accept" perto do NPC). Recomenda-se abrir o projeto no
   editor e jogar uma run completa.

## Como validar rapidamente (sem abrir o editor)

```bash
# Parse + autoloads + cenas, sem travar esperando input:
timeout 10 /caminho/para/Godot_v4.6-stable_linux.x86_64 --headless --path jogo/ res://scenes/world/run.tscn

# Testes automatizados (saem sozinhos, têm prints com ✅/❌):
timeout 10 .../Godot --headless --path jogo/ res://scenes/test_patterns.tscn
```

Para os scripts de teste sem `.tscn` (`test_builder.gd`, `test_facade.gd`,
`test_multiton.gd`, `test_pool.gd`, `test_template_method.gd`), crie um
wrapper temporário:
```
[gd_scene format=3]
[ext_resource type="Script" path="res://scenes/<nome>.gd" id="1"]
[node name="Root" type="Node"]   # ou Node2D, conforme o "extends" do script
script = ExtResource("1")
```
`test_pool.gd` exige um nó `ProjectilePool` irmão chamado `../ProjectilePool`
— é um teste manual de editor (F6), não roda isolado.

## Convenções já em vigor (não repetir trabalho)

- Toda comunicação cross-domain via `SignalBus`, nunca sinais diretos entre
  nós de domínios diferentes.
- Gameplay chama `GameFacade.*`, nunca `GameManager`/`AudioManager`/`SignalBus`
  diretamente.
- Inimigos só nascem via `EnemyFactory.create(type)`.
- `RarityConfig.color_for()`/`label_for()` são `static func` — chamáveis como
  `RarityConfig.color_for(x)` sem instanciar nada.
