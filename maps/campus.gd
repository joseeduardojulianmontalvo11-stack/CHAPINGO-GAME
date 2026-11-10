extends Node2D
## Mapa provisional original. Los rectángulos visibles comparten geometría con su colisión.
const SIZE := Vector2(1800, 1200)
const BUILDINGS := [Rect2(140, 110, 400, 230), Rect2(710, 100, 380, 240), Rect2(1230, 110, 400, 230)]
const GARDENS := [Rect2(180, 710, 330, 220), Rect2(1200, 710, 360, 220)]
const TREES := [Vector2(100, 460), Vector2(360, 450), Vector2(1450, 470), Vector2(1670, 480), Vector2(120, 1010), Vector2(600, 1040), Vector2(1160, 1030), Vector2(1640, 1010)]

func _ready() -> void:
	for rect in BUILDINGS:
		add_obstacle(rect)
	for rect in GARDENS:
		add_obstacle(rect)
	for point in TREES:
		var body := StaticBody2D.new()
		body.position = point
		var collider := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = 20
		collider.shape = shape
		body.add_child(collider)
		add_child(body)
	for border in [Rect2(-30, -30, 1860, 30), Rect2(-30, 1200, 1860, 30), Rect2(-30, 0, 30, 1200), Rect2(1800, 0, 30, 1200)]:
		add_obstacle(border)

func add_obstacle(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = rect.get_center()
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collider.shape = shape
	body.add_child(collider)
	add_child(body)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("77955a"))
	for x in range(30, 1800, 70):
		for y in range(30, 1200, 70):
			draw_line(Vector2(x, y), Vector2(x + 4, y - 7), Color("68874d"), 2)
	draw_rect(Rect2(0, 530, 1800, 140), Color("dbcca8"))
	draw_rect(Rect2(790, 340, 180, 860), Color("dbcca8"))
	draw_rect(Rect2(200, 340, 180, 190), Color("dbcca8"))
	draw_rect(Rect2(1350, 340, 170, 190), Color("dbcca8"))
	for x in range(0, 1800, 80):
		draw_line(Vector2(x, 535), Vector2(x, 665), Color("cbbc99"), 1)
	var names := ["COMEDOR", "BIBLIOTECA", "AULAS"]
	for i in BUILDINGS.size():
		var rect: Rect2 = BUILDINGS[i]
		draw_rect(Rect2(rect.position + Vector2(7, 8), rect.size), Color(0, 0, 0, 0.15))
		draw_rect(rect, Color("d9b881"))
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, 45)), Color("98553d"))
		for x in range(int(rect.position.x + 25), int(rect.end.x - 30), 75):
			draw_rect(Rect2(x, rect.position.y + 75, 40, 55), Color("527b80"))
		draw_rect(Rect2(rect.get_center().x - 22, rect.end.y - 65, 44, 65), Color("654f38"))
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(24, 30), names[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("fff1d3"))
	for rect in GARDENS:
		draw_rect(rect.grow(5), Color("b0a184"))
		draw_rect(rect, Color("456e47"))
		for x in range(int(rect.position.x + 20), int(rect.end.x - 10), 35):
			for y in range(int(rect.position.y + 20), int(rect.end.y - 10), 35):
				draw_circle(Vector2(x, y), 4, Color("eac566") if x % 2 == 0 else Color("e5a48e"))
	for point in TREES:
		draw_circle(point + Vector2(8, 5), 38, Color(0, 0, 0, 0.12))
		draw_rect(Rect2(point - Vector2(8, 35), Vector2(16, 40)), Color("765238"))
		draw_circle(point + Vector2(0, -48), 42, Color("315c3c"))
		draw_circle(point + Vector2(-12, -60), 28, Color("47774a"))
