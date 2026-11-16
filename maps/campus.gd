extends Node2D
## Campus V0.4 original inspirado en la organizacion espacial de Chapingo.
## Las huellas de BUILDINGS alimentan tanto el dibujo como las colisiones.

const Building = preload("res://scripts/campus_building.gd")
const CampusTree = preload("res://scripts/campus_tree.gd")
const SIZE := Vector2(3200, 2200)
const BUILDINGS := [
	{"id": "auditorio", "title": "AUDITORIO ALVARO CARRILLO", "subtitle": "Cultura y encuentro", "rect": Rect2(260, 230, 610, 330), "wall": Color("d6b17b"), "roof": Color("804333"), "accent": Color("f0d59d"), "style": "auditorium"},
	{"id": "rectoria", "title": "RECTORIA", "subtitle": "Administracion central", "rect": Rect2(1290, 170, 610, 300), "wall": Color("d9c49a"), "roof": Color("884337"), "accent": Color("f2dfb3"), "style": "rectoria"},
	{"id": "biblioteca", "title": "BIBLIOTECA CENTRAL", "subtitle": "Lectura y consulta", "rect": Rect2(2160, 210, 560, 320), "wall": Color("c9b892"), "roof": Color("4f625a"), "accent": Color("e9dfbc"), "style": "library"},
	{"id": "comedor", "title": "COMEDOR CENTRAL", "subtitle": "Servicio universitario", "rect": Rect2(260, 870, 610, 350), "wall": Color("d8b782"), "roof": Color("96513b"), "accent": Color("f3d99e"), "style": "academic"},
	{"id": "preparatoria", "title": "PREPARATORIA AGRICOLA · AULAS", "subtitle": "Acceso a salones", "rect": Rect2(2350, 790, 600, 350), "wall": Color("d2bd91"), "roof": Color("75463b"), "accent": Color("ead8ae"), "style": "academic"},
	{"id": "dormitorios", "title": "DORMITORIOS", "subtitle": "Internado estudiantil", "rect": Rect2(210, 1590, 800, 380), "wall": Color("c9ae7f"), "roof": Color("765044"), "accent": Color("e7d4ab"), "style": "dorms"},
	{"id": "meche", "title": "LA MECHE", "subtitle": "Punto de convivencia", "rect": Rect2(1250, 1650, 520, 300), "wall": Color("dfc38e"), "roof": Color("9a5a3d"), "accent": Color("f0deba"), "style": "meche"}
]
const TREES := [
	Vector2(100, 180), Vector2(160, 650), Vector2(320, 680), Vector2(570, 700), Vector2(820, 690),
	Vector2(1030, 250), Vector2(1090, 520), Vector2(2050, 230), Vector2(2050, 510), Vector2(2840, 250),
	Vector2(3030, 470), Vector2(3040, 850), Vector2(3050, 1210), Vector2(110, 1100), Vector2(1040, 980),
	Vector2(1120, 1280), Vector2(2070, 900), Vector2(2140, 1210), Vector2(2940, 1420), Vector2(1880, 1510),
	Vector2(1080, 1710), Vector2(1100, 2010), Vector2(1860, 2050), Vector2(2110, 1640), Vector2(3050, 2030),
	Vector2(90, 1990), Vector2(2850, 620), Vector2(1980, 640)
]
const BENCHES := [
	Rect2(1180, 790, 95, 24), Rect2(1910, 790, 95, 24), Rect2(1180, 1280, 95, 24), Rect2(1910, 1280, 95, 24),
	Rect2(1450, 730, 95, 24), Rect2(1690, 730, 95, 24), Rect2(1450, 1360, 95, 24), Rect2(1690, 1360, 95, 24)
]
const LAMPS := [Vector2(1110, 735), Vector2(2070, 735), Vector2(1110, 1370), Vector2(2070, 1370), Vector2(1400, 1390), Vector2(1840, 1390)]
const CAMPUS_SIGNS := [
	{"p": Vector2(1000, 650), "t": "Centro / Rectoria"},
	{"p": Vector2(2110, 650), "t": "Biblioteca / Aulas"},
	# Alejado del rotulo y portal de vivienda, sin modificar edificios ni accesos.
	{"p": Vector2(790, 1450), "t": "Dormitorios / La Meche"}
]
const WALKABLE_CHECKPOINTS := [
	Vector2(1420, 1180), Vector2(1050, 1180), Vector2(900, 1180), Vector2(565, 1280),
	Vector2(1580, 650), Vector2(1580, 520), Vector2(2090, 660), Vector2(2440, 670),
	Vector2(2680, 1200), Vector2(2150, 1430), Vector2(1600, 1500), Vector2(1080, 1480), Vector2(1030, 1550)
]

