extends CanvasLayer

signal closed
var panel: PanelContainer
var speaker: Label
var message: Label
var prompt: Label
var pages: Array[String] = []
var page := 0
var is_open := false
var header: Label

func _ready() -> void:
	header = Label.new()
	header.position = Vector2(24, 18)
	header.text = "CHAPINGO: VIDA UNIVERSITARIA  ·  V0.2.1\nWASD / Flechas: caminar    E: interactuar    Esc: cerrar    F8: prueba táctil"
	header.add_theme_font_size_override("font_size", 15)
	header.add_theme_color_override("font_shadow_color", Color("24382b"))
	header.add_theme_constant_override("shadow_offset_x", 2)
	header.add_theme_constant_override("shadow_offset_y", 2)
	add_child(header)
	prompt = Label.new()
	prompt.position = Vector2(24, 115)
	prompt.add_theme_font_size_override("font_size", 22)
	add_child(prompt)
	panel = PanelContainer.new()
	# CanvasLayer no es un Control: el panel usa explícitamente el tamaño del viewport.
	add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 22)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)
	speaker = Label.new()
	speaker.add_theme_font_size_override("font_size", 23)
	column.add_child(speaker)
	message = Label.new()
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.add_theme_font_size_override("font_size", 21)
	column.add_child(message)
	var hint := Label.new()
	hint.text = "E: continuar    ·    Esc: despedirse"
	column.add_child(hint)
	panel.hide()
	get_viewport().size_changed.connect(_resize)
	_resize()

func _resize() -> void:
	var safe := preload("res://scripts/safe_layout.gd").rect(get_viewport())
	header.position = safe.position
	prompt.position = safe.position + Vector2(0, 115)
	panel.position = Vector2(safe.position.x, safe.end.y - 470)
	panel.size = Vector2(safe.size.x, 225)

func open_dialogue(character_name: String, lines: Array[String]) -> void:
	pages = lines
	page = 0
	speaker.text = character_name
	message.text = pages[page]
	is_open = true
	panel.show()

func advance() -> void:
	page += 1
	if page >= pages.size():
		close_dialogue()
	else:
		message.text = pages[page]

func close_dialogue() -> void:
	is_open = false
	panel.hide()
	closed.emit()
