extends Control
## Barra superior compacta y ayuda modal. Todos los controles respetan el area segura.

const Layout = preload("res://scripts/safe_layout.gd")
const AppInfo = preload("res://scripts/app_info.gd")
var world: Node2D
var top_panel: PanelContainer
var clock_label: Label
var save_button: Button
var help_panel: PanelContainer
var help_title: Label
var help_scroll: ScrollContainer
var help_text: Label
var help_close: Button

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
	help_panel.name = "PanelAyuda"
	add_child(help_panel)
	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	help_panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	column.add_child(header)
	help_title = Label.new()
	help_title.text = "Ayuda y controles"
	help_title.add_theme_font_size_override("font_size", 26)
	help_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	help_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(help_title)
	help_close = _button("Cerrar (Esc)", 150)
	help_close.pressed.connect(toggle_help)
	header.add_child(help_close)
	help_scroll = ScrollContainer.new()
	help_scroll.name = "ContenidoDesplazable"
	help_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	help_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	help_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(help_scroll)
	help_text = Label.new()
	help_text.name = "TextoAyuda"
	help_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help_text.add_theme_font_size_override("font_size", 20)
	help_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	help_text.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	help_text.text = AppInfo.TITLE + " · " + AppInfo.VERSION + "\n\n" + \
		"MOVIMIENTO\nWASD o flechas: caminar. E / Acción: interactuar. Esc / Cerrar: cerrar ventanas.\n\n" + \
		"ORGANIZACIÓN\nJ: diario de misiones. H: panel académico. Guardar conserva ubicación, reloj, asistencias y calificaciones.\n\n" + \
		"TACTO\nEl joystick mueve al estudiante; Acción interactúa y Cerrar sale de diálogos. En escritorio, Ctrl + Shift + M simula estos controles.\n\n" + \
		"VIDA ACADÉMICA\nEn la entrada de AULAS sabrás si hay una clase disponible y cuál sigue. Durante una clase, pulsa E o Acción, elige una respuesta en cada pregunta y entrega la actividad para ver tu calificación. Dormir en la vivienda avanza al día siguiente."
	help_scroll.add_child(help_text)
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
	# Un hijo de ScrollContainer sin ancho minimo puede colapsar y envolver letra
	# por letra. Se fija al ancho util, dejando el desplazamiento solo en vertical.
	if is_instance_valid(help_text):
		help_text.custom_minimum_size.x = maxf(280.0, safe.size.x - 72.0)
