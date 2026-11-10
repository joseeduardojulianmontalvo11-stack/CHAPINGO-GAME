extends Node2D

const StudentScene = preload("res://characters/student.tscn")
const NpcScene = preload("res://characters/npc.tscn")
const CampusMap = preload("res://maps/campus.gd")
const DialogueUI = preload("res://scripts/dialogue_ui.gd")
const INTERACTION_DISTANCE := 90.0
var student: CharacterBody2D
var guide: StaticBody2D
var ui: CanvasLayer
var map: Node2D
var current_location := "campus"
var door := Vector2(580, 600)
var touch: Control
var story: Node2D

func _ready() -> void:
	configure_input()
	var people := Node2D.new()
	people.y_sort_enabled = true
	add_child(people)
	student = StudentScene.instantiate()
	student.position = Vector2(820, 600)
	people.add_child(student)
	guide = NpcScene.instantiate()
	guide.position = Vector2(935, 590)
	people.add_child(guide)
	ui = DialogueUI.new()
	add_child(ui)
	ui.closed.connect(func(): student.controls_enabled = true)
	if not Session.profile.is_empty():
		student.apply_profile(Session.profile)
		set_location(Session.location, Session.saved_position)
	else:
		set_location("campus", Vector2(820, 600))
	var save_button := Button.new()
	save_button.text = "Guardar"
	save_button.position = Vector2(24, 75)
	save_button.pressed.connect(func(): save_button.text = "Guardado" if save_current() else "Error al guardar")
	ui.add_child(save_button)
	var menu_button := Button.new()
	menu_button.text = "Guardar y menú"
	menu_button.position = Vector2(140, 75)
	menu_button.pressed.connect(func():
		if save_current():
			get_tree().change_scene_to_file("res://scenes/menu.tscn")
		else:
			menu_button.text = "Error al guardar")
	ui.add_child(menu_button)
	var identity := Label.new()
	identity.position = Vector2(330, 80)
	identity.text = Session.profile.get("name", "Estudiante")
	ui.add_child(identity)
	for control in [save_button, menu_button]:
		control.custom_minimum_size = Vector2(110, 52)
	touch = preload("res://scripts/touch_controls.gd").new()
	ui.add_child(touch)
	var layout := func():
		var safe := preload("res://scripts/safe_layout.gd").rect(get_viewport())
		save_button.position = safe.position + Vector2(0, 54)
		menu_button.position = safe.position + Vector2(125, 54)
		identity.position = safe.position + Vector2(340, 70)
	get_viewport().size_changed.connect(layout)
	layout.call()
	story = preload("res://scripts/campus_story.gd").new()
	story.world = self
	add_child(story)
	var journal_button := Button.new()
	journal_button.text = "Diario (J)"
	journal_button.custom_minimum_size = Vector2(130, 52)
	ui.add_child(journal_button)
	journal_button.pressed.connect(story.toggle_journal)
	var journal_layout := func():
		var safe := preload("res://scripts/safe_layout.gd").rect(get_viewport())
		journal_button.position = Vector2(safe.end.x - 130, safe.position.y + 54)
	get_viewport().size_changed.connect(journal_layout)
	journal_layout.call()

func set_location(value: String, point: Vector2) -> void:
	if is_instance_valid(map):
		remove_child(map)
		map.queue_free()
	current_location = value
	if value == "campus":
		map = CampusMap.new()
	else:
		map = preload("res://maps/room.gd").new()
		map.housing = value
	add_child(map)
	move_child(map, 0)
	guide.visible = value == "campus"
	guide.get_node("Colision").set_deferred("disabled", value != "campus")
	student.position = point
	var camera: Camera2D = student.get_node("Camara")
	camera.limit_right = 1800 if value == "campus" else 1152
	camera.limit_bottom = 1200 if value == "campus" else 720
	camera.reset_smoothing()
	if not Session.profile.is_empty():
		save_current()

func save_current() -> bool:
	if Session.profile.is_empty():
		return false
	Session.location = current_location
	Session.saved_position = student.position
	return Session.save_game()

func near_door() -> bool:
	return student.position.distance_to(door) < 75

func travel() -> void:
	if current_location == "campus":
		set_location(Session.profile.get("housing", "internado"), Vector2(570, 500))
	else:
		set_location("campus", Vector2(580, 655))

func configure_input() -> void:
	var bindings := {"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT], "move_up": [KEY_W, KEY_UP], "move_down": [KEY_S, KEY_DOWN], "interact": [KEY_E], "close_dialogue": [KEY_ESCAPE], "journal": [KEY_J]}
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in bindings[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)

func _process(_delta: float) -> void:
	ui.prompt.text = "[E] Hablar con Marisol" if can_interact() and not ui.is_open else ""
	if near_door() and not ui.is_open:
		ui.prompt.text = "[E] Volver a tu vivienda" if current_location == "campus" else "[E] Salir al campus"
	if is_instance_valid(story) and not story.nearby().is_empty() and not ui.is_open:
		ui.prompt.text = "[E / Acción] Consultar " + story.nearby()

func can_interact() -> bool:
	return current_location == "campus" and student.position.distance_to(guide.position) <= INTERACTION_DISTANCE

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("journal") and not event.is_echo():
		story.toggle_journal()
		get_viewport().set_input_as_handled()
		return
	if is_instance_valid(story) and story.journal.visible:
		if event.is_action_pressed("close_dialogue"):
			story.toggle_journal()
		return
	if event.is_action_pressed("interact") and not event.is_echo():
		if ui.is_open:
			ui.advance()
		elif near_door():
			travel()
		elif can_interact():
			story.marisol()
			student.controls_enabled = false
			ui.open_dialogue(guide.DISPLAY_NAME, guide.DIALOGUE)
		elif story.interact():
			pass
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("close_dialogue") and ui.is_open:
		ui.close_dialogue()
		get_viewport().set_input_as_handled()
