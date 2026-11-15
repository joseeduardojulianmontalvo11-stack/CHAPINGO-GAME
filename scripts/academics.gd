extends RefCounted
## Registro separado de asistencia, actividades y calificaciones.

signal changed
const Schedule = preload("res://scripts/academic_schedule.gd")
var schedule = Schedule.new()
var attendance: Dictionary = {}
var completed_activities: Dictionary = {}
var grades: Dictionary = {}

func reset() -> void:
	attendance.clear()
	completed_activities.clear()
	grades.clear()
	changed.emit()

func attend(subject_id: String, day: int, minute: int) -> String:
	if not Schedule.SUBJECTS.has(subject_id):
		return "invalida"
	var key := schedule.session_key(subject_id, day)
	if attendance.has(key):
		return "duplicada"
	var session := schedule.available(day, minute)
	if session.is_empty() or session["subject_id"] != subject_id:
		return "fuera_de_horario"
	var status := "tarde" if minute > int(session["start"]) + Schedule.LATE_AFTER else "a_tiempo"
	attendance[key] = {"subject_id": subject_id, "day": day, "minute": minute, "status": status}
	changed.emit()
	return status

func grade_activity(subject_id: String, answers: Array) -> float:
	if not Schedule.SUBJECTS.has(subject_id) or completed_activities.has(subject_id):
		return -1.0
	var questions: Array = Schedule.SUBJECTS[subject_id]["questions"]
	if answers.size() != questions.size():
		return -1.0
	var correct := 0
	for i in questions.size():
		if int(answers[i]) == int(questions[i]["answer"]):
			correct += 1
	var grade := snappedf(float(correct) * 10.0 / questions.size(), 0.1)
	completed_activities[subject_id] = true
	grades[subject_id] = grade
	changed.emit()
	return grade

func update_absences(day: int, minute: int) -> void:
	var added := false
	# Acota la comprobacion a la semana reciente para mantener costo constante.
	for candidate_day in range(maxi(1, day - 7), day + 1):
		for session in schedule.sessions_for_weekday(posmod(candidate_day - 1, 7)):
			var session_finished: bool = candidate_day < day or minute > int(session["start"]) + int(session["duration"]) + Schedule.LATE_WINDOW
			var key := schedule.session_key(session["subject_id"], candidate_day)
			if session_finished and not attendance.has(key):
				attendance[key] = {"subject_id": session["subject_id"], "day": candidate_day, "minute": -1, "status": "falta"}
				added = true
	if added:
		changed.emit()

func snapshot() -> Dictionary:
	return {"attendance": attendance.duplicate(true), "activities": completed_activities.duplicate(true), "grades": grades.duplicate(true), "schedule_version": 1}

func restore(data: Dictionary) -> void:
	attendance.clear()
	completed_activities.clear()
	grades.clear()
	var stored_attendance = data.get("attendance", {})
	if stored_attendance is Dictionary:
		for key in stored_attendance:
			var entry = stored_attendance[key]
			if entry is Dictionary and Schedule.SUBJECTS.has(entry.get("subject_id", "")) and entry.get("status", "") in ["a_tiempo", "tarde", "falta"]:
				attendance[str(key)] = entry.duplicate(true)
	var stored_activities = data.get("activities", {})
	var stored_grades = data.get("grades", {})
	if stored_activities is Dictionary and stored_grades is Dictionary:
		for id in Schedule.SUBJECTS:
			var grade = stored_grades.get(id)
			if stored_activities.get(id, false) == true and (grade is int or grade is float) and float(grade) >= 0.0 and float(grade) <= 10.0:
				completed_activities[id] = true
				grades[id] = float(grade)
	changed.emit()
