extends StaticBody2D

const DISPLAY_NAME := "Marisol · estudiante guía"
const DIALOGUE: Array[String] = [
	"¡Bienvenido a Chapingo! Soy Marisol. Si es tu primer día, respira: todos nos perdimos por aquí alguna vez.",
	"Las aulas de Preparatoria Agrícola están al este: cruza el Patio de Honor y busca la entrada marcada. El diario (J o su botón) te recuerda el camino. Al oeste está el Comedor Central.",
	"Rectoría queda al norte; la Biblioteca, al noreste. También puedes visitar dormitorios, La Meche, jardines y canchas. ¡Nos vemos por el campus!"
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
