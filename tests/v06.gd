extends SceneTree
## Estado social y eventos GUI reales sinteticos; no prueba hardware fisico.
const Catalog = preload("res://scripts/social_catalog.gd")
const State = preload("res://scripts/social_state.gd")
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

func key(code: Key) -> void:
	for down in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = code if code not in [KEY_ENTER, KEY_TAB, KEY_SPACE] else 0
		event.keycode = code
		event.pressed = down
		root.push_input(event, true)

func click(point: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = point
	root.push_input(motion, true)
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		root.push_input(event, true)

func tap(point: Vector2) -> void:
	for down in [true, false]:
		var event := InputEventScreenTouch.new()
		event.position = point
		event.pressed = down
		Input.parse_input_event(event)
		await process_frame

func text_in(body: Control) -> String:
	var value := ""
	for child in body.get_children():
		if child is Label:
			value += child.text + "\n"
	return value

func choose(ui: Control, topic_index: int, option_index: int) -> void:
	ui.show_topics()
	await settle()
	var topic_button: Button = ui.option_buttons[topic_index]
	ui.scroll.ensure_control_visible(topic_button)
	await settle()
	click(topic_button.get_global_rect().get_center())
	await settle()
	check(ui.option_buttons.size() == 3, "Tema presenta tres respuestas")
	var answer: Button = ui.option_buttons[option_index]
	ui.scroll.ensure_control_visible(answer)
	await settle()
	click(answer.get_global_rect().get_center())
	await settle()

func run() -> void:
	var state = State.new()
	check(state.level("ines") == "Conocido" and state.affinity("ines") == 0, "Afinidad inicial y nivel Conocido")
	state.decide("ines", "llegada", 2)
	check(state.affinity("ines") == 0, "Afinidad no baja de cero")
	state.restore({"ines": {"affinity": 35, "decisions": {}}})
	state.decide("ines", "apoyo", 2)
	check(state.affinity("ines") == 20 and state.level("ines") == "Conocido", "Una respuesta hiriente reduce afinidad y nivel")
	state.restore({"ines": {"affinity": 95, "decisions": {}}})
	state.decide("ines", "llegada", 0)
	check(state.affinity("ines") == 100, "Afinidad no supera cien")
	for value in [0, 29, 30, 59, 60, 100]:
		state.restore({"ines": {"affinity": value}})
		check(state.level("ines") == ("Amigo" if value >= 60 else "Compañero" if value >= 30 else "Conocido"), "Umbral de amistad %d" % value)
	state.restore({"ines": {"affinity": -15, "decisions": {"llegada": 99, "desconocido": 0}}, "beto": {"affinity": 500}, "luz": "incorrecto", "fantasma": {"affinity": 50}})
	check(state.affinity("ines") == 0 and state.affinity("beto") == 100 and not state.relationships.has("luz") and not state.relationships.has("fantasma"), "Carga valida ids, tipos y limites")
	check(state.decide("fantasma", "llegada", 0).is_empty() and state.decide("ines", "no_existe", 0).is_empty() and state.decide("ines", "llegada", -1).is_empty(), "Decisiones invalidas no alteran estado")
	state.restore({"beto": {"affinity": 45}})
	state.decide("beto", "comedor", 2)
	state.decide("beto", "comedor", 0)
	check(state.shared_meal("beto") and state.affinity("beto") == 35, "Una invitacion previa desafortunada no bloquea sobremesa ni vuelve a premiarla")
	for id in Catalog.PEOPLE:
		for topic in Catalog.PEOPLE[id]["topics"]:
			var responses := []
			for option in 3:
				state.reset()
				responses.append(state.decide(id, topic, option)["text"])
			check(responses[0] != responses[1] and responses[1] != responses[2], "Ramas distintas: %s / %s" % [id, topic])

	var session = root.get_node("Session")
	session.save_path = "user://prueba-v06.json"
	session.new_game({"name": "Social", "housing": "internado", "appearance": 1, "hair": "382d29", "skin": "c9936c"})
	var world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	await physics_frame
	var manager = world.social
	var ui = manager.ui
	check(manager.students.size() == 3 and world.ambient_students.size() == 5, "Tres compañeros y cinco estudiantes ambientales conservados")
	var campus = session.CampusMap.new()
	var colors := []
	for person in manager.students.values():
		check(campus.is_walkable(person.position), "Compañero situado en punto transitable")
		colors.append(person.shirt)
	campus.free()
	check(colors[0] != colors[1] and colors[1] != colors[2], "Apariencias diferenciadas")
	# Abrir relaciones no cuenta como conocer a alguien.
	key(KEY_R)
	await settle()
	check(ui.visible and text_in(ui.body).contains("Por conocer") and session.social.relationships.is_empty(), "R abre panel con ubicaciones, intereses y personas por conocer")
	key(KEY_ESCAPE)
	await settle()
	check(not ui.visible and world.student.controls_enabled, "Esc cierra relaciones y restaura movimiento")
	world.set_location("campus", Catalog.PEOPLE["ines"]["position"] + Vector2(-50, 0))
	await settle()
	check(world.ui.prompt.text.contains("Inés"), "Aviso de interaccion identifica compañera")
	key(KEY_E)
	await settle()
	check(ui.visible and manager.current_id == "ines" and session.social.relationships.size() == 1, "E inicia conversacion con Ines")
	check(ui.option_buttons[0].has_focus(), "Primer tema recibe foco de teclado al abrir")
	check(not world.student.controls_enabled and not world.touch.visible, "Conversacion bloquea movimiento y libera joystick")
	var clock_before: int = session.clock.minute_of_day
	world.academic._process(20.0)
	check(session.clock.minute_of_day == clock_before, "Conversacion pausa reloj academico")
	key(KEY_J)
	key(KEY_H)
	click(world.hud.top_panel.get_child(0).get_child(5).get_global_rect().get_center())
	await settle()
	check(ui.visible and not world.story.journal.visible and not world.academic.ui.visible, "Social impide superponer diario y academia")
	key(KEY_ENTER)
	await settle()
	check(ui.option_buttons.size() == 3 and ui.option_buttons[0].has_focus(), "Enter abre tema y enfoca primera respuesta")
	key(KEY_ENTER)
	await settle()
	check(session.social.affinity("ines") == 20 and text_in(ui.body).contains("Se agradece"), "Respuesta elegida produce reaccion y afinidad")
	for i in 4:
		await choose(ui, 0, 0)
	check(session.social.affinity("ines") == 20 and text_in(ui.body).contains("no vuelve a cambiar"), "Repetir tema no permite acumular afinidad")
	check(session.quests.state("conocer_companeros") == "activa", "Repetir conversaciones con una persona no cuenta como conocer dos")
	await choose(ui, 1, 0)
	check(session.social.affinity("ines") == 45 and session.social.level("ines") == "Compañero", "Segundo tema alcanza Compañero")
	ui.show_topics()
	check(text_in(ui.body).contains("Compañero de expedición"), "Saludo refleja nivel Compañero")
	await choose(ui, 2, 0)
	check(session.social.affinity("ines") == 70 and session.social.level("ines") == "Amigo", "Apoyo desarrolla amistad")
	ui.show_topics()
	check(text_in(ui.body).contains("Te guardé una foto") and ui.heading.text.contains("Amigo"), "Dialogo e informacion reflejan Amigo")
	key(KEY_ESCAPE)
	await settle()
	world.set_location("campus", Catalog.PEOPLE["beto"]["position"] + Vector2(-40, 0))
	await settle()
	# Accion tactil existente entra a la misma conversacion.
	world.touch.test_mode = true
	world.sync_modal_state()
	world.touch.pointer(7, world.touch.interact_center, true)
	await settle()
	check(ui.visible and manager.current_id == "beto" and not world.touch.visible, "Accion tactil abre conversacion con Beto")
	check(session.quests.state("conocer_companeros") == "completada" and session.quests.state("sobremesa") == "activa", "Conocer dos compañeros completa primera mision opcional")
	ui.show_topics()
	check(ui.option_buttons[3].disabled, "Sobremesa requiere confianza")
	await choose(ui, 0, 0)
	await choose(ui, 1, 0)
	check(manager.can_share_meal(), "Confianza junto al comedor habilita invitacion")
	await choose(ui, 3, 1)
	check(not session.social.shared_meal("beto") and session.quests.state("sobremesa") == "activa", "Posponer invitacion conserva libertad y mision pendiente")
	await choose(ui, 3, 0)
	check(session.social.shared_meal("beto") and session.quests.state("sobremesa") == "completada", "Compartir mesa completa segunda mision")
	var affinity_after: int = session.social.affinity("beto")
	await choose(ui, 3, 0)
	check(session.social.affinity("beto") == affinity_after, "Repetir sobremesa no duplica premio")
	if DisplayServer.get_name() == "headless":
		print("INFO: headless no emula toque a mouse del sistema; cierre GUI con mouse.")
		click(ui.close.get_global_rect().get_center())
	else:
		await tap(ui.close.get_global_rect().get_center())
	await settle()
	check(not ui.visible and world.touch.visible, "Boton de cierre GUI accesible devuelve controles tactiles")
	key(KEY_J)
	await settle()
	check(world.story.journal.text.text.contains("Un campus con nombres") and world.story.journal.text.text.contains("Un lugar en la mesa"), "Misiones sociales aparecen en diario existente")
	key(KEY_ESCAPE)
	world.set_location("campus", Catalog.PEOPLE["luz"]["position"] + Vector2(-45, 0))
	await settle()
	key(KEY_E)
	await settle()
	check(manager.current_id == "luz", "E permite conocer a Luz en biblioteca")
	await choose(ui, 0, 2)
	check(text_in(ui.body).contains("Prefiero que respetes") and session.social.affinity("ines") == 70, "Respuesta propia de Luz y afinidades independientes")
	key(KEY_ESCAPE)
	# La academia conserva su flujo de entrega despues de socializar.
	session.clock.set_time(15, 545)
	world.set_location("campus", world.story.CLASSROOM_ENTRY.get_center())
	await settle()
	key(KEY_E)
	await settle()
	check(world.academic.ui.visible and not ui.visible, "Interaccion academica funciona despues de conversaciones")
	for choice in world.academic.ui.answer_controls:
		choice.select(1)
	click(world.academic.ui.submit_button.get_global_rect().get_center())
	await settle()
	check(session.academics.grades.get("botanica", -1) == 10.0, "Entrega academica conserva nota e historial")
	key(KEY_R)
	check(not ui.visible, "Relaciones no tapa actividad o historial academico")
	key(KEY_ESCAPE)
	var snapshot: Dictionary = session.social.snapshot()
	world.save_current()
	world.queue_free()
	await settle()
	session.social.reset()
	session.quests.reset()
	session.academics.reset()
	check(session.load_game() and session.social.snapshot() == snapshot and session.quests.state("sobremesa") == "completada" and session.academics.grades.get("botanica", -1) == 10.0, "Guardar y cargar recupera decisiones, afinidad, misiones y nota")
	state.restore(session.social.snapshot())
	state.decide("ines", "llegada", 0)
	check(state.affinity("ines") == 70, "Antirrepeticion persiste al cargar")
	# Guardados anteriores omiten social: no se reescriben ni pierden otros sistemas.
	var legacy: Dictionary = session.read_save()
	legacy.erase("social")
	var file := FileAccess.open(session.save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy))
	file.close()
	var original := FileAccess.get_file_as_string(session.save_path)
	check(session.load_game() and session.social.relationships.is_empty() and session.academics.grades.get("botanica", -1) == 10.0 and session.profile["name"] == "Social", "Partida V0.5.3 sin social conserva academia y perfil")
	check(FileAccess.get_file_as_string(session.save_path) == original, "Carga antigua no reescribe archivo")
	world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	await physics_frame
	manager = world.social
	ui = manager.ui
	# Panel compacto, sin desplazamiento horizontal y con cierre fijo.
	for dimensions in [Vector2i(1152, 720), Vector2i(960, 540), Vector2i(640, 360), Vector2i(844, 390)]:
		root.size = dimensions
		root.content_scale_size = dimensions
		await settle()
		manager.toggle_relations()
		await settle()
		var safe := preload("res://scripts/safe_layout.gd").rect(root)
		check(safe.encloses(ui.get_global_rect()) and safe.encloses(ui.close.get_global_rect()), "Panel social y cierre en area segura: %s" % dimensions)
		check(ui.body.size.x <= ui.scroll.size.x and ui.body.size.x >= ui.scroll.size.x - 20, "Texto social conserva ancho sin scroll horizontal")
		click(ui.close.get_global_rect().get_center())
		await settle()
		world.set_location("campus", Catalog.PEOPLE["ines"]["position"] + Vector2(-50, 0))
		manager.interact()
		ui.show_choices("intereses")
		await settle()
		ui.option_buttons[2].grab_focus()
		await settle()
		check(ui.scroll.get_global_rect().encloses(ui.option_buttons[2].get_global_rect()) and safe.encloses(ui.back.get_global_rect()) and ui.scroll.get_global_rect().end.y <= ui.back.get_global_rect().position.y, "Ultima opcion, volver y cierre accesibles sin superposicion: %s" % dimensions)
		key(KEY_R)
		await settle()
	check(not ui.visible, "Mouse cierra panel compacto")
	world.set_location("internado", Vector2(560, 450))
	await settle()
	check(manager.students.values().all(func(person): return not person.visible) and manager.nearby().is_empty(), "Compañeros no aparecen en vivienda")
	world.queue_free()
	await settle()
	session.new_game({"name": "Nueva", "housing": "externa", "appearance": 0, "hair": "382d29", "skin": "c9936c"})
	check(session.social.relationships.is_empty(), "Partida nueva inicia sin relaciones heredadas")
	print("V0.6: fallos = %d" % failures)
	quit(1 if failures else 0)
