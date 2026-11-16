extends PanelContainer
## Modal social: cabecera y cierre fijos; texto y opciones desplazables.
const Catalog = preload("res://scripts/social_catalog.gd")
var manager: Node
var heading: Label
var scroll: ScrollContainer
var body: VBoxContainer
var back: Button
var close: Button
var option_buttons: Array[Button] = []

func _ready() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("223b32")
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		style.set_content_margin(side, 10)
	add_theme_stylebox_override("panel", style)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	heading = Label.new()
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	heading.add_theme_font_size_override("font_size", 23)
	header.add_child(heading)
	close = _button("Cerrar (Esc/R)")
	close.autowrap_mode = TextServer.AUTOWRAP_OFF
	close.custom_minimum_size.x = 150
	close.pressed.connect(close_panel)
	header.add_child(close)
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.follow_focus = true
	column.add_child(scroll)
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 10)
	body.mouse_filter = Control.MOUSE_FILTER_PASS
	scroll.add_child(body)
	back = _button("Volver a los temas")
	back.pressed.connect(show_topics)
	column.add_child(back)
	get_viewport().size_changed.connect(reflow)
	reflow()
	hide()

func _button(value: String) -> Button:
	var button := Button.new()
	button.text = value
	button.custom_minimum_size.y = 48
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return button

func _clear() -> void:
	option_buttons.clear()
	for child in body.get_children():
		body.remove_child(child)
		child.queue_free()
	scroll.scroll_vertical = 0
	back.hide()

func _text(value: String) -> void:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 20)
	body.add_child(label)

func _option(value: String, callback: Callable) -> Button:
	var button := _button(value)
	button.pressed.connect(callback)
	body.add_child(button)
	option_buttons.append(button)
	return button

func _focus_first() -> void:
	if not option_buttons.is_empty():
		option_buttons[0].grab_focus()
	else:
		close.grab_focus()

func show_relations() -> void:
	_clear()
	heading.text = "Relaciones sociales"
	_text("Conoce gente a tu ritmo. Acércate y pulsa E / Acción. Cada tema modifica la afinidad una sola vez. Conocido: 0–29 · Compañero: 30–59 · Amigo: 60–100.")
	for id in Catalog.PEOPLE:
		var person: Dictionary = Catalog.PEOPLE[id]
		var known: bool = Session.social.relationships.has(id)
		_text("%s · %s\n%s · Afinidad %d / 100\n%s" % [person["name"], person["place"], Session.social.level(id) if known else "Por conocer", Session.social.affinity(id), person["info"]])
	_text("Misiones opcionales: conoce a dos compañeros y comparte una sobremesa. Se descubren al saludar y aparecen en Diario (J). Para la sobremesa, conoce mejor a Beto (30 de afinidad) y conversa junto al comedor.")
	_focus_first()

func show_topics() -> void:
	if manager.current_id.is_empty():
		show_relations()
		return
	_clear()
	var id: String = manager.current_id
	var person: Dictionary = Catalog.PEOPLE[id]
	heading.text = "%s · %s · %d / 100" % [person["name"], Session.social.level(id), Session.social.affinity(id)]
	var rank := 2 if Session.social.affinity(id) >= 60 else (1 if Session.social.affinity(id) >= 30 else 0)
	_text(person["greetings"][rank])
	for topic_id in person["topics"]:
		var done: bool = Session.social.relationships[id]["decisions"].has(topic_id)
		_option(person["topics"][topic_id]["title"] + (" · ya conversado" if done else ""), show_choices.bind(topic_id))
	var meal := _option("Compartir un rato en el comedor", show_choices.bind("comedor"))
	meal.disabled = not manager.can_share_meal()
	if meal.disabled:
		_text("La sobremesa requiere 30 de afinidad y estar juntos junto al Comedor Central. Beto suele estar allí.")
	_focus_first()

func show_choices(topic_id: String) -> void:
	if topic_id == "comedor" and not manager.can_share_meal():
		return
	var definition: Dictionary = Session.social.topic(manager.current_id, topic_id)
	if definition.is_empty():
		return
	_clear()
	_text(definition["line"])
	for i in definition["choices"].size():
		_option(definition["choices"][i][0], manager.choose.bind(topic_id, i))
	back.show()
	_focus_first()

func show_result(value: String) -> void:
	_clear()
	var id: String = manager.current_id
	heading.text = "%s · %s" % [Catalog.PEOPLE[id]["name"], Session.social.level(id)]
	_text(value)
	back.show()
	back.grab_focus()

func close_panel() -> void:
	hide()
	manager.current_id = ""
	manager.world.sync_modal_state()

func reflow() -> void:
	var safe := preload("res://scripts/safe_layout.gd").rect(get_viewport())
	position = safe.position + Vector2(0, 60)
	size = Vector2(safe.size.x, safe.size.y - 60)
