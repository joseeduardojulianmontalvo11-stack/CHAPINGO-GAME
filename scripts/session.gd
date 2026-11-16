extends Node
## Datos compartidos y persistencia; no guarda referencias a nodos.
const SAVE_PATH := "user://partida.json"
const CAMPUS_SAFE_SPAWN := Vector2(1350, 1190)
const CampusMap = preload("res://maps/campus.gd")
var profile: Dictionary = {}
var location := "campus"
var saved_position := Vector2(820, 600)
var save_path := SAVE_PATH
var quests = preload("res://scripts/quests.gd").new()
var clock = preload("res://scripts/academic_clock.gd").new()
var social = preload("res://scripts/social_state.gd").new()
var academics = preload("res://scripts/academics.gd").new()

func new_game(data: Dictionary) -> void:
	quests.reset()
	clock.reset()
	academics.reset()
	social.reset()
	profile = data.duplicate(true)
	location = profile["housing"]
	saved_position = Vector2(560, 450)

func save_game() -> bool:
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({
		"version": 1,
		"profile": profile,
		"location": location,
		"position": [saved_position.x, saved_position.y],
		"quests": quests.progress,
		"social": social.snapshot(),
		"academic": {"clock": clock.snapshot(), "records": academics.snapshot()}
	}))
	return true

func read_save() -> Dictionary:
	if not FileAccess.file_exists(save_path):
		return {}
	var data = JSON.parse_string(FileAccess.get_file_as_string(save_path))
	if not data is Dictionary or data.get("version") != 1:
		return {}
	var person = data.get("profile")
	var point = data.get("position")
	if not person is Dictionary or not point is Array or point.size() != 2:
		return {}
	if not point[0] is float and not point[0] is int:
		return {}
	if not point[1] is float and not point[1] is int:
		return {}
	if not data.get("location") in ["campus", "internado", "externa"] or not person.get("housing") in ["internado", "externa"]:
		return {}
	if not person.get("name") is String or not (person.get("appearance") is int or person.get("appearance") is float) or not person.get("hair") is String or not person.get("skin") is String:
		return {}
	if person["appearance"] < 0 or person["appearance"] > 2 or not Color.html_is_valid(person["hair"]) or not Color.html_is_valid(person["skin"]):
		return {}
	return data

func load_game() -> bool:
	var data := read_save()
	if data.is_empty():
		return false
	profile = data["profile"]
	location = data["location"]
	saved_position = sanitize_position(location, Vector2(data["position"][0], data["position"][1]))
	quests.restore(data.get("quests", {}) if data.get("quests", {}) is Dictionary else {})
	var academic = data.get("academic", {})
	if academic is Dictionary:
		clock.restore(academic.get("clock", {}) if academic.get("clock", {}) is Dictionary else {})
		academics.restore(academic.get("records", {}) if academic.get("records", {}) is Dictionary else {})
	else:
		clock.reset()
		academics.reset()
	social.restore(data.get("social", {}) if data.get("social", {}) is Dictionary else {})
	return true

func sanitize_position(place: String, point: Vector2) -> Vector2:
	if place != "campus":
		return point
	var campus = CampusMap.new()
	var result: Vector2 = point if campus.is_walkable(point) else CAMPUS_SAFE_SPAWN
	campus.free()
	return result
