extends SceneTree
## Regresiones de interfaz y flujo academico incorporadas en V0.5.1.

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, description: String) -> void:
	print(("CORRECTO: " if ok else "FALLO: ") + description)
	if not ok:
		failures += 1

func valid_profile() -> Dictionary:
	return {"name": "Irene", "housing": "internado", "appearance": 1, "hair": "382d29", "skin": "c9936c"}

func body_text(body: VBoxContainer) -> String:
	var result := ""
	for child in body.get_children():
		if child is Label:
			result += child.text + "\n"
	return result

func run() -> void:
	var session = root.get_node("Session")
	session.save_path = "user://prueba-v051.json"
	session.new_game(valid_profile())
	var world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	await physics_frame
	await process_frame
	world.academic.set_process(false)

	root.size = Vector2i(960, 540)
	await process_frame
	world.hud.reflow()
	world.hud.toggle_help()
	await process_frame
	var safe := preload("res://scripts/safe_layout.gd").rect(root)
	check(world.hud.help_panel.visible and world.hud.help_title.text == "Ayuda y controles", "Ayuda abre con titulo claro")
	check(world.hud.help_close.visible and world.hud.help_close.custom_minimum_size.y >= 48, "Ayuda ofrece cierre visible y tactil")
	check(world.hud.help_scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "Ayuda desplaza solo en vertical")
	check(world.hud.help_text.custom_minimum_size.x >= safe.size.x - 73.0 and world.hud.help_text.size.x > 600.0, "Texto de Ayuda conserva un ancho legible")
	check(safe.encloses(world.hud.help_panel.get_global_rect()), "Panel Ayuda permanece dentro del area segura en formato horizontal compacto")
	world.hud.toggle_help()
	root.size = Vector2i(1152, 720)
	await process_frame
	world.hud.reflow()

	var Campus = preload("res://maps/campus.gd")
	var sign_rects: Array[Rect2] = []
	for sign in Campus.CAMPUS_SIGNS:
		sign_rects.append(Rect2(sign["p"] - Vector2(95, 30), Vector2(190, 42)))
	var no_sign_overlap := true
	for i in sign_rects.size():
		for j in range(i + 1, sign_rects.size()):
			no_sign_overlap = no_sign_overlap and not sign_rects[i].intersects(sign_rects[j])
	check(no_sign_overlap, "Letreros principales no se superponen entre si")
	var housing_label_zone := Rect2(940, 1470, 250, 48)
	check(not sign_rects[2].intersects(housing_label_zone), "Dormitorios / La Meche queda separado del rotulo de vivienda")

	world.set_location("campus", world.story.CLASSROOM_ENTRY.get_center())
	world.student.position = world.story.CLASSROOM_ENTRY.get_center()
	session.clock.set_time(1, 480)
	check(world.academic.current_session().is_empty(), "Antes de la ventana no hay clase disponible")
	check(world.academic.prompt_text().contains("No hay clase ahora"), "Entrada de AULAS avisa cuando no hay clase")
	check(world.academic.interact(), "Fuera de horario se puede consultar el panel academico")
	var outside_text := body_text(world.academic.ui.body)
	check(outside_text.contains("No hay clase en este momento") and outside_text.contains("Botánica") and outside_text.contains("09:00"), "Fuera de horario muestra materia y hora de la proxima clase")
	world.academic.ui.close_panel()

	session.academics.reset()
	session.clock.set_time(2, 660)
	check(world.academic.prompt_text().contains("Clase disponible: Matemáticas, 11:00"), "En horario la entrada anuncia materia y hora")
	check(world.academic.interact(), "En horario abre la actividad")
	check(world.academic.ui.answer_controls.size() == 3 and world.academic.ui.submit_button.visible, "Actividad presenta tres respuestas y control de entrega")
	check(world.academic.ui.answer_controls.all(func(choice): return choice.custom_minimum_size.y >= 48 and choice.focus_mode == Control.FOCUS_ALL), "Respuestas tienen blancos tactiles y foco de teclado")
	world.academic.ui.submit_button.pressed.emit()
	check(session.academics.grades.is_empty() and world.academic.ui.activity_feedback.text.contains("Falta responder"), "Entrega incompleta explica que faltan respuestas")
	for choice in world.academic.ui.answer_controls:
		choice.select(2)
	world.academic.ui.submit_button.pressed.emit()
	var history_text := body_text(world.academic.ui.body)
	check(is_equal_approx(session.academics.grades.get("matematicas", -1.0), 10.0), "Respuestas seleccionadas generan calificacion")
	check(history_text.contains("Actividad entregada") and history_text.contains("Calificación: 10.0 / 10") and history_text.contains("Matemáticas — 10.0 / 10"), "Entrega confirma nota y la muestra en historial")
	check(world.save_current(), "Calificacion se guarda desde el flujo de actividad")
	session.academics.reset()
	check(session.load_game() and is_equal_approx(session.academics.grades.get("matematicas", -1.0), 10.0), "Calificacion persiste al cargar la partida")

	world.queue_free()
	await process_frame
	print("V0.5.1: fallos = %d" % failures)
	quit(1 if failures else 0)
