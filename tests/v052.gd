extends SceneTree
## Eventos GUI reales enviados al viewport, sin invocar callbacks de controles.
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, description: String) -> void:
	print(("CORRECTO: " if ok else "FALLO: ") + description)
	if not ok:
		failures += 1

func click(viewport: Viewport, point: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = point
	viewport.push_input(motion, true)
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		viewport.push_input(event, true)

func hud_button(world: Node, label: String) -> Button:
	for child in world.hud.top_panel.get_child(0).get_children():
		if child is Button and child.text == label:
			return child
	return null

func run() -> void:
	root.gui_embed_subwindows = true
	var session = root.get_node("Session")
	session.save_path = "user://prueba-v052.json"
	session.new_game({"name": "Mouse", "housing": "internado", "appearance": 1, "hair": "382d29", "skin": "c9936c"})
	var world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	await physics_frame
	world.academic.set_process(false)
	session.clock.set_time(15, 545)
	world.set_location("campus", world.story.CLASSROOM_ENTRY.get_center())
	await process_frame
	var key := InputEventKey.new()
	key.physical_keycode = KEY_E
	key.pressed = true
	root.push_input(key, true)
	await process_frame
	check(world.academic.ui.visible and world.academic.ui.answer_controls.size() == 3, "E abre Botanica el lunes dia 15 a las 09:05")
	var choices: Array = world.academic.ui.answer_controls.duplicate()
	for i in choices.size():
		var choice: OptionButton = choices[i]
		click(root, choice.get_global_rect().get_center())
		await process_frame
		var popup := choice.get_popup()
		check(popup.visible, "Mouse abre lista de respuesta %d" % (i + 1))
		if popup.visible:
			await create_timer(0.4).timeout
			click(root, Vector2(popup.position) + Vector2(popup.size.x * 0.5, popup.size.y * 0.375))
			await process_frame
		check(choice.selected == 1, "Mouse selecciona primera opcion de respuesta %d" % (i + 1))
	click(root, world.academic.ui.submit_button.get_global_rect().get_center())
	await process_frame
	check(session.academics.grades.get("botanica", -1) == 10.0, "Mouse entrega actividad y obtiene 10 / 10")
	check(world.academic.ui.title.text == "Historial académico", "Entrega abre historial")
	world.academic.ui.close_panel()
	click(root, world.hud.save_button.get_global_rect().get_center())
	await process_frame
	check(world.hud.save_button.text == "Guardado", "HUD Guardar sigue recibiendo clics")
	session.academics.reset()
	check(session.load_game() and session.academics.grades.get("botanica", -1) == 10.0, "Guardar y cargar conserva calificacion")
	click(root, hud_button(world, "Académico (H)").get_global_rect().get_center())
	await process_frame
	check(world.academic.ui.visible, "HUD Academico abre con mouse")
	world.academic.ui.close_panel()
	click(root, hud_button(world, "Diario (J)").get_global_rect().get_center())
	await process_frame
	check(world.story.journal.visible, "HUD Diario abre con mouse")
	world.story.toggle_journal()
	click(root, hud_button(world, "Ayuda").get_global_rect().get_center())
	await process_frame
	check(world.hud.help_panel.visible, "HUD Ayuda abre con mouse")
	click(root, world.hud.help_close.get_global_rect().get_center())
	await process_frame
	check(not world.hud.help_panel.visible, "Cierre interno de Ayuda recibe mouse")
	current_scene = world
	click(root, hud_button(world, "Guardar y menú").get_global_rect().get_center())
	await process_frame
	await process_frame
	check(is_instance_valid(current_scene) and current_scene.scene_file_path == "res://scenes/menu.tscn", "Guardar y menu recibe mouse y vuelve al menu")
	if is_instance_valid(current_scene):
		current_scene.queue_free()
	await process_frame
	print("V0.5.2: fallos = %d" % failures)
	quit(1 if failures else 0)
