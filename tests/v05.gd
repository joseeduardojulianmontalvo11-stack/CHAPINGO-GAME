extends SceneTree
## Sistema academico V0.5. Todas las comprobaciones son headless.

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, description: String) -> void:
	print(("CORRECTO: " if ok else "FALLO: ") + description)
	if not ok:
		failures += 1

func valid_profile() -> Dictionary:
	return {"name": "Irene", "housing": "internado", "appearance": 1, "hair": "382d29", "skin": "c9936c"}

func run() -> void:
	var session = root.get_node("Session")
	session.save_path = "user://prueba-v05.json"
	session.new_game(valid_profile())
	var AppInfo = load("res://scripts/app_info.gd")
	check(AppInfo.VERSION == "V0.5.3", "Version centralizada en V0.5.3")
	check(session.clock.label().contains("Lunes") and session.clock.time_text() == "08:00", "Reloj inicia el lunes a las 08:00")
	session.clock.advance_minutes(1500)
	check(session.clock.day == 2 and session.clock.time_text() == "09:00", "Reloj avanza hora y dia")
	session.clock.sleep_to_next_day()
	check(session.clock.day == 3 and session.clock.time_text() == "08:00", "Dormir avanza al siguiente dia")
	session.clock.reset()
	var world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	await physics_frame
	await process_frame
	world.academic.set_process(false)
	check(world.ui.header.text == "CHAPINGO · V0.5.3" and not world.ui.header.text.contains("WASD"), "Indicador usa la version central y no ocupa espacio con instrucciones")
	check(not world.hud.help_panel.visible and world.hud.save_button.custom_minimum_size.y >= 48, "Ayuda inicia recogida y botones conservan tamaño tactil")
	var safe := preload("res://scripts/safe_layout.gd").rect(root)
	check(world.hud.position == safe.position and world.hud.top_panel.size.x == safe.size.x, "Barra superior respeta el area segura")
	session.clock.reset()
	world.academic._process(120.0)
	check(session.clock.minute_of_day == 540, "Escala configurable avanza 60 minutos en 120 segundos")
	world.academic.ui.toggle_overview()
	var paused_at: int = session.clock.minute_of_day
	world.academic._process(120.0)
	check(session.clock.minute_of_day == paused_at and not world.student.controls_enabled, "Panel academico pausa reloj y movimiento")
	world.academic.ui.close_panel()
	world.hud.toggle_help()
	paused_at = session.clock.minute_of_day
	world.academic._process(120.0)
	check(session.clock.minute_of_day == paused_at and world.hud.help_panel.visible, "Ayuda accesible pausa el reloj")
	world.hud.toggle_help()
	world.story.toggle_journal()
	paused_at = session.clock.minute_of_day
	world.academic._process(120.0)
	check(session.clock.minute_of_day == paused_at, "Diario de misiones pausa el reloj")
	world.story.toggle_journal()
	var pause_lines: Array[String] = ["Texto de prueba"]
	world.ui.open_dialogue("Reloj", pause_lines)
	paused_at = session.clock.minute_of_day
	world.academic._process(120.0)
	check(session.clock.minute_of_day == paused_at, "Dialogos pausan el reloj mientras se lee")
	world.ui.close_dialogue()
	session.clock.set_time(1, 540)
	session.academics.reset()
	world.set_location("campus", world.story.CLASSROOM_ENTRY.get_center())
	world.student.position = world.story.CLASSROOM_ENTRY.get_center()
	check(world.academic.current_session().get("subject_id", "") == "botanica", "Horario ofrece Botanica el lunes a las 09:00")
	check(preload("res://scripts/academic_schedule.gd").SUBJECTS.size() == 3, "Horario modular contiene las tres materias ficticias")
	check(world.academic.interact(), "Interaccion de AULAS inicia la clase disponible")
	var attendance_key: String = session.academics.schedule.session_key("botanica", 1)
	check(session.academics.attendance.get(attendance_key, {}).get("status", "") == "a_tiempo", "Asistencia puntual se registra aparte")
	check(session.academics.attend("botanica", 1, 540) == "duplicada", "Una sesion no admite asistencia duplicada")
	var grade: float = session.academics.grade_activity("botanica", [0, 0, 0])
	check(is_equal_approx(grade, 10.0) and session.academics.grades["botanica"] == 10.0, "Actividad de tres preguntas produce calificacion de 0 a 10")
	check(session.academics.grade_activity("botanica", [0, 0, 0]) < 0, "Actividad evaluada no se repite para obtener puntos")
	world.academic.ui.close_panel()
	session.academics.reset()
	check(session.academics.attend("botanica", 1, 600) == "tarde", "Llegar despues de la tolerancia se registra como tarde")
	session.academics.reset()
	session.academics.update_absences(2, 480)
	check(session.academics.attendance.get(session.academics.schedule.session_key("botanica", 1), {}).get("status", "") == "falta", "Clase perdida queda registrada como falta")
	session.academics.reset()
	session.clock.set_time(1, 540)
	session.academics.attend("botanica", 1, 540)
	session.academics.grade_activity("botanica", [0, 0, 0])
	world.set_location("internado", world.SLEEP_POINT)
	var day_before_sleep: int = session.clock.day
	world.sleep_until_tomorrow()
	check(session.clock.day == day_before_sleep + 1 and session.clock.time_text() == "08:00", "Dormir desde la vivienda inicia una jornada nueva")
	world.ui.close_dialogue()
	check(world.save_current(), "Guardado incluye el estado academico")
	session.clock.reset()
	session.academics.reset()
	check(session.load_game() and session.clock.day == 2 and session.academics.grades.get("botanica", -1) == 10.0, "Carga recupera reloj, asistencia, actividad y calificacion")
	check(world.ambient_students.size() == 5 and world.touch != null, "Campus V0.4 y controles tactiles siguen presentes")
	world.queue_free()
	await process_frame
	var old_save := {"version": 1, "profile": valid_profile(), "location": "campus", "position": [1500, 300], "quests": {}}
	var old_file := FileAccess.open(session.save_path, FileAccess.WRITE)
	old_file.store_string(JSON.stringify(old_save))
	old_file.close()
	session.clock.set_time(9, 999)
	session.academics.grade_activity("matematicas", [1, 1, 1])
	check(session.load_game() and session.profile["name"] == "Irene", "Guardado V0.2–V0.4 sin campos academicos conserva el perfil")
	check(session.clock.day == 1 and session.academics.grades.is_empty(), "Campos academicos ausentes reciben valores iniciales")
	check(session.saved_position == session.CAMPUS_SAFE_SPAWN, "Posicion antigua dentro de un obstaculo se reubica de forma segura")
	print("V0.5: fallos = %d" % failures)
	quit(1 if failures else 0)
