extends StaticBody2D
## Edificio reutilizable: su dibujo y su colision parten de la misma huella.

var size := Vector2(300, 180)
var title := "EDIFICIO"
var subtitle := ""
var wall := Color("d8c49b")
var roof := Color("8d4b3e")
var accent := Color("f1dfb5")
var style := "academic"

func configure(data: Dictionary) -> void:
	var rect: Rect2 = data["rect"]
	position = rect.position
	size = rect.size
	title = data.get("title", title)
	subtitle = data.get("subtitle", "")
	wall = data.get("wall", wall)
	roof = data.get("roof", roof)
	accent = data.get("accent", accent)
	style = data.get("style", style)

func _ready() -> void:
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collider.position = size * 0.5
	collider.shape = shape
	add_child(collider)
	queue_redraw()

func _draw() -> void:
	# Sombra, fachada y techo con aleros dan volumen sin depender de texturas.
	draw_rect(Rect2(Vector2(14, 16), size), Color(0, 0, 0, 0.18))
	draw_rect(Rect2(Vector2.ZERO, size), wall)
	draw_rect(Rect2(-Vector2(10, 10), size + Vector2(20, 74)), roof)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-10, 56), Vector2(size.x + 10, 56), Vector2(size.x - 12, 76), Vector2(12, 76)
	]), roof.darkened(0.22))
	draw_rect(Rect2(8, 78, size.x - 16, size.y - 86), wall.lightened(0.05))
	if style == "rectoria":
		_draw_rectory()
	elif style == "library":
		_draw_library()
	elif style == "auditorium":
		_draw_auditorium()
	elif style == "dorms":
		_draw_dorms()
	elif style == "meche":
		_draw_meche()
	else:
		_draw_academic()
	_draw_sign()

func _draw_sign() -> void:
	draw_rect(Rect2(18, 14, size.x - 36, 36), Color(0.12, 0.16, 0.13, 0.78))
	draw_string(ThemeDB.fallback_font, Vector2(28, 40), title, HORIZONTAL_ALIGNMENT_LEFT, size.x - 56, 22, Color("fff3d5"))
	if not subtitle.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(20, -20), subtitle, HORIZONTAL_ALIGNMENT_LEFT, size.x - 40, 17, Color("fff5dc"))

func _window(point: Vector2, window_size := Vector2(42, 48)) -> void:
	draw_rect(Rect2(point + Vector2(4, 5), window_size), Color(0, 0, 0, 0.16))
	draw_rect(Rect2(point, window_size), Color("547d86"))
	draw_line(point + Vector2(window_size.x * 0.5, 2), point + Vector2(window_size.x * 0.5, window_size.y - 2), Color("d4e5df"), 3)
	draw_line(point + Vector2(2, window_size.y * 0.5), point + Vector2(window_size.x - 2, window_size.y * 0.5), Color("d4e5df"), 3)

func _door(width := 64.0) -> void:
	var point := Vector2((size.x - width) * 0.5, size.y - 78)
	draw_rect(Rect2(point + Vector2(5, 5), Vector2(width, 78)), Color(0, 0, 0, 0.16))
	draw_rect(Rect2(point, Vector2(width, 78)), Color("684735"))
	draw_line(point + Vector2(width * 0.5, 0), point + Vector2(width * 0.5, 78), accent, 3)
	draw_circle(point + Vector2(width * 0.5 - 7, 43), 3, Color("e9c96b"))
	draw_circle(point + Vector2(width * 0.5 + 7, 43), 3, Color("e9c96b"))
	draw_colored_polygon(PackedVector2Array([point + Vector2(-25, 78), point + Vector2(width + 25, 78), point + Vector2(width + 38, 94), point + Vector2(-38, 94)]), Color("b8a985"))

func _draw_academic() -> void:
	for x in range(30, int(size.x - 55), 78):
		_window(Vector2(x, 102))
	_door()

func _draw_rectory() -> void:
	for x in range(28, int(size.x - 50), 72):
		_window(Vector2(x, 104), Vector2(38, 52))
	var center := size.x * 0.5
	draw_colored_polygon(PackedVector2Array([Vector2(center - 105, 87), Vector2(center, 55), Vector2(center + 105, 87)]), accent)
	for x in [center - 82, center - 42, center + 42, center + 82]:
		draw_rect(Rect2(x - 7, size.y - 110, 14, 110), accent)
	_door(72)

func _draw_library() -> void:
	draw_rect(Rect2(28, 94, size.x - 56, 70), Color("477781"))
	for x in range(45, int(size.x - 45), 58):
		draw_line(Vector2(x, 98), Vector2(x, 160), Color("d7e4de"), 4)
	draw_rect(Rect2(18, 172, size.x - 36, 12), accent)
	_door(76)

func _draw_auditorium() -> void:
	var center := size.x * 0.5
	draw_colored_polygon(PackedVector2Array([Vector2(25, size.y - 18), Vector2(25, 118), Vector2(center, 75), Vector2(size.x - 25, 118), Vector2(size.x - 25, size.y - 18)]), wall.lightened(0.12))
	for x in range(55, int(size.x - 55), 86):
		_window(Vector2(x, 132), Vector2(48, 58))
	_door(88)

func _draw_dorms() -> void:
	for row in [96, 160, 224]:
		for x in range(28, int(size.x - 50), 68):
			_window(Vector2(x, row), Vector2(36, 38))
	_door(70)

func _draw_meche() -> void:
	draw_rect(Rect2(26, 94, size.x - 52, size.y - 112), Color("f0dfb9"))
	for x in range(48, int(size.x - 60), 92):
		draw_arc(Vector2(x + 25, size.y - 58), 25, PI, TAU, 18, roof.darkened(0.15), 8)
	_door(58)
