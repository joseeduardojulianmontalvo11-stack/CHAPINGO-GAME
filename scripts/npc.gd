extends StaticBody2D

const DISPLAY_NAME := "Marisol · estudiante guía"
const DIALOGUE: Array[String] = [
	"¡Bienvenido a Chapingo! Soy Marisol. Si es tu primer día, respira: todos nos perdimos por aquí alguna vez.",
	"Las aulas están al noreste: busca la entrada marcada bajo el edificio AULAS. El diario (J o su botón) te recuerda el camino. Al oeste, el comedor. La mejor brújula es seguir a quien lleva hambre.",
	"Puedes recorrer esta pequeña plaza a tu ritmo. Los árboles dan sombra, pero todavía no te ayudan a estudiar. ¡Nos vemos por el campus!"
]

func _draw() -> void:
	draw_circle(Vector2(0, 1), 15, Color(0, 0, 0, 0.15))
	draw_line(Vector2(-5, -8), Vector2(-5, 2), Color("263c48"), 6)
	draw_line(Vector2(5, -8), Vector2(5, 2), Color("263c48"), 6)
	draw_rect(Rect2(-12, -30, 24, 24), Color("a95c37"))
	draw_circle(Vector2(0, -39), 12, Color("3f302a"))
	draw_circle(Vector2(0, -36), 9, Color("c9936c"))
	draw_circle(Vector2(-3, -37), 1.5, Color("30251f"))
	draw_circle(Vector2(3, -37), 1.5, Color("30251f"))
