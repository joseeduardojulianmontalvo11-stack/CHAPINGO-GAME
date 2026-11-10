extends Node2D
## Adaptador de eventos del campus. No controla el movimiento ni sustituye diálogos.
const BREAKFAST_SIGN := Vector2(230, 405)
const BREAKFAST_MENU := Vector2(440, 405)
const CLASSROOM_ENTRY := Rect2(1385, 345, 90, 95)
var world: Node2D
var journal: PanelContainer

func _ready() -> void:
	journal = preload("res://scripts/quest_journal.gd").new()
	world.ui.add_child(journal)
	journal.dismissed.connect(toggle_journal)
	Session.quests.changed.connect(func(): world.save_current())

func toggle_journal() -> void:
	if world.ui.is_open:
		return
	journal.visible = not journal.visible
	world.student.controls_enabled = not journal.visible
	world.touch.release_all()
	world.touch.visible = not journal.visible and (OS.has_feature("mobile") or world.touch.test_mode)

func marisol() -> void:
	Session.quests.start("primer_salon")

func nearby() -> String:
	if world.current_location != "campus":
		return ""
	if world.student.position.distance_to(BREAKFAST_SIGN) < 65:
		return "aviso"
	if world.student.position.distance_to(BREAKFAST_MENU) < 65:
		return "menu"
	return ""

func interact() -> bool:
	var target := nearby()
	if target.is_empty():
		return false
	if target == "aviso":
		Session.quests.start("primer_desayuno")
		say("Aviso del comedor", "¿Primer desayuno? Consulta el menú a la derecha de la entrada. La fila no es una materia, pero tiene asistencia completa.")
	else:
		var completed := Session.quests.event("menu_comedor")
		if not completed.is_empty():
			say("El primer desayuno", Session.quests.DEFINITIONS["primer_desayuno"]["consequence"])
		else:
			say("Menú del comedor", "Desayuno del día: paciencia con acompañamiento. Si es tu primera visita, consulta el aviso a la izquierda de la entrada.")
	return true

func say(title: String, line: String) -> void:
	world.student.controls_enabled = false
	var lines: Array[String] = [line]
	world.ui.open_dialogue(title, lines)

func _process(_delta: float) -> void:
	visible = world.current_location == "campus"
	if not visible or world.ui.is_open or journal.visible:
		return
	if CLASSROOM_ENTRY.has_point(world.student.position):
		if not Session.quests.event("entrada_aulas").is_empty():
			say("¡Bienvenido a las aulas!", "¡Encontraste tu salón! Bueno, el edificio. La puerta correcta es contenido del siguiente semestre. " + Session.quests.DEFINITIONS["primer_salon"]["consequence"])

func _draw() -> void:
	for point in [BREAKFAST_SIGN, BREAKFAST_MENU]:
		draw_rect(Rect2(point - Vector2(20, 28), Vector2(40, 38)), Color("f1db9f"))
		draw_string(ThemeDB.fallback_font, point + Vector2(-30, -35), "Aviso" if point == BREAKFAST_SIGN else "Menú", HORIZONTAL_ALIGNMENT_LEFT, -1, 18)
	draw_rect(CLASSROOM_ENTRY, Color(0.9, 0.8, 0.4, 0.18))
	draw_string(ThemeDB.fallback_font, Vector2(1375, 455), "Entrada aulas", HORIZONTAL_ALIGNMENT_LEFT, -1, 17)
