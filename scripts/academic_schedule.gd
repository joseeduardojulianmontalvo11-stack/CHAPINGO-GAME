extends RefCounted
## Datos ficticios y modulares. No representan un horario oficial de la UACh.

const EARLY_WINDOW := 30
const LATE_WINDOW := 45
const LATE_AFTER := 20
const SUBJECTS := {
	"botanica": {
		"name": "Botánica", "professor": "Dra. Jacaranda Flores", "location": "AULAS · Preparatoria Agrícola",
		"sessions": [{"weekday": 0, "start": 540, "duration": 120}, {"weekday": 2, "start": 540, "duration": 120}],
		"questions": [
			{"text": "¿Qué estructura realiza principalmente la fotosíntesis?", "options": ["La hoja", "La raíz", "El fruto"], "answer": 0},
			{"text": "¿Qué transporta el xilema?", "options": ["Agua y minerales", "Tareas atrasadas", "Polen solamente"], "answer": 0},
			{"text": "Una semilla necesita para germinar…", "options": ["Agua y condiciones adecuadas", "Una credencial", "Café soluble"], "answer": 0}
		]
	},
	"matematicas": {
		"name": "Matemáticas", "professor": "Ing. Víctor Vector", "location": "AULAS · Preparatoria Agrícola",
		"sessions": [{"weekday": 1, "start": 660, "duration": 120}, {"weekday": 3, "start": 660, "duration": 120}],
		"questions": [
			{"text": "¿Cuánto es 3 × 4?", "options": ["7", "12", "34"], "answer": 1},
			{"text": "La mitad de 10 hectáreas es…", "options": ["2", "5", "20"], "answer": 1},
			{"text": "Un ángulo recto mide…", "options": ["45°", "90°", "180°"], "answer": 1}
		]
	},
	"suelos": {
		"name": "Introducción a los Suelos", "professor": "Mtro. Teodoro Terrón", "location": "AULAS · Preparatoria Agrícola",
		"sessions": [{"weekday": 0, "start": 840, "duration": 120}, {"weekday": 4, "start": 840, "duration": 120}],
		"questions": [
			{"text": "El horizonte superficial suele llamarse…", "options": ["Horizonte A", "Horizonte Z", "Horizonte Wi-Fi"], "answer": 0},
			{"text": "La textura del suelo depende de…", "options": ["Arena, limo y arcilla", "Color del tractor", "Altura del aula"], "answer": 0},
			{"text": "La materia orgánica puede mejorar…", "options": ["La estructura del suelo", "La señal del teléfono", "El timbre escolar"], "answer": 0}
		]
	}
}

func sessions_for_weekday(index: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id in SUBJECTS:
		for session in SUBJECTS[id]["sessions"]:
			if session["weekday"] == index:
				var entry: Dictionary = session.duplicate(true)
				entry["subject_id"] = id
				result.append(entry)
	result.sort_custom(func(a, b): return a["start"] < b["start"])
	return result

func available(day: int, minute: int) -> Dictionary:
	var weekday := posmod(day - 1, 7)
	for session in sessions_for_weekday(weekday):
		var finish: int = session["start"] + session["duration"]
		if minute >= session["start"] - EARLY_WINDOW and minute <= finish + LATE_WINDOW:
			return session
	return {}

func next_session(day: int, minute: int) -> Dictionary:
	for offset in range(0, 8):
		var candidate_day := day + offset
		for session in sessions_for_weekday(posmod(candidate_day - 1, 7)):
			if offset > 0 or session["start"] >= minute:
				var result: Dictionary = session.duplicate(true)
				result["day"] = candidate_day
				return result
	return {}

func session_key(subject_id: String, day: int) -> String:
	return "%d:%s" % [day, subject_id]

func format_minute(value: int) -> String:
	return "%02d:%02d" % [value / 60, value % 60]
