extends Control
## Cada dedo conserva su acción hasta liberarse. No captura pulsaciones de otros controles.
const Layout = preload("res://scripts/safe_layout.gd")
var test_mode := false
var stick_id := -1
var fingers: Dictionary = {}
var stick_center := Vector2.ZERO
var knob := Vector2.ZERO
var interact_center := Vector2.ZERO
var close_center := Vector2.ZERO
const RADIUS := 75.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	test_mode = "--touch-test" in OS.get_cmdline_user_args()
	visible = OS.has_feature("mobile") or test_mode
	get_viewport().size_changed.connect(reflow)
	reflow()

func reflow() -> void:
	release_all()
	var safe := Layout.rect(get_viewport())
	stick_center = Vector2(safe.position.x + 95, safe.end.y - 95)
	interact_center = Vector2(safe.end.x - 70, safe.end.y - 75)
	close_center = interact_center - Vector2(0, 130)
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F8:
		test_mode = not test_mode
		visible = OS.has_feature("mobile") or test_mode
		release_all()
	if not visible:
		return
	if event is InputEventScreenTouch:
		pointer(event.index, event.position, event.pressed)
	elif event is InputEventScreenDrag:
		drag(event.index, event.position)
	elif test_mode and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		pointer(10000, event.position, event.pressed)
	elif test_mode and event is InputEventMouseMotion:
		drag(10000, event.position)

func pointer(id: int, point: Vector2, pressed: bool) -> void:
	if not pressed:
		if id == stick_id:
			stick_id = -1
			move_stick(Vector2.ZERO)
		fingers.erase(id)
		return
	if point.distance_to(stick_center) <= RADIUS and stick_id == -1:
		stick_id = id
		drag(id, point)
	elif point.distance_to(interact_center) <= 52:
		fingers[id] = "interact"
		activate("interact")
	elif point.distance_to(close_center) <= 52:
		fingers[id] = "close_dialogue"
		activate("close_dialogue")

func drag(id: int, point: Vector2) -> void:
	if id == stick_id:
		move_stick((point - stick_center).limit_length(RADIUS) / RADIUS)

func move_stick(direction: Vector2) -> void:
	knob = direction * RADIUS
	var value := direction if direction.length() > 0.15 else Vector2.ZERO
	for pair in [["move_left", -value.x], ["move_right", value.x], ["move_up", -value.y], ["move_down", value.y]]:
		if pair[1] > 0:
			Input.action_press(pair[0], pair[1])
		else:
			Input.action_release(pair[0])
	queue_redraw()

func activate(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
	var release := InputEventAction.new()
	release.action = action
	Input.parse_input_event.call_deferred(release)

func release_all() -> void:
	if stick_id != -1:
		move_stick(Vector2.ZERO)
	stick_id = -1
	fingers.clear()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_EXIT_TREE:
		release_all()

func _draw() -> void:
	draw_circle(stick_center, RADIUS, Color(0.1, 0.2, 0.15, 0.65))
	draw_circle(stick_center + knob, 30, Color("d8c7a2"))
	for point in [interact_center, close_center]:
		draw_circle(point, 52, Color(0.1, 0.2, 0.15, 0.85))
	draw_string(ThemeDB.fallback_font, interact_center + Vector2(-30, 6), "Acción", HORIZONTAL_ALIGNMENT_LEFT, -1, 19)
	draw_string(ThemeDB.fallback_font, close_center + Vector2(-29, 6), "Cerrar", HORIZONTAL_ALIGNMENT_LEFT, -1, 19)
