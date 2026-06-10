@tool
extends Node
class_name DamageTester

# 1. Defina aqui as variáveis que os Handlers vão procurar via "in target"
@export var defense: int = 20
@export var resistance: float = 0.5 # 0.5 significa 50%

@export_group("Configurações do Teste")
@export var damage_chain: DamageHandler
@export var dano_inicial: int = 100

# 2. Botão falso no Inspector
@export var clicar_para_testar: bool = false:
	set(value):
		if value == true:
			_rodar_teste()

func _rodar_teste() -> void:
	print("\n--- [TESTE AUTOMÁTICO] Iniciando Cadeia ---")
	if not damage_chain:
		print("❌ Erro: Monte a cadeia (Armor -> Resistance -> Health) no Inspector antes de testar!")
		return
		
	# Passamos 'self' (este script) como target. 
	# Os Handlers vão ler as variáveis 'defense' e 'resistance' aqui de cima!
	var context = {"target": self}
	damage_chain.handle(dano_inicial, context)

# 3. Ponto de retorno que o HealthHandler vai chamar
func apply_final_damage(final_damage: int) -> void:
	print("▶️ Atributos do Alvo -> Defesa: ", defense, " | Resistência: ", resistance * 100, "%")
	print("💥 Dano Bruto: ", dano_inicial, " -> Dano Final Recebido: ", final_damage)
	
	if final_damage == 40:
		print("✅ SUCESSO: O sistema buscou os dados dinamicamente e calculou 40!")
	else:
		print("❌ FALHA: O cálculo resultou em ", final_damage, " (Esperado: 40)")
	print("-------------------------------------------\n")
