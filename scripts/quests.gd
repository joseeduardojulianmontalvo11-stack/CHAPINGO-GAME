extends RefCounted
## Definiciones independientes del mapa. Añadir misiones requiere nuevos datos y eventos.
signal changed
const DEFINITIONS := {
	"primer_salon": {"name": "¿Dónde está mi salón?", "description": "Marisol te ayuda a orientarte en tu primer día.", "type": "principal", "objectives": [{"id": "encontrar_aulas", "text": "Encuentra la entrada de AULAS, al noreste del campus.", "event": "entrada_aulas"}], "consequence": "Ya sabes llegar a las aulas. Recordar para qué ibas es otro asunto."},
	"primer_desayuno": {"name": "El primer desayuno", "description": "Descubre cómo conseguir tu primer desayuno en el comedor.", "type": "secundaria", "objectives": [{"id": "consultar_menu", "text": "Consulta el menú junto a la entrada del comedor.", "event": "menu_comedor"}], "consequence": "El menú dice: desayuno después de formarse. ¡Has descubierto la primera materia: paciencia aplicada!"}
}
var progress: Dictionary = {}

func reset() -> void:
	progress.clear()
	changed.emit()

func state(id: String) -> String:
	return progress.get(id, {}).get("state", "no iniciada")

func start(id: String) -> bool:
	if not DEFINITIONS.has(id) or state(id) != "no iniciada":
		return false
	progress[id] = {"state": "activa", "done": []}
	changed.emit()
	return true

func objective(id: String) -> String:
	if state(id) == "completada":
		return DEFINITIONS[id]["consequence"]
	for item in DEFINITIONS[id]["objectives"]:
		if not item["id"] in progress.get(id, {}).get("done", []):
			return item["text"]
	return ""

func event(value: String) -> Array[String]:
	var completed: Array[String] = []
	for id in DEFINITIONS:
		if state(id) != "activa":
			continue
		for item in DEFINITIONS[id]["objectives"]:
			if not item["id"] in progress[id]["done"]:
				if item["event"] == value:
					progress[id]["done"].append(item["id"])
					if progress[id]["done"].size() == DEFINITIONS[id]["objectives"].size():
						progress[id]["state"] = "completada"
						completed.append(id)
					changed.emit()
				break
	return completed

func restore(data: Dictionary) -> void:
	progress.clear()
	for id in DEFINITIONS:
		var entry = data.get(id, {})
		if not entry is Dictionary or not entry.get("done", []) is Array:
			continue
		if not entry.get("state") in ["activa", "completada"]:
			continue
		var done: Array = []
		for item in DEFINITIONS[id]["objectives"]:
			if item["id"] in entry.get("done", []):
				done.append(item["id"])
		progress[id] = {"state": "completada" if done.size() == DEFINITIONS[id]["objectives"].size() else "activa", "done": done}
	changed.emit()
