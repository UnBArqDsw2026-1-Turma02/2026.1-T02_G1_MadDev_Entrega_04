# Contexto de Implementação — MadDev (jogo de Arquitetura)

Atualizado em 2026-06-19. Ver `tasks.md` para o checklist detalhado por issue
(Backlog/Roadmap em `docs/Documentacao/`).

## Estado geral

Issues 01–18 (lógica de jogo) estão **funcionalmente completas e validadas**
via `godot --headless` 4.6 (sem erros de parse/runtime nas cenas testadas).
Issues 19–22 (sprites, música, SFX) são puramente produção de arte/áudio —
nenhum arquivo existe em `jogo/art/sprites|music|sounds` além dos tiles
básicos; não é trabalho de código.

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
