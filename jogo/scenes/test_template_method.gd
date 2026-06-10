extends Node

func _ready():
	print("=== TESTANDO TEMPLATE METHOD DOS INIMIGOS ====")
	
	# Aguarda um pouco para o jogo carregar
	await get_tree().create_timer(1.0).timeout
	
	# Teste 1: Criar inimigo melee
	print("\n--- Teste 1: Inimigo Melee ---")
	var melee = EnemyFactory.create(&"melee")
	if melee:
		add_child(melee)
		melee.position = Vector2(200, 150)
		print("✅ Inimigo Melee criado na posição: ", melee.position)
		print("   Velocidade: ", melee.move_speed)
		print("   Dano: ", melee.attack_damage)
		print("   Vida: ", melee.max_health)
	
	# Teste 2: Criar inimigo Ranged
	print("\n--- Teste 2: Inimigo Ranged ---")
	var ranged = EnemyFactory.create(&"ranged")
	if ranged:
		add_child(ranged)
		ranged.position = Vector2(400, 150)
		print("✅ Inimigo Ranged criado na posição: ", ranged.position)
		print("   Velocidade: ", ranged.move_speed)
		print("   Dano: ", ranged.attack_damage)
		print("   Vida: ", ranged.max_health)
	
	# Teste 3: Criar inimigo Basic
	print("\n--- Teste 3: Inimigo Basic ---")
	var basic = EnemyFactory.create(&"basic")
	if basic:
		add_child(basic)
		basic.position = Vector2(300, 250)
		print("✅ Inimigo Basic criado na posição: ", basic.position)
		print("   Velocidade: ", basic.move_speed)
		print("   Dano: ", basic.attack_damage)
		print("   Vida: ", basic.max_health)
	
	print("\n=== TESTE CONCLUÍDO ===")
	print("Observe o comportamento de ataque de cada inimigo!")
	print("- Melee: ataque corpo a corpo")
	print("- Ranged: ataque à distância com projétil")
	print("- Basic: ataque simples")
