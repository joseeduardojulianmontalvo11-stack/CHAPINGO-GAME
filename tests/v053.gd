extends SceneTree
## Regresiones con eventos GUI sinteticos; no sustituye hardware Windows/movil.
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, description: String) -> void:
	print(("CORRECTO: " if ok else "FALLO: ") + description)
	if not ok:
		failures += 1

func settle() -> void:
	for i in 5:
		await process_frame

func mouse(point: Vector2, button := MOUSE_BUTTON_LEFT, down := true) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = point
	root.push_input(motion, true)
	var event := InputEventMouseButton.new()
	event.position = point
	event.button_index = button
	event.pressed = down
	root.push_input(event, true)

func click(point: Vector2) -> void:
	mouse(point)
	mouse(point, MOUSE_BUTTON_LEFT, false)

func key(code: Key) -> void:
	for down in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.pressed = down
		root.push_input(event, true)

func run() -> void:
	root.gui_embed_subwindows = true
	var session = root.get_node("Session")
	session.save_path = "user://prueba-v053.json"
	session.new_game({"name": "Scroll", "housing": "internado", "appearance": 1, "hair": "382d29", "skin": "c9936c"})
	var world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	await physics_frame
	world.academic.set_process(false)
	var ui = world.academic.ui
	for dimensions in [Vector2i(1152, 720), Vector2i(960, 540), Vector2i(640, 360), Vector2i(844, 390)]:
		root.size = dimensions
		root.content_scale_size = dimensions
		session.academics.reset()
		ui.show_activity("botanica", "Asistencia registrada")
		await settle()
		var fixed_rect: Rect2 = ui.submit_button.get_global_rect()
		var safe := preload("res://scripts/safe_layout.gd").rect(root)
		check(safe.encloses(ui.get_global_rect()), "%s: panel limitado al area segura" % dimensions)
		check(safe.encloses(fixed_rect) and not ui.scroll.is_ancestor_of(ui.submit_button), "Entrega visible fuera del scroll")
		check(ui.scroll.size.y > 50 and ui.scroll.get_global_rect().end.y <= ui.footer.get_global_rect().position.y, "Preguntas y pie fijo sin superposicion")
		check(ui.body.size.x >= ui.scroll.size.x - 20 and ui.body.size.x <= ui.scroll.size.x, "Contenido conserva ancho sin scroll horizontal")
		click(fixed_rect.get_center())
		await settle()
		check(ui.activity_feedback.text.contains("1, 2, 3") and session.academics.grades.is_empty(), "Entrega incompleta identifica todas las preguntas faltantes")
		ui.answer_controls[0].release_focus()
		ui.scroll.scroll_vertical = 0
		await settle()
		var wheel_point: Vector2 = ui.scroll.get_global_rect().position + Vector2(20, 10)
		for i in 12:
			mouse(wheel_point, MOUSE_BUTTON_WHEEL_DOWN)
			mouse(wheel_point, MOUSE_BUTTON_WHEEL_DOWN, false)
		await settle()
		var bar: VScrollBar = ui.scroll.get_v_scroll_bar()
		if bar.visible:
			check(ui.scroll.scroll_vertical > 0, "Rueda sobre contenido desplaza verticalmente")
			ui.scroll.scroll_vertical = 0
			await settle()
			var bar_rect := bar.get_global_rect()
			mouse(bar_rect.position + Vector2(bar_rect.size.x / 2, 8))
			var drag := InputEventMouseMotion.new()
			drag.position = bar_rect.end - Vector2(bar_rect.size.x / 2, 8)
			drag.relative = Vector2(0, bar_rect.size.y - 16)
			drag.button_mask = MOUSE_BUTTON_MASK_LEFT
			root.push_input(drag, true)
			mouse(drag.position, MOUSE_BUTTON_LEFT, false)
			await settle()
			check(ui.scroll.scroll_vertical > 0, "Barra vertical responde al arrastre con mouse")
			ui.scroll.scroll_vertical = 0
			await settle()
			# PanGesture ejercita el desplazamiento gestual nativo sin hardware tactil.
			var pan := InputEventPanGesture.new()
			pan.position = wheel_point
			pan.delta = Vector2(0, 10)
			root.push_input(pan, true)
			await settle()
			check(ui.scroll.scroll_vertical > 0, "Gesto pan sintetico desplaza preguntas")
		for i in 3:
			var choice: OptionButton = ui.answer_controls[i]
			ui.scroll.ensure_control_visible(choice)
			await settle()
			check(ui.scroll.get_global_rect().encloses(choice.get_global_rect()), "Respuesta %d accesible completa" % (i + 1))
			click(choice.get_global_rect().get_center())
			await process_frame
			check(choice.get_popup().visible, "Mouse abre respuesta %d" % (i + 1))
			# Seleccion con eventos de mouse dentro del popup.
			await create_timer(0.4).timeout
			var popup := choice.get_popup()
			click(Vector2(popup.position) + Vector2(popup.size.x * 0.5, popup.size.y * 0.375))
			await settle()
			check(choice.selected == 1, "Seleccion GUI de respuesta %d" % (i + 1))
		check(ui.submit_button.get_global_rect() == fixed_rect, "Entrega permanece fija al recorrer las tres preguntas")
		if dimensions.x == 960:
			ui.answer_controls[2].grab_focus()
			key(KEY_TAB)
			check(ui.submit_button.has_focus(), "Tab desde ultima respuesta alcanza Entregar")
			key(KEY_ENTER)
		else:
			click(ui.submit_button.get_global_rect().get_center())
		await settle()
		check(session.academics.grades.get("botanica", -1) == 10.0, "Entrega GUI calcula nota")
		check(ui.title.text == "Historial académico" and ui.body.get_child(0).text.contains("Calificación: 10.0"), "Resultado y calificacion en historial")
		ui._submit("botanica")
		check(session.academics.grades.size() == 1, "Segundo intento no duplica entrega")
		session.academics.reset()
		check(session.load_game() and session.academics.grades.get("botanica", -1) == 10.0, "Nota persiste despues de guardar y cargar")
	# El mensaje real de asistencia y la materia mas larga tambien deben caber.
	root.size = Vector2i(640, 360)
	root.content_scale_size = root.size
	for subject_id in ["botanica", "matematicas", "suelos"]:
		var subject: Dictionary = preload("res://scripts/academic_schedule.gd").SUBJECTS[subject_id]
		ui.show_activity(subject_id, "Clase disponible: %s, 09:00.\nLlegaste a tiempo." % subject["name"])
		await settle()
		ui.scroll.ensure_control_visible(ui.answer_controls[2])
		await settle()
		check(ui.scroll.get_global_rect().encloses(ui.answer_controls[2].get_global_rect()), "Mensaje de asistencia permite acceder a ultima respuesta: " + subject_id)
		ui.answer_controls[0].select(1)
		click(ui.submit_button.get_global_rect().get_center())
		await settle()
		check(ui.activity_feedback.text.contains("2, 3") and not ui.activity_feedback.text.contains("1,"), "Validacion enumera solo respuestas pendientes: " + subject_id)
		ui.scroll.ensure_control_visible(ui.answer_controls[2])
		await settle()
		check(ui.scroll.get_global_rect().encloses(ui.answer_controls[2].get_global_rect()) and ui.get_global_rect().encloses(ui.submit_button.get_global_rect()), "Ultima respuesta y entrega accesibles en telefono: " + subject_id)
	world.queue_free()
	await settle()
	print("V0.5.3: fallos = %d" % failures)
	quit(1 if failures else 0)
