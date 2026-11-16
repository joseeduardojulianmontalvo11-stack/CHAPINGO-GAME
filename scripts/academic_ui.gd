extends PanelContainer
## Panel academico modal compatible con teclado, mouse y tacto.

const Layout = preload("res://scripts/safe_layout.gd")
const Schedule = preload("res://scripts/academic_schedule.gd")
var manager: Node
var scroll: ScrollContainer
var footer: HBoxContainer
var body: VBoxContainer
var title: Label
var notice := ""
var answer_controls: Array[OptionButton] = []
var activity_feedback: Label
var submit_button: Button

func _ready() -> void:
	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 10)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	margin.add_child(column)
	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 8)
	column.add_child(nav)
	for pair in [["Resumen", show_overview], ["Horario", show_schedule], ["Historial", show_history]]:
		var button := _button(pair[0])
		button.pressed.connect(pair[1])
		nav.add_child(button)
	var close := _button("Cerrar (H/Esc)")
	close.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close.pressed.connect(close_panel)
	nav.add_child(close)
	title = Label.new()
	title.add_theme_font_size_override("font_size", 22)
	column.add_child(title)
	scroll = ScrollContainer.new()
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	scroll.follow_focus = true
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.mouse_filter = Control.MOUSE_FILTER_PASS
	body.add_theme_constant_override("separation", 12)
	scroll.add_child(body)
	footer = HBoxContainer.new()
	footer.add_theme_constant_override("separation", 10)
	column.add_child(footer)
	footer.hide()
	get_viewport().size_changed.connect(reflow)
	reflow()
	hide()

func _button(label: String) -> Button:
	var control := Button.new()
	control.text = label
	control.custom_minimum_size.y = 48
	return control

func _clear() -> void:
	answer_controls.clear()
	activity_feedback = null
	submit_button = null
	footer.hide()
	scroll.scroll_vertical = 0
	for container in [body, footer]:
		for child in container.get_children():
			container.remove_child(child)
			child.queue_free()

func _label(value: String, font_size := 20) -> Label:
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	body.add_child(label)
	return label

func open_with_notice(value: String) -> void:
	notice = value
	show_overview()
	show()
	manager.world.sync_modal_state()

func toggle_overview() -> void:
	if visible:
		close_panel()
	elif not manager.world.has_blocking_modal():
		notice = ""
		show_overview()
		show()
		manager.world.sync_modal_state()

func show_overview() -> void:
	_clear()
	title.text = "Vida académica"
	if not notice.is_empty():
		_label(notice, 21)
	var current: Dictionary = manager.current_session()
	if current.is_empty():
		if notice.is_empty():
			_label("No hay clase en este momento.")
	else:
		var subject: Dictionary = Schedule.SUBJECTS[current["subject_id"]]
		_label("CLASE DISPONIBLE: %s, %s\n%s" % [subject["name"], manager.schedule.format_minute(current["start"]), subject["professor"]], 22)
	var next: Dictionary = manager.next_session()
	if not next.is_empty():
		var definition: Dictionary = Schedule.SUBJECTS[next["subject_id"]]
		_label("PRÓXIMA CLASE\n%s · Día %d (%s) · %s\n%s" % [definition["name"], next["day"], Session.clock.weekday_name(next["day"]), manager.schedule.format_minute(next["start"]), definition["location"]])
	_label("Materias: Botánica, Matemáticas e Introducción a los Suelos. Horario ficticio para esta experiencia; no es un programa oficial de la UACh.", 17)

func show_schedule() -> void:
	_clear()
	title.text = "Horario escolar"
	for weekday in range(5):
		_label(Session.clock.WEEKDAYS[weekday].to_upper(), 21)
		var sessions: Array[Dictionary] = manager.schedule.sessions_for_weekday(weekday)
		if sessions.is_empty():
			_label("Sin clases. Incluso el calendario necesita respirar.", 17)
		for session in sessions:
			var subject: Dictionary = Schedule.SUBJECTS[session["subject_id"]]
			_label("%s–%s · %s\n%s · %s" % [manager.schedule.format_minute(session["start"]), manager.schedule.format_minute(session["start"] + session["duration"]), subject["name"], subject["professor"], subject["location"]], 18)

