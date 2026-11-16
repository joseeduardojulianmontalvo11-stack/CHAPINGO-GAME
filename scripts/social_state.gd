extends RefCounted
## Estado puro y serializable. Cada decision importante cuenta una sola vez.
signal changed
const Catalog = preload("res://scripts/social_catalog.gd")
var relationships: Dictionary = {}

func reset() -> void:
	relationships.clear()
	changed.emit()

func meet(id: String) -> void:
	if Catalog.PEOPLE.has(id) and not relationships.has(id):
		relationships[id] = {"affinity": 0, "decisions": {}, "shared_meal": false}
		changed.emit()

func affinity(id: String) -> int:
	return int(relationships.get(id, {}).get("affinity", 0))

func level(id: String) -> String:
	var value := affinity(id)
	return "Amigo" if value >= 60 else ("Compañero" if value >= 30 else "Conocido")

func topic(id: String, topic_id: String) -> Dictionary:
	if not Catalog.PEOPLE.has(id):
		return {}
	return Catalog.MEAL if topic_id == "comedor" else Catalog.PEOPLE[id]["topics"].get(topic_id, {})

func decide(id: String, topic_id: String, option: int) -> Dictionary:
	var definition := topic(id, topic_id)
	if definition.is_empty() or option < 0 or option >= definition["choices"].size():
		return {}
	meet(id)
	var decisions: Dictionary = relationships[id]["decisions"]
	# Posponer una invitacion no cierra la mision. Una eleccion anterior puede
	# recordarse sin volver a premiarla cuando finalmente comparten la mesa.
	if topic_id == "comedor":
		if option == 1:
			return {"text": definition["choices"][1][2], "delta": 0, "repeated": false}
		if option == 0:
			relationships[id]["shared_meal"] = true
	if decisions.has(topic_id):
		var previous: Array = definition["choices"][option if topic_id == "comedor" else decisions[topic_id]]
		changed.emit()
		return {"text": "Recuerdas su respuesta: " + previous[2] + "\nYa hablaron de esto. La afinidad no vuelve a cambiar.", "delta": 0, "repeated": true}
	var choice: Array = definition["choices"][option]
	var before := affinity(id)
	relationships[id]["affinity"] = clampi(before + int(choice[1]), 0, 100)
	decisions[topic_id] = option
	changed.emit()
	return {"text": choice[2], "delta": affinity(id) - before, "repeated": false}

func shared_meal(id: String) -> bool:
	return relationships.get(id, {}).get("shared_meal", false) == true

func snapshot() -> Dictionary:
	return relationships.duplicate(true)

func restore(data: Dictionary) -> void:
	relationships.clear()
	for id in Catalog.PEOPLE:
		var entry = data.get(id)
		if not entry is Dictionary:
			continue
		var value = entry.get("affinity", 0)
		if not (value is int or value is float) or not is_finite(float(value)):
			value = 0
		var decisions := {}
		var stored = entry.get("decisions", {})
		if stored is Dictionary:
			for topic_id in stored:
				var definition := topic(id, str(topic_id))
				var option = stored[topic_id]
				if not definition.is_empty() and (option is int or option is float) and is_finite(float(option)) and option >= 0 and option < definition["choices"].size() and option == int(option):
					decisions[topic_id] = int(option)
		relationships[id] = {"affinity": int(clampf(float(value), 0, 100)), "decisions": decisions, "shared_meal": entry.get("shared_meal", false) == true}
	changed.emit()
