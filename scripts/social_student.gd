extends "res://scripts/ambient_student.gd"
## Companero estable sin nuevas colisiones. Reutiliza el dibujo de estudiantes.
var person_id := ""
var display_name := ""

func _draw() -> void:
	super._draw()
	draw_string(ThemeDB.fallback_font, Vector2(-55, -58), display_name, HORIZONTAL_ALIGNMENT_CENTER, 110, 18, Color("fff5d6"))
