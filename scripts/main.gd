extends Node2D

const StudentScene = preload("res://characters/student.tscn")
const NpcScene = preload("res://characters/npc.tscn")
const CampusMap = preload("res://maps/campus.gd")
const AmbientStudent = preload("res://scripts/ambient_student.gd")
const DialogueUI = preload("res://scripts/dialogue_ui.gd")
const AcademicManager = preload("res://scripts/academic_manager.gd")
const GameHud = preload("res://scripts/game_hud.gd")
const INTERACTION_DISTANCE := 90.0
const CAMPUS_SIZE := Vector2(3200, 2200)
const CAMPUS_SPAWN := Vector2(1350, 1190)
const GUIDE_POSITION := Vector2(1490, 1190)
const HOUSING_DOOR := Vector2(1064, 1555)
const ROOM_DOOR := Vector2(570, 600)
const SLEEP_POINT := Vector2(470, 320)
var student: CharacterBody2D
var guide: StaticBody2D
var ui: CanvasLayer
var map: Node2D
var current_location := "campus"
var door := HOUSING_DOOR
var touch: Control
var story: Node2D
var academic: Node
var social: Node
var hud: Control
var ambient_students: Array[Node2D] = []

func _ready() -> void:
	configure_input()
	var people := Node2D.new()
	people.y_sort_enabled = true
	add_child(people)
	student = StudentScene.instantiate()
	student.position = CAMPUS_SPAWN
	people.add_child(student)
	guide = NpcScene.instantiate()
	guide.position = GUIDE_POSITION
	people.add_child(guide)
	spawn_ambient_students(people)
	ui = DialogueUI.new()
	add_child(ui)
	ui.closed.connect(sync_modal_state)
	if not Session.profile.is_empty():
		student.apply_profile(Session.profile)
		set_location(Session.location, Session.saved_position)
	else:
		set_location("campus", CAMPUS_SPAWN)
	touch = preload("res://scripts/touch_controls.gd").new()
	ui.add_child(touch)
	story = preload("res://scripts/campus_story.gd").new()
	story.world = self
	add_child(story)
	academic = AcademicManager.new()
	academic.world = self
	academic.classroom_entry = story.CLASSROOM_ENTRY
	add_child(academic)
	social = preload("res://scripts/social_manager.gd").new()
	social.world = self
	add_child(social)
	hud = GameHud.new()
	hud.world = self
	ui.add_child(hud)
	sync_modal_state()

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
	for person in ambient_students:
		person.visible = value == "campus"
	student.position = point
	var camera: Camera2D = student.get_node("Camara")
	camera.limit_right = int(CAMPUS_SIZE.x) if value == "campus" else 1152
	camera.limit_bottom = int(CAMPUS_SIZE.y) if value == "campus" else 720
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
	var target := door if current_location == "campus" else ROOM_DOOR
	return student.position.distance_to(target) < 75

func near_sleep() -> bool:
	return current_location != "campus" and student.position.distance_to(SLEEP_POINT) < 90

func sleep_until_tomorrow() -> void:
	Session.academics.update_absences(Session.clock.day + 1, Session.clock.DEFAULT_MINUTE)
	Session.clock.sleep_to_next_day()
	save_current()
	student.controls_enabled = false
	var lines: Array[String] = ["Dormiste hasta el siguiente día. Tu horario avanzó; tu ropa decidió no opinar.", Session.clock.label()]
	ui.open_dialogue("Descanso", lines)

func travel() -> void:
	if current_location == "campus":
		set_location(Session.profile.get("housing", "internado"), Vector2(570, 500))
	else:
		set_location("campus", HOUSING_DOOR + Vector2(0, 65))

func spawn_ambient_students(parent: Node2D) -> void:
	var routes := [
		[Vector2(1210, 1180), Vector2(1370, 1180), Vector2(1370, 1320), Vector2(1210, 1320)],
		[Vector2(1680, 650), Vector2(1940, 650), Vector2(1940, 710), Vector2(1680, 710)],
		[Vector2(2140, 1280), Vector2(2470, 1280), Vector2(2470, 1435), Vector2(2140, 1435)],
		[Vector2(1045, 1530), Vector2(1045, 1870), Vector2(1150, 1870), Vector2(1150, 1530)],
		[Vector2(2250, 1490), Vector2(2850, 1490), Vector2(2850, 1540), Vector2(2250, 1540)]
	]
	var palettes := [
		[Color("4f7891"), Color("d9a47d"), Color("3b2c28")],
		[Color("b86554"), Color("81583f"), Color("211c1b")],
		[Color("d4a84e"), Color("efc39f"), Color("7a4d2d")],
		[Color("597a5b"), Color("b87955"), Color("332724")],
		[Color("825f94"), Color("6f4937"), Color("191718")]
	]
	for i in routes.size():
		var person := AmbientStudent.new()
		person.configure(routes[i], palettes[i], i)
		person.name = "EstudianteSecundario%d" % (i + 1)
		parent.add_child(person)
		ambient_students.append(person)

