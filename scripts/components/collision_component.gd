class_name CollisionComponent
extends Area3D

signal object_clicked(object:Node3D)


var _is_mouse_on_object:bool = false


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	_is_mouse_on_object = true


func _on_mouse_exited() -> void:
	_is_mouse_on_object = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Select") and _is_mouse_on_object:
		object_clicked.emit(get_parent())
