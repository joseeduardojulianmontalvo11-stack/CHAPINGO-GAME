extends SceneTree
## Validacion estructural V0.4. Es headless: no sustituye una revision visual.

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, description: String) -> void:
	print(("CORRECTO: " if ok else "FALLO: ") + description)
	if not ok:
		failures += 1

func interact(world: Node) -> void:
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	world._unhandled_input(event)

func run() -> void:
	var session = root.get_node("Session")
	session.save_path = "user://prueba-v04.json"
	session.new_game({"name": "Campus", "housing": "internado", "appearance": 0, "hair": "382d29", "skin": "c9936c"})
	var world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	world.set_location("campus", world.CAMPUS_SPAWN)
	await physics_frame
	await physics_frame
	var campus = world.map
	check(campus.SIZE == Vector2(3200, 2200), "Dimensiones ampliadas del campus")
	check(world.student.get_node("Camara").limit_right == 3200 and world.student.get_node("Camara").limit_bottom == 2200, "Camara usa los limites nuevos")
	var expected := ["rectoria", "biblioteca", "comedor", "auditorio", "preparatoria", "dormitorios", "meche"]
	var found: Array[String] = []
	for data in campus.BUILDINGS:
		found.append(data["id"])
	check(expected.all(func(id): return id in found), "Estan los siete edificios principales")
	check(campus.get_node_or_null("Rectoria") != null and campus.get_node("Rectoria").get_child_count() > 0, "Edificios instancian colisiones desde su huella")
	var all_paths_clear := true
	for point in campus.WALKABLE_CHECKPOINTS:
		all_paths_clear = all_paths_clear and campus.is_walkable(point)
	check(all_paths_clear, "La red de caminos conserva puntos transitables conectados")
	check(campus.is_walkable(world.student.position), "Jugador aparece en una posicion transitable")
	check(world.ambient_students.size() == 5, "Hay cinco estudiantes secundarios")
	var non_blocking := true
	for person in world.ambient_students:
		non_blocking = non_blocking and not person is CollisionObject2D
	check(non_blocking, "Estudiantes secundarios no bloquean caminos")
	var origin: Vector2 = world.ambient_students[0].position
	for i in 12:
		await process_frame
	check(world.ambient_students[0].position.distance_to(origin) > 0.1, "Estudiantes secundarios recorren rutas cortas")
	world.student.position = Vector2(1590, 510)
	Input.action_press("move_up")
	for i in 30:
		await physics_frame
	Input.action_release("move_up")
	check(world.student.position.y >= 479, "Rectoria bloquea al jugador de forma coherente")
	world.student.position = world.guide.position + Vector2(-55, 0)
	interact(world)
	check(session.quests.state("primer_salon") == "activa" and world.ui.is_open, "Marisol y la mision principal siguen operativas")
	world.ui.close_dialogue()
	world.student.position = world.story.CLASSROOM_ENTRY.get_center()
	await process_frame
	await process_frame
	check(session.quests.state("primer_salon") == "completada", "Entrada de aulas completa la mision")
	world.ui.close_dialogue()
	world.student.position = world.story.BREAKFAST_SIGN
	interact(world)
	world.ui.close_dialogue()
	world.student.position = world.story.BREAKFAST_MENU
	interact(world)
	check(session.quests.state("primer_desayuno") == "completada", "Aviso y menu del comedor siguen operativos")
	world.ui.close_dialogue()
	world.student.position = world.door
	interact(world)
	check(world.current_location == "internado" and world.map.housing == "internado", "Vivienda elegida conserva su interior")
	world.student.position = Vector2(570, 565)
	interact(world)
	check(world.current_location == "campus", "La vivienda regresa al campus ampliado")
	world.story.toggle_journal()
	check(world.story.journal.visible and not world.student.controls_enabled, "Diario conserva el bloqueo de movimiento")
	world.story.toggle_journal()
	check(world.save_current(), "Guardado acepta posiciones del campus V0.4")
	var saved_position: Vector2 = world.student.position
	check(session.load_game() and session.location == "campus" and session.saved_position == saved_position, "Carga recupera ubicacion, posicion y progreso")
	world.queue_free()
	await process_frame
	print("V0.4: fallos = %d" % failures)
	quit(1 if failures else 0)
