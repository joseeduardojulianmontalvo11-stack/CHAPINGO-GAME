extends Node
## Conecta reloj, horario y registros con el mundo sin cargar main.gd.

const Schedule = preload("res://scripts/academic_schedule.gd")
const AcademicUI = preload("res://scripts/academic_ui.gd")
var world: Node2D
var classroom_entry := Rect2()
var schedule = Schedule.new()
var ui: PanelContainer
var last_absence_stamp := -1

func _ready() -> void:
	ui = AcademicUI.new()
	ui.manager = self
	world.ui.add_child(ui)

func _process(delta: float) -> void:
	if not world.has_blocking_modal():
		Session.clock.advance_real(delta)
	var stamp: int = Session.clock.day * 1440 + Session.clock.minute_of_day
	if stamp != last_absence_stamp:
		last_absence_stamp = stamp
		Session.academics.update_absences(Session.clock.day, Session.clock.minute_of_day)

func near_classroom() -> bool:
	return world.current_location == "campus" and classroom_entry.has_point(world.student.position)

func current_session() -> Dictionary:
	return schedule.available(Session.clock.day, Session.clock.minute_of_day)

func next_session() -> Dictionary:
	return schedule.next_session(Session.clock.day, Session.clock.minute_of_day)

func prompt_text() -> String:
	var session := current_session()
	if session.is_empty():
		return "[E / Acción] No hay clase ahora · Consultar próxima"
	var subject: Dictionary = Schedule.SUBJECTS[session["subject_id"]]
	return "Clase disponible: %s, %s · [E / Acción] Asistir" % [subject["name"], schedule.format_minute(session["start"])]

func interact() -> bool:
	if not near_classroom():
		return false
	var session := current_session()
	if session.is_empty():
		var message := "No hay clase en este momento."
		var next := next_session()
		if not next.is_empty():
			var next_subject: Dictionary = Schedule.SUBJECTS[next["subject_id"]]
			message += "\nPróxima clase: %s, %s." % [next_subject["name"], schedule.format_minute(next["start"])]
		ui.open_with_notice(message)
		return true
	var subject_id: String = session["subject_id"]
	var subject: Dictionary = Schedule.SUBJECTS[subject_id]
	var status := Session.academics.attend(subject_id, Session.clock.day, Session.clock.minute_of_day)
	if status == "duplicada":
		ui.open_with_notice("Clase disponible: %s, %s.\nEsta sesión ya tiene tu asistencia." % [subject["name"], schedule.format_minute(session["start"])])
	elif status in ["a_tiempo", "tarde"]:
		world.save_current()
		var message := "Clase disponible: %s, %s.\n%s" % [subject["name"], schedule.format_minute(session["start"]), "Llegaste a tiempo." if status == "a_tiempo" else "Llegaste tarde."]
		if Session.academics.completed_activities.has(subject_id):
			ui.open_with_notice(message + " La actividad de esta materia ya fue evaluada.")
		else:
			ui.show_activity(subject_id, message)
	return true
