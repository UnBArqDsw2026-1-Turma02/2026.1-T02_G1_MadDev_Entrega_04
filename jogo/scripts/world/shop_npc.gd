## Observer — detecta proximidade do player e abre diálogo de compra.
## Strategy Pattern — cada NPC tem categoria e item distintos via @export.
class_name ShopNPC
extends StaticBody2D

@export var category: String    = "Armeiro"
@export var item: ItemData      = null
@export var interaction_radius: float = 56.0

var _dialog_open: bool = false


func _ready() -> void:
	set_process(true)


func _process(_delta: float) -> void:
	if _dialog_open:
		return
	var player: Node = get_tree().get_first_node_in_group("player")
	if player and global_position.distance_to(player.global_position) <= interaction_radius:
		if Input.is_action_just_pressed("ui_accept"):
			_open_dialog(player)


func _open_dialog(player: Node) -> void:
	if item == null:
		return
	_dialog_open = true
	get_tree().paused = true

	var dialog := _build_dialog()
	get_tree().current_scene.add_child(dialog)

	var btn_buy: Button   = dialog.find_child("BtnBuy",  true, false)
	var btn_close: Button = dialog.find_child("BtnClose", true, false)

	btn_buy.pressed.connect(func():
		if GameManager.spend_currency(item.price):
			SignalBus.item_picked_up.emit({"name": item.item_name, "type": str(item.item_type)})
		else:
			OS.alert("Moeda insuficiente!", "Loja")
		_close_dialog(dialog)
	)
	btn_close.pressed.connect(func(): _close_dialog(dialog))


func _close_dialog(dialog: Node) -> void:
	dialog.queue_free()
	get_tree().paused = false
	_dialog_open = false


func _build_dialog() -> Control:
	var root := PanelContainer.new()
	root.name = "ShopDialog"
	root.anchors_preset = Control.PRESET_CENTER
	var vbox := VBoxContainer.new()
	root.add_child(vbox)

	var lbl_title := Label.new()
	lbl_title.text = "[%s] %s" % [category, item.item_name if item else ""]
	vbox.add_child(lbl_title)

	var lbl_rarity := Label.new()
	lbl_rarity.text = "Raridade: " + RarityConfig.label_for(item.rarity if item else 0)
	lbl_rarity.modulate = RarityConfig.color_for(item.rarity if item else 0)
	vbox.add_child(lbl_rarity)

	var lbl_price := Label.new()
	lbl_price.text = "Preço: %d moedas  (você tem: %d)" % [item.price if item else 0, GameManager.currency]
	vbox.add_child(lbl_price)

	var hbox := HBoxContainer.new()
	vbox.add_child(hbox)

	var btn_buy := Button.new()
	btn_buy.name = "BtnBuy"
	btn_buy.text = "Comprar"
	hbox.add_child(btn_buy)

	var btn_close := Button.new()
	btn_close.name = "BtnClose"
	btn_close.text = "Fechar"
	hbox.add_child(btn_close)

	return root
