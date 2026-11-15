extends Control
## Barra superior compacta y ayuda modal. Todos los controles respetan el area segura.

const Layout = preload("res://scripts/safe_layout.gd")
const AppInfo = preload("res://scripts/app_info.gd")
var world: Node2D
var top_panel: PanelContainer
var clock_label: Label
var save_button: Button
var help_panel: PanelContainer

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	top_panel = PanelContainer.new()
	add_child(top_panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	top_panel.add_child(row)
	save_button = _button("Guardar", 96)
	save_button.pressed.connect(_save)
	row.add_child(save_button)
	var menu := _button("Guardar y menú", 145)
	menu.pressed.connect(_save_and_menu)
	row.add_child(menu)
	var identity := Label.new()
	identity.text = str(Session.profile.get("name", "Estudiante"))
	identity.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	identity.custom_minimum_size.x = 110
	identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(identity)
	clock_label = Label.new()
	clock_label.custom_minimum_size.x = 180
	clock_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(clock_label)
	var academic := _button("Académico (H)", 145)
	academic.pressed.connect(func(): world.academic.ui.toggle_overview())
	row.add_child(academic)
	var journal := _button("Diario (J)", 120)
	journal.pressed.connect(world.story.toggle_journal)
	row.add_child(journal)
	var help := _button("Ayuda", 80)
	help.pressed.connect(toggle_help)
	row.add_child(help)
	_build_help()
	get_viewport().size_changed.connect(reflow)
	reflow()

func _button(label: String, width: float) -> Button:
	var control := Button.new()
	control.text = label
	control.custom_minimum_size = Vector2(width, 52)
	return control

func _build_help() -> void:
	help_panel = PanelContainer.new()
	add_child(help_panel)
	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	help_panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)
	var close := _button("Ayuda · Cerrar", 180)
	close.pressed.connect(toggle_help)
	column.add_child(close)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var text := Label.new()
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.add_theme_font_size_override("font_size", 20)
	text.text = AppInfo.TITLE + " · " + AppInfo.VERSION + "\n\n" + \
		"MOVIMIENTO\nWASD o flechas: caminar. E / Acción: interactuar. Esc / Cerrar: cerrar ventanas.\n\n" + \
		"ORGANIZACIÓN\nJ: diario de misiones. H: panel académico. Guardar conserva ubicación, reloj, asistencias y calificaciones.\n\n" + \
		"TACTO\nEl joystick mueve al estudiante; Acción interactúa y Cerrar sale de diálogos. En escritorio, Ctrl + Shift + M simula estos controles.\n\n" + \
		"VIDA ACADÉMICA\nConsulta el horario, llega a AULAS durante una clase y realiza la actividad. Dormir en la vivienda avanza al día siguiente. Explorar sigue siendo opcional y saludable."
	scroll.add_child(text)
	help_panel.hide()

func _process(_delta: float) -> void:
	clock_label.text = Session.clock.label()

func _save() -> void:
	save_button.text = "Guardado" if world.save_current() else "Error"

func _save_and_menu() -> void:
	if world.save_current():
		get_tree().change_scene_to_file("res://scenes/menu.tscn")

func toggle_help() -> void:
	if not help_panel.visible and world.has_blocking_modal():
		return
	help_panel.visible = not help_panel.visible
	world.sync_modal_state()

func reflow() -> void:
	var safe := Layout.rect(get_viewport())
	position = safe.position
	size = safe.size
	top_panel.position = Vector2.ZERO
	top_panel.size = Vector2(safe.size.x, 52)
	help_panel.position = Vector2(0, 60)
	help_panel.size = Vector2(safe.size.x, safe.size.y - 60)
