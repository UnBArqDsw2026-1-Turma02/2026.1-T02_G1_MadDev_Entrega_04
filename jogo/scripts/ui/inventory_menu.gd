## Menu de inventário (tecla Tab). Mostra os SLOTS DE EQUIPAMENTO em cima e o
## BOLSO em uma matriz 2x3 (6 slots) embaixo. Permite equipar e dropar itens
## não consumíveis. Pausa o jogo ao abrir e retoma ao fechar.
## Observer — escuta inventory_changed / equipment_changed para refletir em tempo real.
extends Control

const ICON: Texture2D = preload("res://icon.svg")

## Nomes dos slots de equipamento (índices = player.EquipSlot).
const _SLOT_NAMES: Array[String] = ["Arma", "Tronco", "Perna", "Pé", "Acessório"]

@onready var _equip_grid: GridContainer = $Panel/Margin/VBox/EquipGrid
@onready var _pocket_grid: GridContainer = $Panel/Margin/VBox/PocketGrid
@onready var _info_label: Label = $Panel/Margin/VBox/InfoLabel
@onready var _btn_equip: Button = $Panel/Margin/VBox/Actions/BtnEquip
@onready var _btn_drop: Button = $Panel/Margin/VBox/Actions/BtnDrop
@onready var _btn_close: Button = $Panel/Margin/VBox/BtnClose

var _player: Node = null
var _open: bool = false
var _selected_pocket: int = -1
var _equip_buttons: Array[Button] = []
var _pocket_buttons: Array[Button] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	_build_equip_slots()
	_build_pocket_slots()
	_btn_close.pressed.connect(close)
	_btn_equip.pressed.connect(_on_equip_pressed)
	_btn_drop.pressed.connect(_on_drop_pressed)
	SignalBus.inventory_changed.connect(func(_p): _refresh())
	SignalBus.equipment_changed.connect(func(_s, _i): _refresh())
	SignalBus.run_ended.connect(func(_v): close())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		_toggle()
		get_viewport().set_input_as_handled()
	elif _open and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _toggle() -> void:
	if _open:
		close()
	else:
		open()


func open() -> void:
	_player = get_tree().get_first_node_in_group("player")
	_selected_pocket = -1
	_refresh()
	show()
	_open = true
	get_tree().paused = true


func close() -> void:
	if not _open:
		hide()
		return
	_open = false
	get_tree().paused = false
	hide()


# ---------------------------------------------------------------------------
# Construção dos slots (uma vez)
# ---------------------------------------------------------------------------
func _build_equip_slots() -> void:
	for i in range(_SLOT_NAMES.size()):
		var btn := _make_slot_button()
		var slot_index := i
		btn.pressed.connect(func() -> void: _on_equip_slot_pressed(slot_index))
		_equip_grid.add_child(btn)
		_equip_buttons.append(btn)


func _build_pocket_slots() -> void:
	for i in range(6):
		var btn := _make_slot_button()
		var pocket_index := i
		btn.pressed.connect(func() -> void: _select_pocket(pocket_index))
		_pocket_grid.add_child(btn)
		_pocket_buttons.append(btn)


func _make_slot_button() -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(96, 44)
	btn.add_theme_font_size_override("font_size", 12)
	btn.clip_text = true
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return btn


# ---------------------------------------------------------------------------
# Refresh
# ---------------------------------------------------------------------------
func _refresh() -> void:
	if _player == null:
		_player = get_tree().get_first_node_in_group("player")
	if _player == null:
		return

	var equipment: Dictionary = _player.get("equipment") if _player.get("equipment") != null else {}
	for i in range(_equip_buttons.size()):
		var item: Resource = equipment.get(i)
		var btn := _equip_buttons[i]
		if item != null:
			btn.text = "%s\n%s" % [_SLOT_NAMES[i], _item_name(item)]
			btn.modulate = RarityConfig.color_for(_item_rarity(item))
			btn.disabled = false
		else:
			btn.text = "%s\n—" % _SLOT_NAMES[i]
			btn.modulate = Color(0.7, 0.7, 0.75)
			btn.disabled = true

	var pocket: Array = _player.get("pocket") if _player.get("pocket") != null else []
	for i in range(_pocket_buttons.size()):
		var item: Resource = pocket[i] if i < pocket.size() else null
		var btn := _pocket_buttons[i]
		if item != null:
			btn.text = "%d\n%s" % [i + 1, _item_name(item)]
			btn.modulate = RarityConfig.color_for(_item_rarity(item))
		else:
			btn.text = "%d\n—" % (i + 1)
			btn.modulate = Color(0.6, 0.6, 0.66)

	# Realça a seleção atual.
	if _selected_pocket >= 0 and (_selected_pocket >= pocket.size() or pocket[_selected_pocket] == null):
		_selected_pocket = -1
	for i in range(_pocket_buttons.size()):
		_pocket_buttons[i].button_pressed = (i == _selected_pocket)

	_update_info()


func _select_pocket(index: int) -> void:
	_selected_pocket = index
	_refresh()


func _update_info() -> void:
	if _selected_pocket < 0:
		_info_label.text = "Selecione um item do bolso para equipar ou soltar."
		_btn_equip.disabled = true
		_btn_drop.disabled = true
		return
	var pocket: Array = _player.get("pocket")
	var item: Resource = pocket[_selected_pocket]
	if item == null:
		_info_label.text = "Selecione um item do bolso."
		_btn_equip.disabled = true
		_btn_drop.disabled = true
		return
	var equippable: bool = item.get("slot") != null
	_info_label.text = "%s — %s%s" % [
		_item_name(item),
		RarityConfig.label_for(_item_rarity(item)),
		_mods_text(item),
	]
	_btn_equip.disabled = not equippable
	_btn_drop.disabled = false


func _mods_text(item: Resource) -> String:
	if item.get("modifiers") == null:
		return ""
	var mods: Dictionary = item.modifiers
	if mods.is_empty():
		return ""
	var parts: Array[String] = []
	for k in mods.keys():
		parts.append("%s %+d" % [str(k), int(mods[k])])
	return "  (" + ", ".join(parts) + ")"


# ---------------------------------------------------------------------------
# Ações
# ---------------------------------------------------------------------------
func _on_equip_slot_pressed(slot_index: int) -> void:
	if _player and _player.has_method("unequip_to_pocket"):
		_player.unequip_to_pocket(slot_index)
	_refresh()


func _on_equip_pressed() -> void:
	if _selected_pocket < 0:
		return
	if _player and _player.has_method("equip_from_pocket"):
		_player.equip_from_pocket(_selected_pocket)
	_refresh()


func _on_drop_pressed() -> void:
	if _selected_pocket < 0:
		return
	if _player and _player.has_method("drop_pocket_item"):
		_player.drop_pocket_item(_selected_pocket)
	_selected_pocket = -1
	_refresh()


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
func _item_name(item: Resource) -> String:
	if item.get("item_name") != null:
		return str(item.item_name)
	return "Item"


func _item_rarity(item: Resource) -> int:
	return int(item.get("rarity")) if item.get("rarity") != null else 0
