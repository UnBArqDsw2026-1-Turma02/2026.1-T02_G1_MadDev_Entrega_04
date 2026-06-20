## Lista numerada 1-6 do bolso, sempre visível na lateral direita da tela.
## Observer — reflete SignalBus.inventory_changed em tempo real. Espelha os mesmos
## 6 slots da matriz 2x3 do menu Tab (mesma fonte de dados: player.pocket).
extends PanelContainer

const ICON: Texture2D = preload("res://icon.svg")
const POCKET_SIZE: int = 6

@onready var _slots: VBoxContainer = $Margin/VBox/Slots

var _rows: Array = []


func _ready() -> void:
	for i in range(POCKET_SIZE):
		var row := _make_row(i + 1)
		_slots.add_child(row["box"])
		_rows.append(row)
	SignalBus.inventory_changed.connect(_on_inventory_changed)
	_clear_all()


func _make_row(number: int) -> Dictionary:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 4)

	var num := Label.new()
	num.text = "%d" % number
	num.custom_minimum_size = Vector2(14, 0)
	num.add_theme_font_size_override("font_size", 12)
	num.modulate = Color(0.7, 0.75, 0.85)
	box.add_child(num)

	var icon := TextureRect.new()
	icon.texture = ICON
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(14, 14)
	box.add_child(icon)

	var item_name := Label.new()
	item_name.add_theme_font_size_override("font_size", 12)
	item_name.clip_text = true
	item_name.custom_minimum_size = Vector2(96, 0)
	box.add_child(item_name)

	return {"box": box, "icon": icon, "name": item_name}


func _clear_all() -> void:
	for row in _rows:
		_set_empty(row)


func _set_empty(row: Dictionary) -> void:
	row["icon"].visible = false
	row["name"].text = "—"
	row["name"].modulate = Color(0.55, 0.55, 0.62)


func _on_inventory_changed(pocket: Array) -> void:
	for i in range(POCKET_SIZE):
		var row: Dictionary = _rows[i]
		var item: Resource = pocket[i] if i < pocket.size() else null
		if item == null:
			_set_empty(row)
			continue
		var rarity: int = int(item.get("rarity")) if item.get("rarity") != null else 0
		row["icon"].visible = true
		row["icon"].modulate = RarityConfig.color_for(rarity)
		row["name"].text = str(item.item_name) if item.get("item_name") != null else "Item"
		row["name"].modulate = Color.WHITE
