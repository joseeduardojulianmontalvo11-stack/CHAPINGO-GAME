extends SceneTree
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool, text: String) -> void:
	print(("CORRECTO: " if ok else "FALLO: ") + text)
	if not ok:
		failures += 1
func interact(world: Node) -> void:
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	world._unhandled_input(event)
func run() -> void:
	var session = root.get_node("Session")
	session.save_path = "user://prueba-quests.json"
	session.new_game({"name": "Ana", "housing": "externa", "appearance": 0, "hair": "382d29", "skin": "c9936c"})
	var world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	world.set_location("campus", Vector2(880, 590))
	await process_frame
	interact(world)
	check(session.quests.state("primer_salon") == "activa", "Conversar con Marisol activa misión")
	check(not session.quests.start("primer_salon"), "La misión no se reinicia")
	check(session.quests.objective("primer_salon").contains("AULAS"), "Objetivo actual indica aulas")
	world.ui.close_dialogue()
	world.student.position = world.story.BREAKFAST_SIGN
	interact(world)
	check(session.quests.state("primer_desayuno") == "activa" and session.quests.state("primer_salon") == "activa", "Dos misiones activas simultáneamente")
	world.ui.close_dialogue()
	var key := InputEventAction.new()
	key.action = "journal"
	key.pressed = true
	world._unhandled_input(key)
	check(world.story.journal.visible and not world.student.controls_enabled, "J abre diario")
	world.story.journal.get_child(0).get_child(0).pressed.emit()
	check(not world.story.journal.visible and world.student.controls_enabled, "Botón táctil cierra diario")
	world.student.position = world.story.BREAKFAST_MENU
	interact(world)
	check(session.quests.state("primer_desayuno") == "completada", "Interacción completa desayuno")
	world.ui.close_dialogue()
	world.student.position = Vector2(1430, 380)
	await process_frame
	await process_frame
	check(session.quests.state("primer_salon") == "completada" and world.ui.is_open, "Zona de entrada completa principal y muestra bienvenida")
	check(session.quests.progress["primer_salon"]["done"] == ["encontrar_aulas"], "Identificador de objetivo completado")
	world.save_current()
	world.queue_free()
	await process_frame
	session.quests.reset()
	check(session.load_game() and session.quests.state("primer_salon") == "completada" and session.quests.state("primer_desayuno") == "completada", "Carga conserva ambas misiones completadas")
	session.quests.reset()
	session.quests.start("primer_salon")
	session.save_game()
	session.quests.reset()
	check(session.load_game() and session.quests.state("primer_salon") == "activa", "Carga conserva misión activa")
	var old: Dictionary = session.read_save()
	old.erase("quests")
	var file := FileAccess.open(session.save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(old))
	file.close()
	var original := FileAccess.get_file_as_string(session.save_path)
	check(session.load_game() and session.quests.state("primer_salon") == "no iniciada", "Partida antigua sin misiones carga correctamente")
	check(FileAccess.get_file_as_string(session.save_path) == original, "Leer partida antigua no reescribe archivo")
	print("Misiones: fallos = %d" % failures)
	quit(1 if failures else 0)
