extends PanelContainer
signal dismissed
var text: Label

func _ready() -> void:
	var column := VBoxContainer.new()
	add_child(column)
	var close := Button.new()
	close.text = "Diario de misiones · Cerrar (J)"
	close.custom_minimum_size.y = 52
	close.pressed.connect(func(): dismissed.emit())
	column.add_child(close)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	text = Label.new()
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.add_theme_font_size_override("font_size", 21)
	scroll.add_child(text)
	get_viewport().size_changed.connect(reflow)
	Session.quests.changed.connect(refresh)
	reflow()
	refresh()
	hide()

func reflow() -> void:
	var safe := preload("res://scripts/safe_layout.gd").rect(get_viewport())
	position = safe.position + Vector2(0, 115)
	size = Vector2(safe.size.x, safe.size.y - 115)

func refresh() -> void:
	text.text = "Explora a tu ritmo. Habla con Marisol o visita el comedor.\n"
	for section in ["principal", "secundaria", "completada"]:
		text.text += "\n" + {"principal": "PRINCIPALES ACTIVAS", "secundaria": "SECUNDARIAS ACTIVAS", "completada": "COMPLETADAS"}[section] + "\n"
		var found := false
		for id in Session.quests.DEFINITIONS:
			var definition: Dictionary = Session.quests.DEFINITIONS[id]
			var state: String = Session.quests.state(id)
			if (section == "completada" and state == section) or (state == "activa" and definition["type"] == section):
				found = true
				text.text += definition["name"] + "\n" + definition["description"] + "\n" + Session.quests.objective(id) + "\n\n"
		if not found:
			text.text += "Ninguna por ahora.\n"
