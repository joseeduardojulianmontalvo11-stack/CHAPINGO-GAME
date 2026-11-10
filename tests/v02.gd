extends SceneTree
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, description: String) -> void:
	print(("CORRECTO: " if ok else "FALLO: ") + description)
	if not ok:
		failures += 1

func run() -> void:
	var session = root.get_node("Session")
	session.save_path = "user://prueba-v02.json"
	var menu = load("res://scenes/menu.tscn").instantiate()
	root.add_child(menu)
	menu.show_creator()
	menu.name_field.text = "Ana"
	menu.look.select(2)
	menu.hair.select(1)
	menu.skin.select(3)
	menu.update_preview()
	check(menu.preview.appearance == 2 and menu.preview.skin == Color("694a37"), "Vista previa refleja las opciones")
	var person: Dictionary = menu.selected_profile()
	menu.queue_free()
	await process_frame
	for home in ["internado", "externa"]:
		person["housing"] = home
		session.new_game(person)
		var world = load("res://scenes/main.tscn").instantiate()
		root.add_child(world)
		await physics_frame
		await physics_frame
		check(world.current_location == home and world.map.housing == home, "Inicio en " + home)
		check(world.student.appearance == 2 and world.student.hair == Color("754b30"), "Apariencia aplicada en " + home)
		world.student.position = Vector2(570, 565)
		check(world.near_door(), "Salida accesible en " + home)
		var event := InputEventAction.new()
		event.action = "interact"
		event.pressed = true
		world._unhandled_input(event)
		check(world.current_location == "campus" and world.guide.visible, "E sale al campus")
		world._unhandled_input(event)
		check(world.current_location == home, "E regresa a la vivienda elegida")
		world.student.position = Vector2(620, 450)
		check(world.save_current(), "Guardado en " + home)
		world.queue_free()
		await process_frame
		session.profile = {}
		check(session.load_game() and session.profile["name"] == "Ana", "Recuperación del nombre")
		var restored = load("res://scenes/main.tscn").instantiate()
		root.add_child(restored)
		check(restored.current_location == home and restored.student.position == Vector2(620, 450), "Continuar recupera escena y posición")
		check(restored.student.skin == Color("694a37") and restored.student.appearance == 2, "Continuar conserva apariencia")
		restored.queue_free()
		await process_frame
	print("V0.2: fallos = %d" % failures)
	quit(1 if failures else 0)