func _ready() -> void:
	for data in BUILDINGS:
		var building := Building.new()
		building.configure(data)
		building.name = str(data["id"]).capitalize()
		add_child(building)
	for i in TREES.size():
		var tree := CampusTree.new()
		var hue := Color("356a43") if i % 3 else Color("416f45")
		tree.configure(TREES[i], hue, 0.85 + (i % 4) * 0.08)
		tree.name = "Arbol%02d" % i
		add_child(tree)
	for rect in BENCHES:
		add_obstacle(rect, "Banca")
	for point in LAMPS:
		add_circle_obstacle(point, 7.0, "Luminaria")
	for border in [Rect2(-30, -30, SIZE.x + 60, 30), Rect2(-30, SIZE.y, SIZE.x + 60, 30), Rect2(-30, 0, 30, SIZE.y), Rect2(SIZE.x, 0, 30, SIZE.y)]:
		add_obstacle(border, "Limite")

func building_rect(id: String) -> Rect2:
	for data in BUILDINGS:
		if data["id"] == id:
			return data["rect"]
	return Rect2()

func is_walkable(point: Vector2, margin := 14.0) -> bool:
	if not Rect2(Vector2.ZERO, SIZE).grow(-margin).has_point(point):
		return false
	for data in BUILDINGS:
		if (data["rect"] as Rect2).grow(margin).has_point(point):
			return false
	for rect in BENCHES:
		if rect.grow(margin).has_point(point):
			return false
	for tree in TREES:
		if point.distance_to(tree) < 18.0 + margin:
			return false
	for lamp in LAMPS:
		if point.distance_to(lamp) < 7.0 + margin:
			return false
	return true

func add_obstacle(rect: Rect2, prefix := "Obstaculo") -> void:
	var body := StaticBody2D.new()
	body.name = prefix
	body.position = rect.get_center()
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collider.shape = shape
	body.add_child(collider)
	add_child(body)

func add_circle_obstacle(point: Vector2, radius: float, prefix := "Obstaculo") -> void:
	var body := StaticBody2D.new()
	body.name = prefix
	body.position = point
	var collider := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = radius
	collider.shape = shape
	body.add_child(collider)
	add_child(body)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("76945b"))
	_draw_grass()
	_draw_paths()
	_draw_patios()
	_draw_gardens()
	_draw_sports()
	_draw_props()
	_draw_housing_portal()

func _draw_grass() -> void:
	for x in range(35, int(SIZE.x), 78):
		for y in range(35, int(SIZE.y), 78):
			var sway := float((x + y) % 13)
			draw_line(Vector2(x, y), Vector2(x + 3 + sway * 0.1, y - 7), Color("66854e"), 2)

func _draw_paths() -> void:
	var stone := Color("d8c9a7")
	var edge := Color("aa9b7e")
	for rect in [Rect2(0, 620, 3200, 120), Rect2(0, 1240, 3200, 120), Rect2(1020, 470, 120, 1730), Rect2(2020, 530, 120, 1670), Rect2(1520, 470, 140, 1180), Rect2(870, 1020, 1480, 130), Rect2(870, 1430, 1480, 120)]:
		draw_rect(rect.grow(5), edge)
		draw_rect(rect, stone)
		for x in range(int(rect.position.x + 15), int(rect.end.x - 10), 46):
			draw_line(Vector2(x, rect.position.y + 4), Vector2(x + 22, rect.end.y - 4), Color(0.55, 0.5, 0.4, 0.18), 2)
	for rect in [Rect2(520, 560, 90, 310), Rect2(1530, 470, 120, 150), Rect2(2400, 530, 110, 90), Rect2(520, 1220, 100, 140), Rect2(2630, 1140, 110, 100), Rect2(540, 1360, 110, 230), Rect2(1450, 1550, 110, 100)]:
		draw_rect(rect.grow(4), edge)
		draw_rect(rect, stone)

