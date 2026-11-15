extends StaticBody2D
## Arbol reutilizable con copa variable y colision limitada al tronco.

var canopy := Color("356a43")
var scale_factor := 1.0

func configure(point: Vector2, color: Color, factor := 1.0) -> void:
	position = point
	canopy = color
	scale_factor = factor

func _ready() -> void:
	var collider := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 16.0 * scale_factor
	collider.shape = shape
	add_child(collider)
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0, Vector2(1.15, 0.42))
	draw_circle(Vector2(7, 5), 35 * scale_factor, Color(0, 0, 0, 0.16))
	draw_set_transform(Vector2.ZERO)
	draw_rect(Rect2(Vector2(-8, -46) * scale_factor, Vector2(16, 50) * scale_factor), Color("76513a"))
	draw_circle(Vector2(0, -56) * scale_factor, 38 * scale_factor, canopy)
	draw_circle(Vector2(-22, -58) * scale_factor, 27 * scale_factor, canopy.lightened(0.12))
	draw_circle(Vector2(20, -70) * scale_factor, 26 * scale_factor, canopy.darkened(0.07))
