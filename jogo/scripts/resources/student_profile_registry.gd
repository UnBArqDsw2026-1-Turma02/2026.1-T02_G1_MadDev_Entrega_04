## Multiton Pattern — garante uma única instância de StudentProfile por chave (profile_name).
## Registre este script como Autoload "StudentProfileRegistry" no project.godot.
## Os .tres de perfil são carregados uma vez e cacheados; chamadas subsequentes
## retornam a mesma referência, nunca duplicam o Resource em memória.
extends Node

const _PROFILE_PATHS: Dictionary = {
	"Calouro":          "res://resources/profiles/calouro.tres",
	"Veterano":         "res://resources/profiles/veterano.tres",
	"Jubilado":         "res://resources/profiles/jubilado.tres",
	"Cara da Atletica": "res://resources/profiles/atletica.tres",
}

var _cache: Dictionary = {}


func get_profile(profile_name: String) -> StudentProfile:
	if _cache.has(profile_name):
		return _cache[profile_name]

	if not _PROFILE_PATHS.has(profile_name):
		push_error("StudentProfileRegistry: perfil desconhecido '%s'" % profile_name)
		return null

	var profile: StudentProfile = load(_PROFILE_PATHS[profile_name])
	_cache[profile_name] = profile
	return profile


func get_all_profiles() -> Array[StudentProfile]:
	var result: Array[StudentProfile] = []
	for key in _PROFILE_PATHS.keys():
		result.append(get_profile(key))
	return result


## Retorna uma cópia independente do perfil para não poluir o cache com modificações.
func clone_profile(profile_name: String) -> StudentProfile:
	var original := get_profile(profile_name)
	if original == null:
		return null
	return original.duplicate(true)
