extends Node2D

const StudentScene = preload("res://characters/student.tscn")
const NpcScene = preload("res://characters/npc.tscn")
const CampusMap = preload("res://maps/campus.gd")
const DialogueUI = preload("res://scripts/dialogue_ui.gd")
const INTERACTION_DISTANCE := 90.0
var student: CharacterBody2D
var guide: StaticBody2D
var ui: CanvasLayer

func _ready() -> void:
	configure_input()
	add_child(CampusMap.new())
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

func configure_input() -> void:
	var bindings := {"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT], "move_up": [KEY_W, KEY_UP], "move_down": [KEY_S, KEY_DOWN], "interact": [KEY_E], "close_dialogue": [KEY_ESCAPE]}
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in bindings[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)

func _process(_delta: float) -> void:
	ui.prompt.text = "[E] Hablar con Marisol" if can_interact() and not ui.is_open else ""

func can_interact() -> bool:
	return student.position.distance_to(guide.position) <= INTERACTION_DISTANCE

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not event.is_echo():
		if ui.is_open:
			ui.advance()
		elif can_interact():
			student.controls_enabled = false
			ui.open_dialogue(guide.DISPLAY_NAME, guide.DIALOGUE)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("close_dialogue") and ui.is_open:
		ui.close_dialogue()
		get_viewport().set_input_as_handled()
