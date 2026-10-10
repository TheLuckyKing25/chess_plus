class_name OccupantComponent
extends Node


#signal occupant_changed(new_occupant: InteractableGameObject)
signal occupant_clicked(clicked_occupant: InteractableGameObject)


@export var occupant: InteractableGameObject = null if get_children().size() == 0 else get_child(0):
	set = _occupant_setter,
	get = _occupant_getter


func _occupant_setter(value: InteractableGameObject) -> void:
	if is_instance_valid(value):
		get_parent().add_to_group(Constants.Groups.IS_OCCUPIED)
	else:
		get_parent().remove_from_group(Constants.Groups.IS_OCCUPIED)
	occupant = value


func _occupant_getter() -> InteractableGameObject:
	return null if not is_instance_valid(occupant) else occupant


func _on_occupant_clicked(object:InteractableGameObject) -> void:
	occupant_clicked.emit(object)


func disconnect_occupant_signals(connected_occupant: InteractableGameObject) -> void:
	Debug.Printer.print_signal_connection_log(1,"clicked",connected_occupant,owner,1)
	if connected_occupant.has_signal("clicked") and connected_occupant.is_connected("clicked",_on_occupant_clicked):
		connected_occupant.clicked.disconnect(_on_occupant_clicked)


func connect_occupant_signals(unconnected_occupant: InteractableGameObject) -> void:
	Debug.Printer.print_signal_connection_log(0,"clicked",unconnected_occupant,owner,1)
	if unconnected_occupant.has_signal("clicked") and not unconnected_occupant.clicked.is_connected(_on_occupant_clicked):
		unconnected_occupant.clicked.connect(_on_occupant_clicked)