func show_history() -> void:
	_clear()
	title.text = "Historial académico"
	_label("ASISTENCIAS", 21)
	if Session.academics.attendance.is_empty():
		_label("Todavía no hay registros.")
	else:
		var keys: Array = Session.academics.attendance.keys()
		keys.sort()
		for key in keys:
			var entry: Dictionary = Session.academics.attendance[key]
			var subject: Dictionary = Schedule.SUBJECTS[entry["subject_id"]]
			_label("Día %d · %s — %s" % [entry["day"], subject["name"], str(entry["status"]).replace("_", " ").capitalize()], 18)
	_label("CALIFICACIONES", 21)
	if Session.academics.grades.is_empty():
		_label("Sin actividades evaluadas. El cero aún no te conoce.")
	else:
		for id in Session.academics.grades:
			_label("%s — %.1f / 10" % [Schedule.SUBJECTS[id]["name"], Session.academics.grades[id]], 20)

func show_activity(subject_id: String, attendance_message: String) -> void:
	_clear()
	var subject: Dictionary = Schedule.SUBJECTS[subject_id]
	title.text = "Actividad · " + subject["name"]
	activity_feedback = _label(attendance_message.replace("\n", " "), 18)
	body.remove_child(activity_feedback)
	activity_feedback.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(activity_feedback)
	var question_number := 0
	for question in subject["questions"]:
		question_number += 1
		_label("%d. %s" % [question_number, question["text"]], 19)
		var choice := OptionButton.new()
		choice.mouse_filter = Control.MOUSE_FILTER_PASS
		choice.fit_to_longest_item = false
		choice.clip_text = true
		choice.name = "Respuesta%d" % question_number
		choice.custom_minimum_size.y = 52
		choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		choice.add_item("Selecciona una respuesta…")
		for option in question["options"]:
			choice.add_item(option)
		body.add_child(choice)
		answer_controls.append(choice)
	submit_button = _button("Entregar actividad")
	submit_button.name = "EntregarActividad"
	submit_button.size_flags_vertical = Control.SIZE_SHRINK_END
	submit_button.pressed.connect(func(): _submit(subject_id))
	footer.add_child(submit_button)
	footer.show()
	if not answer_controls.is_empty():
		answer_controls[0].grab_focus()
	show()
	manager.world.sync_modal_state()

func _submit(subject_id: String) -> void:
	if not is_instance_valid(submit_button) or submit_button.disabled:
		return
	var answers: Array = []
	var missing := PackedStringArray()
	var first_missing: OptionButton
	for i in answer_controls.size():
		var choice := answer_controls[i]
		if choice.selected <= 0:
			missing.append(str(i + 1))
			if first_missing == null:
				first_missing = choice
		answers.append(choice.selected - 1)
	if not missing.is_empty():
		activity_feedback.text = "Falta responder: preguntas %s." % ", ".join(missing)
		first_missing.grab_focus()
		_reveal_answer.call_deferred(first_missing)
		return
	submit_button.disabled = true
	var grade := Session.academics.grade_activity(subject_id, answers)
	if grade < 0:
		notice = "Esta actividad ya fue evaluada."
	else:
		notice = "Actividad entregada.\nCalificación: %.1f / 10." % grade
	manager.world.save_current()
	show_history()
	var result := _label(notice, 21)
	body.move_child(result, 0)

func _reveal_answer(choice: OptionButton) -> void:
	if is_instance_valid(choice) and scroll.is_ancestor_of(choice):
		scroll.ensure_control_visible(choice)

func close_panel() -> void:
	hide()
	manager.world.sync_modal_state()

func reflow() -> void:
	var safe := Layout.rect(get_viewport())
	position = safe.position + Vector2(0, 60)
	size = Vector2(safe.size.x, safe.size.y - 60)
	if is_instance_valid(body):
		# El ancho lo asigna el ScrollContainer, descontando su barra vertical.
		body.custom_minimum_size.x = 0
