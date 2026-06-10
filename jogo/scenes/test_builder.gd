## Teste visual do Builder Pattern.
## Rode com F6. Use 1/2/3/4 para trocar o tipo de sala em runtime.
extends Node2D

var _current_room: Node2D = null
var _director: RoomDirector

const INSTRUCOES := """[1] Sala de Combate  (difficulty 1)
[2] Sala de Descanso
[3] Sala do Chefão
[4] Sala Vazia
[R] Recriar sala atual"""

var _tipo_atual: String = "combat"
var _label: Label


func _ready() -> void:
	_director = RoomDirector.new()

	_label = Label.new()
	_label.position = Vector2(8, 8)
	_label.text = INSTRUCOES
	add_child(_label)

	_carregar_sala("combat")


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return
	match event.keycode:
		KEY_1: _carregar_sala("combat")
		KEY_2: _carregar_sala("rest")
		KEY_3: _carregar_sala("boss")
		KEY_4: _carregar_sala("empty")
		KEY_R: _carregar_sala(_tipo_atual)


func _carregar_sala(tipo: String) -> void:
	if _current_room != null:
		_current_room.queue_free()
		_current_room = null

	_tipo_atual = tipo
	_director.set_builder(RoomBuilder.new())

	match tipo:
		"combat": _current_room = _director.build_combat_room(1)
		"rest":   _current_room = _director.build_rest_room()
		"boss":   _current_room = _director.build_boss_room()
		"empty":  _current_room = _director.build_empty_room()

	if _current_room:
		add_child(_current_room)
		print("Sala carregada: ", _current_room.name,
			" | filhos: ", _current_room.get_child_count(),
			" | inimigos: ", _current_room.get_children().filter(
				func(c): return c.is_in_group("enemies")).size())
