class_name OccupantComponent
extends Node


signal occupant_changed(new_occupant: InteractableGameObject)
signal occupant_clicked(clicked_occupant: InteractableGameObject)


@export var occupant: InteractableGameObject = null if get_children().size() == 0 else get_child(0):
	set = _occupant_setter,
	get = _occupant_getter


var is_occupied: bool:
	get: return is_instance_valid(occupant)


func _occupant_setter(value) -> void:
	_on_occupant_changed(value)
	occupant = value


func _occupant_getter() -> InteractableGameObject:
	return null if not is_instance_valid(occupant) else occupant


func _on_occupant_changed(new_occupant: InteractableGameObject):
	occupant_changed.emit(new_occupant)
	if is_instance_valid(occupant): _disconnect_occupant_signals(occupant)
	if is_instance_valid(new_occupant):
		_connect_occupant_signals(new_occupant)
		if is_instance_valid(new_occupant.get_parent()):
			new_occupant.reparent(self,false)
		else:
			add_child(new_occupant)
		var tile_position:Vector3 = get_parent().position
		new_occupant.position = Vector3(tile_position.x,0.2,tile_position.z)

		if new_occupant.get_property_list().map(func(item): return item.name).has("position_vector"):
			new_occupant.position_vector = get_parent().position_vector


func _on_occupant_clicked(object:InteractableGameObject):
	occupant_clicked.emit(object)


func _disconnect_occupant_signals(occupant: InteractableGameObject):
	if occupant.has_signal("clicked") and occupant.is_connected("clicked",_on_occupant_clicked):
		occupant.clicked.disconnect(_on_occupant_clicked)


func _connect_occupant_signals(occupant: InteractableGameObject):
	if occupant.has_signal("clicked") and not occupant.clicked.is_connected(_on_occupant_clicked):
		occupant.clicked.connect(_on_occupant_clicked)
