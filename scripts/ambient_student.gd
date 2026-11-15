extends Node2D
## Estudiante ambiental sin colision: da vida al campus sin bloquear al jugador.

var route: PackedVector2Array = []
var route_index := 0
var speed := 42.0
var wait_time := 0.0
var shirt := Color("638ca0")
var skin := Color("c9936c")
var hair := Color("3b2b27")
var accessory := 0
var facing := Vector2.DOWN

func configure(points: Array, palette: Array, variant: int) -> void:
	route = PackedVector2Array(points)
	position = route[0]
	route_index = 1 if route.size() > 1 else 0
	shirt = palette[0]
	skin = palette[1]
	hair = palette[2]
	accessory = variant
	speed += variant * 7.0

func _process(delta: float) -> void:
	if route.size() < 2:
		return
	if wait_time > 0:
		wait_time -= delta
		return
	var target := route[route_index]
	var offset := target - position
	if offset.length() < 3:
		route_index = (route_index + 1) % route.size()
		wait_time = 0.6 + accessory * 0.18
	else:
		facing = offset.normalized()
		position += facing * minf(speed * delta, offset.length())
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0, Vector2(1, 0.42))
	draw_circle(Vector2(0, 2), 15, Color(0, 0, 0, 0.14))
	draw_set_transform(Vector2.ZERO)
	draw_line(Vector2(-5, -7), Vector2(-5, 1), Color("263c48"), 5)
	draw_line(Vector2(5, -7), Vector2(5, 1), Color("263c48"), 5)
	draw_rect(Rect2(-11, -29, 22, 22), shirt)
	draw_circle(Vector2(0, -37), 10, skin)
	draw_arc(Vector2(0, -39), 9, PI, TAU, 12, hair, 6)
	draw_circle(Vector2(facing.x * 3, -36 + facing.y), 1.5, Color("2e2522"))
	if accessory % 3 == 0:
		draw_rect(Rect2(10, -25, 6, 17), Color("d5a849"))
	elif accessory % 3 == 1:
		draw_line(Vector2(-12, -26), Vector2(12, -26), Color("efe5ce"), 3)
	else:
		draw_arc(Vector2(0, -40), 12, PI, TAU, 12, Color("263c48"), 3)