func configure_input() -> void:
	var bindings := {"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT], "move_up": [KEY_W, KEY_UP], "move_down": [KEY_S, KEY_DOWN], "interact": [KEY_E], "close_dialogue": [KEY_ESCAPE], "journal": [KEY_J], "academic": [KEY_H], "social": [KEY_R]}
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in bindings[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)

func _process(_delta: float) -> void:
	if has_blocking_modal():
		ui.prompt.text = ""
		return
	ui.prompt.text = "[E] Hablar con Marisol" if can_interact() and not ui.is_open else ""
	if near_door() and not ui.is_open:
		ui.prompt.text = "[E] Volver a tu vivienda" if current_location == "campus" else "[E] Salir al campus"
	if near_sleep() and not ui.is_open:
		ui.prompt.text = "[E / Acción] Dormir hasta mañana"
	if is_instance_valid(story) and not story.nearby().is_empty() and not ui.is_open:
		ui.prompt.text = "[E / Acción] Consultar " + story.nearby()
	if is_instance_valid(academic) and academic.near_classroom() and not ui.is_open:
		ui.prompt.text = academic.prompt_text()

	if is_instance_valid(social) and not social.nearby().is_empty():
		ui.prompt.text = "[E / Acción] Conversar con " + social.Catalog.PEOPLE[social.nearby()]["name"]

func can_interact() -> bool:
	return current_location == "campus" and student.position.distance_to(guide.position) <= INTERACTION_DISTANCE

func has_blocking_modal() -> bool:
	return (is_instance_valid(ui) and ui.is_open) \
		or (is_instance_valid(story) and is_instance_valid(story.journal) and story.journal.visible) \
		or (is_instance_valid(academic) and is_instance_valid(academic.ui) and academic.ui.visible) \
		or (is_instance_valid(hud) and is_instance_valid(hud.help_panel) and hud.help_panel.visible) \
		or (is_instance_valid(social) and is_instance_valid(social.ui) and social.ui.visible)

func sync_modal_state() -> void:
	if not is_instance_valid(student) or not is_instance_valid(touch):
		return
	var blocked := has_blocking_modal()
	student.controls_enabled = not blocked
	if is_instance_valid(hud):
		hud.set_modal_blocked(blocked)
	if blocked:
		touch.release_all()
	touch.visible = not blocked and (OS.has_feature("mobile") or touch.test_mode)

func _unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(social) and social.ui.visible:
		if not event.is_echo() and (event.is_action_pressed("close_dialogue") or event.is_action_pressed("social")):
			social.ui.close_panel()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("social") and not event.is_echo():
		social.toggle_relations()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("journal") and not event.is_echo():
		if not is_instance_valid(academic.ui) or not academic.ui.visible:
			story.toggle_journal()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("academic") and not event.is_echo():
		if not story.journal.visible and not hud.help_panel.visible and not ui.is_open:
			academic.ui.toggle_overview()
		get_viewport().set_input_as_handled()
		return
	if is_instance_valid(academic.ui) and academic.ui.visible:
		if event.is_action_pressed("close_dialogue"):
			academic.ui.close_panel()
		get_viewport().set_input_as_handled()
		return
	if is_instance_valid(hud.help_panel) and hud.help_panel.visible:
		if event.is_action_pressed("close_dialogue"):
			hud.toggle_help()
		get_viewport().set_input_as_handled()
		return
	if is_instance_valid(story) and story.journal.visible:
		if event.is_action_pressed("close_dialogue"):
			story.toggle_journal()
		return
	if event.is_action_pressed("interact") and not event.is_echo():
		if ui.is_open:
			ui.advance()
		elif near_sleep():
			sleep_until_tomorrow()
		elif near_door():
			travel()
		elif can_interact():
			story.marisol()
			student.controls_enabled = false
			ui.open_dialogue(guide.DISPLAY_NAME, guide.DIALOGUE)
		elif social.interact():
			pass
		elif academic.interact():
			pass
		elif story.interact():
			pass
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("close_dialogue") and ui.is_open:
		ui.close_dialogue()
		get_viewport().set_input_as_handled()
