extends "res://maps/campus.gd"
var housing := "internado"

func _ready() -> void:
	for rect in [Rect2(0, 0, 1152, 130), Rect2(0, 0, 150, 720), Rect2(1000, 0, 152, 720), Rect2(0, 620, 1152, 100), Rect2(210, 180, 200, 230), Rect2(760, 180, 180, 100)]:
		add_obstacle(rect)

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1152, 720), Color("324b42"))
	draw_rect(Rect2(150, 130, 850, 490), Color("bfab88") if housing == "internado" else Color("a9b5ad"))
	draw_rect(Rect2(210, 180, 200, 230), Color("6b4e38"))
	draw_rect(Rect2(220, 190, 180, 210), Color("678b9c"))
	draw_rect(Rect2(230, 200, 160, 45), Color("eee3cd"))
	draw_rect(Rect2(760, 180, 180, 100), Color("805c3b"))
	draw_rect(Rect2(785, 195, 70, 40), Color("f0dfb2"))
	draw_rect(Rect2(520, 580, 100, 40), Color("d4a957"))
	draw_string(ThemeDB.fallback_font, Vector2(210, 165), "Dormitorio del internado" if housing == "internado" else "Habitación externa", HORIZONTAL_ALIGNMENT_LEFT, -1, 24)
	draw_string(ThemeDB.fallback_font, Vector2(465, 565), "E · Salir al campus", HORIZONTAL_ALIGNMENT_LEFT, -1, 20)
