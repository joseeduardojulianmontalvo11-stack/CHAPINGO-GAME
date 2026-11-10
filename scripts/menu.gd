extends Control

var column: VBoxContainer
var preview: CharacterBody2D
var name_field: LineEdit
var look: OptionButton
var hair: OptionButton
var skin: OptionButton
var housing: OptionButton
const HAIR := ["382d29", "754b30", "c69b56", "613b64"]
const SKIN := ["e5b58b", "c9936c", "946747", "694a37"]

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("203f35")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)
	column = VBoxContainer.new()
	column.custom_minimum_size.x = 560
	column.add_theme_constant_override("separation", 12)
	center.add_child(column)
	var layout := func():
		var safe := preload("res://scripts/safe_layout.gd").rect(get_viewport())
		scroll.position = safe.position
		scroll.size = safe.size
		center.custom_minimum_size.y = safe.size.y
		column.custom_minimum_size.x = minf(640, safe.size.x)
	get_viewport().size_changed.connect(layout)
	layout.call()
	show_menu()

func clear() -> void:
	for child in column.get_children():
		column.remove_child(child)
		child.queue_free()

func label_text(value: String, font_size := 20) -> void:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	column.add_child(label)

func button(text: String, action: Callable) -> Button:
	var control := Button.new()
	control.text = text
	control.custom_minimum_size.y = 52
	control.pressed.connect(action)
	column.add_child(control)
	return control

func show_menu() -> void:
	clear()
	label_text("CHAPINGO: VIDA UNIVERSITARIA", 28)
	label_text("V0.3 · Tu historia comienza en el campus")
	button("Nueva partida", show_creator)
	button("Continuar", continue_game).disabled = Session.read_save().is_empty()
	button("Salir", func(): get_tree().quit())
	label_text("Nueva partida reemplaza el guardado al comenzar.", 16)

func choice(title: String, values: Array) -> OptionButton:
	label_text(title, 16)
	var control := OptionButton.new()
	control.custom_minimum_size.y = 48
	control.fit_to_longest_item = false
	control.get_popup().add_theme_constant_override("v_separation", 22)
	for value in values:
		control.add_item(value)
	column.add_child(control)
	control.item_selected.connect(func(_index): update_preview())
	return control

func show_creator() -> void:
	clear()
	label_text("Tu primer día en Chapingo", 26)
	name_field = LineEdit.new()
	name_field.placeholder_text = "Nombre del estudiante"
	name_field.max_length = 32
	name_field.custom_minimum_size.y = 48
	column.add_child(name_field)
	look = choice("Apariencia", ["Camisa crema", "Camisa azul", "Camisa terracota"])
	hair = choice("Cabello", ["Oscuro", "Castaño", "Rubio", "Violeta"])
	skin = choice("Tono de piel", ["Claro", "Medio", "Moreno", "Oscuro"])
	housing = choice("Vivienda", ["Internado: compañeros cerca; el silencio, de intercambio.", "Externa: independencia… y platos que no se lavan solos."])
	var holder := Control.new()
	holder.custom_minimum_size.y = 85
	column.add_child(holder)
	preview = preload("res://characters/student.tscn").instantiate()
	preview.get_node("Camara").enabled = false
	preview.set_physics_process(false)
	preview.position = Vector2(280, 78)
	holder.resized.connect(func(): preview.position.x = holder.size.x / 2 if is_instance_valid(preview) else 0)
	preview.scale = Vector2(1.5, 1.5)
	holder.add_child(preview)
	update_preview()
	button("Comenzar", start_game)
	button("Volver", show_menu)

func selected_profile() -> Dictionary:
	return {"name": name_field.text.strip_edges() if not name_field.text.strip_edges().is_empty() else "Estudiante", "appearance": look.selected, "hair": HAIR[hair.selected], "skin": SKIN[skin.selected], "housing": "internado" if housing.selected == 0 else "externa"}

func update_preview() -> void:
	if is_instance_valid(preview) and is_instance_valid(housing):
		preview.apply_profile(selected_profile())

func start_game() -> void:
	Session.new_game(selected_profile())
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func continue_game() -> void:
	if Session.load_game():
		get_tree().change_scene_to_file("res://scenes/main.tscn")
