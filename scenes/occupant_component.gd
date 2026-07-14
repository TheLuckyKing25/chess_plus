class_name OccupantComponent
extends Node

@export var occupant: Node3D = null if get_children().size() == 0 else get_child(0):
	set = _occupant_setter,
	get = _occupant_getter


var is_occupied: bool:
	get: return is_instance_valid(occupant)


func _occupant_setter(value) -> void:
	_on_occupant_changed(value)
	occupant = value


func _occupant_getter() -> Node3D:
	return null if not is_instance_valid(occupant) else occupant


func _on_occupant_changed(new_occupant: PieceObject):
	if is_instance_valid(occupant): _disconnect_occupant_signals(occupant)
	if is_instance_valid(new_occupant):
		_connect_occupant_signals(new_occupant)
		if is_instance_valid(new_occupant.get_parent()):
			new_occupant.reparent(self,false)
		else:
			add_child(new_occupant)
			var tile_position:Vector3 = get_parent().position
			new_occupant.position = Vector3(tile_position.x,0.2,tile_position.z)


func _disconnect_occupant_signals(occupant: Node3D):
	if occupant.has_signal("clicked") and occupant.is_connected("clicked",get_parent()._on_occupant_clicked):
		occupant.clicked.disconnect(get_parent()._on_occupant_clicked)

	if occupant.state.is_connected("state_changed",Callable(get_parent().state,"_on_state_change")):
		occupant.state.state_changed.disconnect(Callable(get_parent().state,"_on_state_change"))
		get_parent().state.state_changed.disconnect(Callable(occupant.state,"_on_state_change"))


func _connect_occupant_signals(occupant: Node3D):
	occupant.clicked.connect(get_parent()._on_occupant_clicked)
	occupant.state.state_changed.connect(Callable(get_parent().state,"_on_state_change"))
	get_parent().state.state_changed.connect(Callable(occupant.state,"_on_state_change"))
