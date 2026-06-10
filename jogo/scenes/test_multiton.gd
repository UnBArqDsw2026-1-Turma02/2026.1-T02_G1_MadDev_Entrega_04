## Teste do Multiton (DifficultyRegistry).
## Rode esta cena com F6. Resultados aparecem no painel Output.
## Valida criação lazy, unicidade de instância por chave e valores corretos.
extends Node

var _pass: int = 0
var _fail: int = 0


func _ready() -> void:
	await get_tree().process_frame

	print("")
	print("========================================")
	print("   TESTE: DifficultyRegistry (Multiton)")
	print("========================================")

	_test_lazy_creation()
	_test_identity()
	_test_values_easy()
	_test_values_normal()
	_test_values_hard()

	print("----------------------------------------")
	print("  RESULTADO: %d passaram | %d falharam" % [_pass, _fail])
	print("========================================")
	print("")


# ---------------------------------------------------------------------------
# Testes individuais
# ---------------------------------------------------------------------------

func _test_lazy_creation() -> void:
	print("\n[1] Criação lazy — instância criada apenas na primeira chamada")
	var instance = DifficultyRegistry.get_instance(DifficultyRegistry.EASY)
	_assert("get_instance(EASY) retorna objeto não-nulo", instance != null)


func _test_identity() -> void:
	print("\n[2] Unicidade — mesma chave retorna estritamente a mesma instância")
	var a = DifficultyRegistry.get_instance(DifficultyRegistry.HARD)
	var b = DifficultyRegistry.get_instance(DifficultyRegistry.HARD)
	_assert("get_instance(HARD) === get_instance(HARD)", a == b)

	var c = DifficultyRegistry.get_instance(DifficultyRegistry.EASY)
	var d = DifficultyRegistry.get_instance(DifficultyRegistry.NORMAL)
	_assert("EASY e NORMAL são instâncias distintas", c != d)


func _test_values_easy() -> void:
	print("\n[3] Valores — Easy (0.75 HP | 0.85 speed | 1.5 drop)")
	var cfg = DifficultyRegistry.get_instance(DifficultyRegistry.EASY)
	_assert("enemy_hp_modifier == 0.75",   is_equal_approx(cfg.enemy_hp_modifier,   0.75))
	_assert("enemy_speed_modifier == 0.85", is_equal_approx(cfg.enemy_speed_modifier, 0.85))
	_assert("item_drop_rate == 1.5",        is_equal_approx(cfg.item_drop_rate,       1.5))


func _test_values_normal() -> void:
	print("\n[4] Valores — Normal (1.0 HP | 1.0 speed | 1.0 drop)")
	var cfg = DifficultyRegistry.get_instance(DifficultyRegistry.NORMAL)
	_assert("enemy_hp_modifier == 1.0",    is_equal_approx(cfg.enemy_hp_modifier,   1.0))
	_assert("enemy_speed_modifier == 1.0", is_equal_approx(cfg.enemy_speed_modifier, 1.0))
	_assert("item_drop_rate == 1.0",       is_equal_approx(cfg.item_drop_rate,       1.0))


func _test_values_hard() -> void:
	print("\n[5] Valores — Hard (1.5 HP | 1.2 speed | 0.7 drop)")
	var cfg = DifficultyRegistry.get_instance(DifficultyRegistry.HARD)
	_assert("enemy_hp_modifier == 1.5",    is_equal_approx(cfg.enemy_hp_modifier,   1.5))
	_assert("enemy_speed_modifier == 1.2", is_equal_approx(cfg.enemy_speed_modifier, 1.2))
	_assert("item_drop_rate == 0.7",       is_equal_approx(cfg.item_drop_rate,       0.7))


# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------

func _assert(description: String, condition: bool) -> void:
	if condition:
		_pass += 1
		print("  ✅ ", description)
	else:
		_fail += 1
		print("  ❌ FALHOU: ", description)
