extends SceneTree
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, description: String) -> void:
	print(("CORRECTO: " if ok else "FALLO: ") + description)
	if not ok:
		failures += 1

func tap(touch: Control, id: int, point: Vector2, pressed := true) -> void:
	var event := InputEventScreenTouch.new()
	event.index = id
	event.position = point
	event.pressed = pressed
	touch._input(event)

func run() -> void:
	var session = root.get_node("Session")
	session.save_path = "user://prueba-mobile.json"
	session.new_game({"name": "Prueba", "appearance": 1, "hair": "382d29", "skin": "c9936c", "housing": "internado"})
	var world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	await physics_frame
	var touch = world.touch
	check(not touch.visible, "Controles ocultos en computadora")
	var toggle := InputEventKey.new()
	toggle.physical_keycode = KEY_F8
	toggle.pressed = true
	touch._input(toggle)
	check(touch.visible, "F8 activa simulación")
	var mouse := InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.position = touch.stick_center + Vector2(65, 0)
	mouse.pressed = true
	touch._input(mouse)
	var origin: Vector2 = world.student.position
	for i in 12:
		await physics_frame
	check(world.student.position.x > origin.x + 10, "Joystick por mouse mueve al estudiante")
	mouse.pressed = false
	touch._input(mouse)
	check(not Input.is_action_pressed("move_right"), "Soltar mouse libera movimiento")
	world.set_location("campus", Vector2(880, 590))
	await process_frame
	await process_frame
	tap(touch, 0, touch.stick_center)
	tap(touch, 1, touch.interact_center)
	await process_frame
	check(world.ui.is_open and touch.stick_id == 0, "Segundo dedo conversa sin quitar el joystick")
	tap(touch, 1, touch.interact_center, false)
	tap(touch, 2, touch.interact_center)
	await process_frame
	check(world.ui.page == 1, "Botón Acción avanza diálogo")
	tap(touch, 3, touch.close_center)
	await process_frame
	check(not world.ui.is_open, "Botón Cerrar cierra diálogo")
	tap(touch, 0, touch.stick_center, false)
	world.student.position = world.door
	tap(touch, 4, touch.interact_center)
	await process_frame
	check(world.current_location == "internado", "Acción entra en vivienda")
	world.student.position = world.door - Vector2(0, 40)
	tap(touch, 5, touch.interact_center)
	await process_frame
	check(world.current_location == "campus", "Acción sale al campus")
	tap(touch, 6, touch.stick_center + Vector2(60, 0))
	touch._notification(Control.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(not Input.is_action_pressed("move_right"), "Pérdida de foco libera joystick")
	for child in world.ui.get_children():
		if child is Button and child.text == "Guardar":
			child.pressed.emit()
	check(session.load_game() and session.location == "campus", "Botón Guardar persiste partida")
	root.size = Vector2i(2532, 1170)
	await process_frame
	var safe := preload("res://scripts/safe_layout.gd").rect(root)
	check(safe.has_point(touch.stick_center) and safe.has_point(touch.interact_center), "Controles dentro del margen en pantalla alargada")
	world.queue_free()
	await process_frame
	var menu = load("res://scenes/menu.tscn").instantiate()
	root.add_child(menu)
	menu.show_creator()
	await process_frame
	check(menu.name_field.custom_minimum_size.y >= 48 and menu.housing.custom_minimum_size.y >= 48, "Creador con blancos táctiles amplios")
	menu.queue_free()
	await process_frame
	print("Móviles: fallos = %d" % failures)
	quit(1 if failures else 0)
