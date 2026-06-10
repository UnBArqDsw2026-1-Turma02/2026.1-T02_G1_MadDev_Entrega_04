## Factory Method Pattern — ConcreteCreator para inimigo de longa distância.
class_name RangedEnemySpawner
extends EnemySpawner

func _create_enemy() -> CharacterBody2D:
	return EnemyFactory.create(&"ranged")
