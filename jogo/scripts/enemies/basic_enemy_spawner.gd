## Factory Method Pattern — ConcreteCreator para inimigo básico.
class_name BasicEnemySpawner
extends EnemySpawner

func _create_enemy() -> CharacterBody2D:
	return EnemyFactory.create(&"melee")
