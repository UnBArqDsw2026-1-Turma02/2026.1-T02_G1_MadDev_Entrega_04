## Observer Pattern - dados de uma conquista observada pelo AchievementManager.
## Cada conquista guarda sua propria condicao como Callable.
extends Resource
class_name Achievement

@export var id: StringName = &""
@export var name: String = ""
@export var description: String = ""
@export var unlocked: bool = false

var event: StringName = &""
var condition: Callable


func setup(
	new_id: StringName,
	new_name: String,
	new_description: String,
	new_event: StringName,
	new_condition: Callable
) -> Achievement:
	id = new_id
	name = new_name
	description = new_description
	event = new_event
	condition = new_condition
	unlocked = false
	return self


func can_unlock(data: Dictionary) -> bool:
	if unlocked or not condition.is_valid():
		return false
	return condition.call(data)
