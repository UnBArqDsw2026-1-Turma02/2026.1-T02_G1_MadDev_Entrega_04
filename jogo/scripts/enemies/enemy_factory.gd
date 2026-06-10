## Factory Method Pattern — fonte única de criação de inimigos.
## Em vez de espalhar `load(...).instantiate()` pelo código, todos os caminhos
## (RoomBuilder, EnemySpawner, testes) chamam EnemyFactory.create(type).
## Adicionar um novo inimigo = adicionar uma entrada no mapa _SCENES.
class_name EnemyFactory
extends RefCounted

const _SCENES: Dictionary = {
	&"basic":  "res://scenes/enemies/enemy.tscn",
	&"melee":  "res://scenes/enemies/enemy_melee.tscn",
	&"ranged": "res://scenes/enemies/enemy_ranged.tscn",
	&"boss":   "res://scenes/enemies/enemy_boss.tscn",
}


## Cria e retorna um inimigo do tipo pedido (sem adicioná-lo à árvore).
## Tipo desconhecido cai no inimigo básico.
static func create(type: StringName) -> CharacterBody2D:
	var path: String = _SCENES.get(type, _SCENES[&"basic"])
	var scene := load(path) as PackedScene
	if scene == null:
		push_error("EnemyFactory: cena inválida para o tipo '%s'." % type)
		return null
	return scene.instantiate() as CharacterBody2D
