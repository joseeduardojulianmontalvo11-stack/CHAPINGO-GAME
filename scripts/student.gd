extends CharacterBody2D
## El origen del personaje está en sus pies; la cámara y colisión lo siguen.
const SPEED := 220.0
var controls_enabled := true
var facing := Vector2.DOWN
var appearance := 0
var hair := Color("382d29")
var skin := Color("e5b58b")

func apply_profile(profile: Dictionary) -> void:
	appearance = int(profile.get("appearance", 0))
	hair = Color(profile.get("hair", "382d29"))
	skin = Color(profile.get("skin", "e5b58b"))
	queue_redraw()

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down") if controls_enabled else Vector2.ZERO
	velocity = direction * SPEED
	if direction != Vector2.ZERO:
		facing = direction
	move_and_slide()
	queue_redraw()

func _draw() -> void:
	draw_ellipse_shadow()
	draw_line(Vector2(-5, -7), Vector2(-5, 1), Color("263c48"), 6)
	draw_line(Vector2(5, -7), Vector2(5, 1), Color("263c48"), 6)
	draw_style_box(_shirt(), Rect2(-12, -29, 24, 23))
	draw_circle(Vector2(0, -37), 10, skin)
	draw_arc(Vector2(0, -39), 9, PI, TAU, 12, hair, 6)
	draw_circle(Vector2(facing.x * 4, -36 + facing.y * 2), 2, Color("382d29"))
	draw_rect(Rect2(-16, -25, 6, 16), Color("d3a44b"))

func draw_ellipse_shadow() -> void:
	draw_set_transform(Vector2.ZERO, 0, Vector2(1, 0.4))
	draw_circle(Vector2.ZERO, 16, Color(0, 0, 0, 0.18))
	draw_set_transform(Vector2.ZERO)

func _shirt() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = [Color("f5eadd"), Color("678b9c"), Color("be765c")][appearance % 3]
	style.set_corner_radius_all(5)
	return style
