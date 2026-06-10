extends Node

@export var pool: ProjectilePool

func _ready():
	print("=== TESTANDO PROJECTILE POOL ====")
	
	# Se não tem pool, tenta encontrar um na cena
	if pool == null:
		pool = get_node("../ProjectilePool")
	
	if pool == null:
		print("❌ Pool não encontrado! Adicione um nó ProjectilePool na cena.")
		return
	
	# Mostra status inicial
	print("Status inicial: ", pool.get_pool_status())
	
	# Dispara 5 projéteis
	for i in range(5):
		var pos = Vector2(100 + i * 50, 200)
		var dir = Vector2(1, 0)
		var projectile = pool.get_projectile(pos, dir)
		if projectile:
			print("✅ Disparo ", i+1, " - Projétil: ", projectile.name)
	
	# Mostra status após disparos
	print("Após disparos: ", pool.get_pool_status())
	
	# Aguarda além do lifetime (3.0s) para garantir que os projéteis retornaram ao pool
	await get_tree().create_timer(4.0).timeout

	# Mostra status final (projéteis devem ter voltado ao pool)
	print("Após 4 segundos: ", pool.get_pool_status())
