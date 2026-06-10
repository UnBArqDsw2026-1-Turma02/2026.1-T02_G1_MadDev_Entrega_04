## Flyweight Pattern — mapeamento único de nível de raridade para cor.
class_name RarityConfig
extends Resource

enum Rarity { COMMON = 0, UNCOMMON = 1, RARE = 2, EPIC = 3 }

## Cores indexadas por Rarity: Comum=branco, Incomum=verde, Raro=azul, Épico=roxo.
const COLORS: Array[Color] = [
	Color.WHITE,
	Color(0.3, 1.0, 0.3),   # verde
	Color(0.3, 0.6, 1.0),   # azul
	Color(0.7, 0.3, 1.0),   # roxo
]

const LABELS: Array[String] = ["Comum", "Incomum", "Raro", "Épico"]

static func color_for(rarity: int) -> Color:
	return COLORS[clampi(rarity, 0, COLORS.size() - 1)]

static func label_for(rarity: int) -> String:
	return LABELS[clampi(rarity, 0, LABELS.size() - 1)]
