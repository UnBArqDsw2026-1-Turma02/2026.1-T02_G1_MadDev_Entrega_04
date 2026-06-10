class_name DifficultyRegistry
extends RefCounted

const EASY: StringName = &"easy"
const NORMAL: StringName = &"normal"
const HARD: StringName = &"hard"

static var _instances: Dictionary = {}

static func get_instance(key: StringName) -> DifficultyConfig:
	if not _instances.has(key):
		_instances[key] = _create(key)
	return _instances[key]

static func _create(key: StringName) -> DifficultyConfig:
	var cfg := DifficultyConfig.new()
	match key:
		EASY:   cfg.setup(0.75, 0.85, 1.5)
		NORMAL: cfg.setup(1.0,  1.0,  1.0)
		HARD:   cfg.setup(1.5,  1.2,  0.7)
		_:
			assert(false, "DifficultyRegistry: chave desconhecida '%s'" % key)
	return cfg