func _draw_patios() -> void:
	var patio := Rect2(1140, 740, 880, 610)
	draw_rect(patio, Color("c7b792"))
	for x in range(1160, 2010, 55):
		draw_line(Vector2(x, 745), Vector2(x, 1345), Color(0.55, 0.49, 0.38, 0.25), 2)
	for y in range(760, 1340, 55):
		draw_line(Vector2(1145, y), Vector2(2015, y), Color(0.55, 0.49, 0.38, 0.25), 2)
	var center := Vector2(1580, 1040)
	draw_circle(center, 150, Color("a99a7b"))
	draw_circle(center, 134, Color("d9cba9"))
	draw_circle(center, 72, Color("62855d"))
	draw_circle(center, 42, Color("7b9670"))
	draw_string(ThemeDB.fallback_font, Vector2(1400, 825), "PATIO DE HONOR", HORIZONTAL_ALIGNMENT_CENTER, 360, 28, Color("5b4937"))

func _draw_gardens() -> void:
	for garden in [Rect2(900, 780, 190, 180), Rect2(2070, 790, 190, 180), Rect2(900, 1390, 190, 180), Rect2(2070, 1380, 190, 180)]:
		draw_rect(garden.grow(5), Color("9c8d70"))
		draw_rect(garden, Color("4d754d"))
		for x in range(int(garden.position.x + 18), int(garden.end.x - 10), 32):
			for y in range(int(garden.position.y + 18), int(garden.end.y - 10), 32):
				draw_circle(Vector2(x, y), 4, Color("e9c95e") if (x + y) % 3 else Color("d98981"))

func _draw_sports() -> void:
	var zone := Rect2(2240, 1570, 720, 440)
	draw_rect(zone.grow(12), Color("566b55"))
	draw_rect(zone, Color("6c9a62"))
	draw_rect(Rect2(2300, 1630, 600, 320), Color("8baf72"), false, 6)
	draw_line(Vector2(2600, 1630), Vector2(2600, 1950), Color("e7e1c7"), 5)
	draw_circle(Vector2(2600, 1790), 72, Color("e7e1c7"), false, 5)
	draw_rect(Rect2(2300, 1700, 90, 180), Color("e7e1c7"), false, 4)
	draw_rect(Rect2(2810, 1700, 90, 180), Color("e7e1c7"), false, 4)
	draw_string(ThemeDB.fallback_font, Vector2(2400, 1550), "AREAS DEPORTIVAS", HORIZONTAL_ALIGNMENT_CENTER, 400, 24, Color("f4efd8"))

func _draw_props() -> void:
	for rect in BENCHES:
		draw_rect(Rect2(rect.position + Vector2(4, 5), rect.size), Color(0, 0, 0, 0.16))
		draw_rect(rect, Color("765339"))
		draw_line(rect.position + Vector2(12, 5), rect.end - Vector2(12, 5), Color("b4814c"), 5)
	for point in LAMPS:
		draw_line(point, point - Vector2(0, 58), Color("3d4b47"), 6)
		draw_circle(point - Vector2(0, 62), 12, Color("f5df95"))
		draw_arc(point - Vector2(0, 62), 15, PI, TAU, 12, Color("394b47"), 5)
	for sign in CAMPUS_SIGNS:
		var p: Vector2 = sign["p"]
		draw_line(p, p + Vector2(0, 62), Color("5b4938"), 7)
		draw_rect(Rect2(p - Vector2(95, 30), Vector2(190, 42)), Color("315b43"))
		draw_string(ThemeDB.fallback_font, p - Vector2(86, 2), sign["t"], HORIZONTAL_ALIGNMENT_CENTER, 172, 16, Color("fff2d2"))

func _draw_housing_portal() -> void:
	var rect := Rect2(1018, 1515, 92, 62)
	draw_rect(Rect2(rect.position + Vector2(5, 6), rect.size), Color(0, 0, 0, 0.16))
	draw_rect(rect, Color("7a5b3c"))
	draw_rect(Rect2(1030, 1528, 68, 49), Color("d4aa55"))
	draw_string(ThemeDB.fallback_font, Vector2(955, 1500), "Tu vivienda · E", HORIZONTAL_ALIGNMENT_CENTER, 220, 19, Color("fff2d3"))
