## Mediator Pattern — ponto central de comunicação entre sistemas desacoplados.
## Nenhum nó deve conectar sinais diretamente em outro nó de domínio diferente;
## use SignalBus.algum_sinal.emit() / SignalBus.algum_sinal.connect() no lugar.
extends Node

# ---------------------------------------------------------------------------
# Jogador
# ---------------------------------------------------------------------------
signal player_health_changed(new_health: int, max_health: int)
signal player_died()
signal player_leveled_up(new_level: int)
signal level_up_ready(new_level: int)
## Game feel — emitido a cada hit recebido (HUD/feedback de dano).
signal player_damaged()
## Cargas de dash (corações de dash): atual e máximo.
signal dash_changed(current: int, maximum: int)

# ---------------------------------------------------------------------------
# Inimigos
# ---------------------------------------------------------------------------
signal enemy_spawned(enemy: Node)
signal enemy_died(enemy: Node)
signal all_enemies_cleared()

# ---------------------------------------------------------------------------
# Sala / Mundo
# ---------------------------------------------------------------------------
signal room_entered(room_id: int)
signal room_cleared()
signal door_lock_changed(door_id: String, locked: bool)
signal door_entered(door_id: String)

# ---------------------------------------------------------------------------
# Itens / Inventário
# ---------------------------------------------------------------------------
signal item_picked_up(item_data: Dictionary)
signal consumable_used(consumable_type: String)
signal key_used()
signal bomb_used(origin: Vector2)
signal equipment_changed(slot: int, item: Resource)
signal benefit_changed(benefit: Resource)
## Bolso do inventário mudou — carrega a lista de 6 slots (item ou null).
signal inventory_changed(pocket: Array)
## Contadores de recurso da run (consumíveis "carregar e usar depois").
signal bombs_changed(amount: int)
signal keys_changed(amount: int)

# ---------------------------------------------------------------------------
# Jogo / Meta
# ---------------------------------------------------------------------------
signal run_started()
signal run_ended(victory: bool)
signal game_paused(is_paused: bool)
signal score_changed(new_score: int)
signal currency_changed(new_amount: int)
## XP do jogador: progresso atual, limiar do próximo nível e nível corrente.
signal xp_changed(current_xp: int, xp_to_next: int, level: int)
signal achievement_unlocked(achievement: Achievement)
signal profile_selected(profile_name: String)
