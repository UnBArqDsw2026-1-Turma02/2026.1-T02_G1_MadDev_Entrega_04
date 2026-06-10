@tool
class_name HealthHandler
extends DamageHandler

func handle(damage: int, context: Dictionary) -> int:
	if context.has("target") and context["target"].has_method("apply_final_damage"):
		context["target"].apply_final_damage(damage)
	else:
		print("Dano final calculado, mas nenhum alvo foi especificado: ", damage)
		
	return super.handle(damage, context)
