## Script de teste — valida Decorator e Iterator imprimindo no console.
## Como rodar: abra esta cena no Godot e pressione F6.
extends Node

func _ready() -> void:
	print("\n========== TESTE: DECORATOR ==========")
	_test_decorator()
	print("\n========== TESTE: ITERATOR ==========")
	_test_iterator()
	print("\n========== FIM DOS TESTES ==========")


# ---------------------------------------------------------------------------
# Teste do padrão Decorator
# ---------------------------------------------------------------------------
func _test_decorator() -> void:
	# Item base puro
	var base := ItemBase.new()
	base.item_name = "Lápis"
	base.base_value = 10

	# Empilha RareDecorator sobre o item base
	var rare := RareDecorator.new()
	rare.wrapped = base

	# Empilha BurnDecorator sobre o RareDecorator
	var burn := BurnDecorator.new()
	burn.wrapped = rare
	burn.burn_damage = 5

	# Empilha DoubleDropDecorator no topo
	var doubled := DoubleDropDecorator.new()
	doubled.wrapped = burn

	print("Item base       → ", base.get_effect(), " | valor: ", base.get_value())
	print("+ Rare          → ", rare.get_effect(), " | valor: ", rare.get_value())
	print("+ Burn          → ", burn.get_effect(), " | valor: ", burn.get_value())
	print("+ DoubleDrop    → ", doubled.get_effect(), " | valor: ", doubled.get_value())

	# Validações
	assert(base.get_value() == 10, "Valor base incorreto")
	assert(rare.get_value() == 30, "Rare deveria somar 20 ao base")
	assert(burn.get_value() == 35, "Burn deveria somar 5 ao Rare")
	assert(doubled.get_value() == 70, "DoubleDrop deveria dobrar o Burn")
	print("✅ Todos os asserts passaram.")


# ---------------------------------------------------------------------------
# Teste do padrão Iterator
# ---------------------------------------------------------------------------
func _test_iterator() -> void:
	# --- FilteredItemIterator com ItemBase reais ---
	var sword := ItemBase.new()
	sword.item_name = "Espada"
	sword.base_value = 15
	sword.item_type = &"weapon"

	var potion := ItemBase.new()
	potion.item_name = "Poção"
	potion.base_value = 5
	potion.item_type = &"consumable"

	var bow := ItemBase.new()
	bow.item_name = "Arco"
	bow.base_value = 12
	bow.item_type = &"weapon"

	var helmet := ItemBase.new()
	helmet.item_name = "Elmo"
	helmet.base_value = 8
	helmet.item_type = &"armor"

	var dagger := ItemBase.new()
	dagger.item_name = "Adaga"
	dagger.base_value = 9
	dagger.item_type = &"weapon"

	var inventory := [sword, potion, bow, helmet, dagger]

	print("\n-- Filtrar apenas 'weapon' (ItemBase) --")
	var weapon_count := 0
	for item in FilteredItemIterator.new(inventory, &"weapon"):
		print("  → ", item.item_name)
		weapon_count += 1
	assert(weapon_count == 3, "Deveria encontrar 3 armas")

	# --- SortedEnemyIterator ---
	var enemies := [
		{"name": "Livro",         "position": Vector2(100, 0)},
		{"name": "Caderno",       "position": Vector2(20, 0)},
		{"name": "Prova",         "position": Vector2(50, 0)},
		{"name": "Símbolo Cálc.", "position": Vector2(5, 0)},
	]
	var player_pos := Vector2.ZERO

	print("\n-- Inimigos ordenados por distância do player (0,0) --")
	var prev_distance := -1.0
	for enemy in SortedEnemyIterator.new(enemies, player_pos):
		var d: float = enemy.position.distance_to(player_pos)
		print("  → ", enemy.name, " @ distância ", d)
		assert(d >= prev_distance, "Ordem violada!")
		prev_distance = d

	print("✅ Todos os asserts passaram.")
