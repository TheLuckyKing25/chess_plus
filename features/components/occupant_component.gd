class_name OccupantComponent
extends Node


signal occupant_changed(new_occupant: InteractableGameObject)
signal occupant_clicked(clicked_occupant: InteractableGameObject)


@export var occupant: InteractableGameObject = null if get_children().size() == 0 else get_child(0):
	set = _occupant_setter,
	get = _occupant_getter


func _occupant_setter(value: InteractableGameObject) -> void:
	_on_occupant_changed(value)
	if is_instance_valid(value):
		get_parent().add_to_group(Constants.GROUPS.IS_OCCUPIED)
	else:
		get_parent().remove_from_group(Constants.GROUPS.IS_OCCUPIED)
	occupant = value


func _occupant_getter() -> InteractableGameObject:
	return null if not is_instance_valid(occupant) else occupant


func _on_occupant_changed(new_occupant: InteractableGameObject) -> void:
	occupant_changed.emit(new_occupant)
	if is_instance_valid(occupant): disconnect_occupant_signals(occupant)
	if is_instance_valid(new_occupant):
		connect_occupant_signals(new_occupant)
		if is_instance_valid(new_occupant.get_parent()):
			new_occupant.reparent(self,false)
		else:
			add_child(new_occupant)
		var tile_position:Vector3 = get_parent().position
		new_occupant.position = Vector3(tile_position.x,0.2,tile_position.z)

		if new_occupant.get_property_list().map(func(item:Dictionary) -> String: return item.name).has("position_vector"):
			new_occupant.position_vector = get_parent().position_vector


func _on_occupant_clicked(object:InteractableGameObject) -> void:
	occupant_clicked.emit(object)


func disconnect_occupant_signals(connected_occupant: InteractableGameObject) -> void:
	if connected_occupant.has_signal("clicked") and connected_occupant.is_connected("clicked",_on_occupant_clicked):
		connected_occupant.clicked.disconnect(_on_occupant_clicked)


func connect_occupant_signals(unconnected_occupant: InteractableGameObject) -> void:
	if unconnected_occupant.has_signal("clicked") and not unconnected_occupant.clicked.is_connected(_on_occupant_clicked):
		unconnected_occupant.clicked.connect(_on_occupant_clicked)
