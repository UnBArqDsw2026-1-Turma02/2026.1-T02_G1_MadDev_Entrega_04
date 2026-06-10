## Flyweight Pattern — mapeamento de tipo de sala para recompensa esperada.
## Usado pelo RoomBuilder para atribuir reward_type às portas (preview de porta).
class_name RoomRewardConfig
extends Resource

## Mapeamento tipo_de_sala → recompensa (StringName).
## Valores usados como reward_type em door.gd e no ícone de preview.
const REWARDS: Dictionary = {
	"combat":   &"item",
	"rest":     &"health",
	"chest":    &"weapon",
	"shop":     &"shop",
	"pre_boss": &"item",
	"boss":     &"victory",
	"empty":    &"none",
}

static func reward_for(room_type: String) -> StringName:
	return REWARDS.get(room_type, &"none")


## Loot alternativo ao explodir um baú (moeda, bomba extra ou chave).
const CHEST_BOMB_LOOT: Array[StringName] = [&"currency", &"bomb", &"key"]

static func random_bomb_loot() -> StringName:
	return CHEST_BOMB_LOOT[randi() % CHEST_BOMB_LOOT.size()]
