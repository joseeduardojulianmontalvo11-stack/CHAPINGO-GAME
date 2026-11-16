extends Node
## Adaptador entre campus, conversaciones, misiones y guardado.
const Catalog = preload("res://scripts/social_catalog.gd")
var world: Node2D
var students: Dictionary = {}
var ui: PanelContainer
var current_id := ""

func _ready() -> void:
	for id in Catalog.PEOPLE:
		var data: Dictionary = Catalog.PEOPLE[id]
		var person := preload("res://scripts/social_student.gd").new()
		person.person_id = id
		person.display_name = data["name"]
		person.name = "Companero_" + id
		person.configure([data["position"]], data["palette"], data["accessory"])
		world.student.get_parent().add_child(person)
		students[id] = person
	ui = preload("res://scripts/social_ui.gd").new()
	ui.manager = self
	world.ui.add_child(ui)

func _process(_delta: float) -> void:
	for person in students.values():
		person.visible = world.current_location == "campus"

func nearby() -> String:
	if world.current_location != "campus":
		return ""
	var nearest := ""
	var distance: float = world.INTERACTION_DISTANCE
	for id in students:
		var candidate: float = world.student.position.distance_to(students[id].position)
		if candidate <= distance:
			distance = candidate
			nearest = id
	return nearest

func interact() -> bool:
	var id := nearby()
	if id.is_empty() or world.has_blocking_modal():
		return false
	current_id = id
	Session.social.meet(id)
	_sync_quests()
	world.save_current()
	ui.show()
	ui.show_topics()
	world.sync_modal_state()
	return true

func _sync_quests() -> void:
	# Son opcionales: se descubren al conversar, nunca bloquean otras misiones.
	Session.quests.start("conocer_companeros")
	Session.quests.start("sobremesa")
	if Session.social.relationships.size() >= 1:
		Session.quests.event("social_uno")
	if Session.social.relationships.size() >= 2:
		Session.quests.event("social_dos")
	for id in Session.social.relationships:
		if Session.social.shared_meal(id):
			Session.quests.event("social_comedor")

func can_share_meal() -> bool:
	return not current_id.is_empty() and nearby() == current_id \
		and world.student.position.distance_to(world.story.BREAKFAST_MENU) < 200 \
		and Session.social.affinity(current_id) >= 30

func choose(topic_id: String, option: int) -> void:
	if not ui.visible or nearby() != current_id:
		return
	if topic_id == "comedor" and not can_share_meal():
		return
	var result := Session.social.decide(current_id, topic_id, option)
	if result.is_empty():
		return
	_sync_quests()
	var saved: bool = world.save_current()
	ui.show_result(result["text"] + "\nAfinidad: %d / 100 (%+d) · %s" % [Session.social.affinity(current_id), result["delta"], Session.social.level(current_id)] + ("" if saved else "\nNo se pudo guardar. Intenta con Guardar al cerrar."))

func toggle_relations() -> void:
	if ui.visible:
		ui.close_panel()
	elif not world.has_blocking_modal():
		current_id = ""
		ui.show()
		ui.show_relations()
		world.sync_modal_state()
