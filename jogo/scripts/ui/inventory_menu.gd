## Observer — escuta sinais do player para refletir o inventário em tempo real.
## Pausa o jogo ao abrir e retoma ao fechar.
extends Control

@onready var _grid: GridContainer      = $Panel/VBox/Grid
@onready var _benefit_label: Label     = $Panel/VBox/BenefitRow/BenefitLabel
@onready var _btn_close: Button        = $Panel/VBox/BtnClose

var _player: Node = null


func _ready() -> void:
	hide()
	_btn_close.pressed.connect(_close)
	SignalBus.item_picked_up.connect(func(_d): _refresh())
	SignalBus.run_started.connect(func(): _refresh())


func open() -> void:
	_player = get_tree().get_first_node_in_group("player")
	_refresh()
	show()
	get_tree().paused = true


func _close() -> void:
	get_tree().paused = false
	hide()


func _refresh() -> void:
	if _player == null:
		return
	for child in _grid.get_children():
		child.queue_free()

	var equip: Dictionary = _player.get("equipment") if _player.get("equipment") != null else {}
	for slot_key in equip.keys():
		var item: Resource = equip[slot_key]
		var slot_btn := Button.new()
		var label_text := "[vazio]"
		if item != null:
			var iname: String = item.get("item_name") if item.get("item_name") != null else str(item)
			var rarity: int   = item.get("rarity")   if item.get("rarity")   != null else 0
			label_text = iname
			slot_btn.modulate = RarityConfig.color_for(rarity)
		slot_btn.text = label_text
		slot_btn.pressed.connect(_on_discard.bind(slot_key))
		_grid.add_child(slot_btn)

	var benefit: Resource = _player.get("active_benefit")
	if benefit != null and benefit.get("consumable_name") != null:
		_benefit_label.text = "Benefício: " + benefit.consumable_name
	else:
		_benefit_label.text = "Benefício: nenhum"


func _on_discard(slot_key: int) -> void:
	if _player and _player.has_method("unequip"):
		_player.unequip(slot_key)
	_refresh()
