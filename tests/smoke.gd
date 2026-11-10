extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	if condition:
		print("CORRECTO: " + description)
	else:
		failures += 1
		push_error(description)

func interact(world: Node) -> void:
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	world._unhandled_input(event)

func run() -> void:
	var world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	await physics_frame
	await physics_frame
	check(world.student.get_node("Camara").enabled, "Cámara activa")
	check(not world.can_interact(), "No se conversa fuera del alcance")
	interact(world)
	check(not world.ui.is_open, "E fuera del alcance no abre diálogo")
	var origin: Vector2 = world.student.position
	Input.action_press("move_right")
	for i in 12:
		await physics_frame
	Input.action_release("move_right")
	check(world.student.position.x > origin.x + 10, "El estudiante camina con la entrada de movimiento")
	world.student.position = Vector2(650, 370)
	Input.action_press("move_up")
	Input.action_press("move_right")
	await physics_frame
	await physics_frame
	check(absf(world.student.velocity.length() - 220.0) < 0.1, "La diagonal conserva la velocidad")
	Input.action_release("move_up")
	Input.action_release("move_right")
	world.student.position = Vector2(850, 370)
	Input.action_press("move_up")
	for i in 30:
		await physics_frame
	Input.action_release("move_up")
	check(world.student.position.y >= 349, "El edificio bloquea al estudiante")
	world.student.position = Vector2(1780, 600)
	Input.action_press("move_right")
	for i in 20:
		await physics_frame
	Input.action_release("move_right")
	check(world.student.position.x <= 1791, "El límite del mapa bloquea al estudiante")
	world.student.position = world.guide.position + Vector2(-55, 0)
	interact(world)
	check(world.ui.is_open and not world.student.controls_enabled, "E cerca del NPC abre diálogo y bloquea movimiento")
	check(world.ui.message.text.begins_with("¡Bienvenido"), "Se muestra el diálogo en español")
	origin = world.student.position
	Input.action_press("move_down")
	for i in 10:
		await physics_frame
	Input.action_release("move_down")
	check(world.student.position.distance_to(origin) < 0.1, "El personaje permanece quieto durante la conversación")
	interact(world)
	check(world.ui.page == 1, "E avanza el diálogo")
	interact(world)
	interact(world)
	check(not world.ui.is_open and world.student.controls_enabled, "Terminar el diálogo restaura movimiento")
	interact(world)
	var escape := InputEventAction.new()
	escape.action = "close_dialogue"
	escape.pressed = true
	world._unhandled_input(escape)
	check(not world.ui.is_open and world.student.controls_enabled, "Esc cierra la conversación")
	world.queue_free()
	await process_frame
	print("Prueba terminada. Fallos: %d" % failures)
	quit(1 if failures else 0)
