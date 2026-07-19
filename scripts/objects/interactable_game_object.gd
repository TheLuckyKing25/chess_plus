@abstract
class_name InteractableGameObject
extends Node3D

signal clicked(piece: InteractableGameObject)

@export var collision_component: CollisionComponent
@export var mesh_component: MeshComponent
@export var state: ObjectStateComponent


@abstract func select_object()


func _ready() -> void:
	collision_component.object_clicked.connect(_on_clicked)
	collision_component.mouse_entered.connect(Callable(mesh_component,"show_mouse_hover"))
	collision_component.mouse_exited.connect(Callable(mesh_component,"hide_mouse_hover"))
	state.current = ObjectStateComponent.STATE_NONE


func _on_clicked(object: InteractableGameObject):
	clicked.emit(self)
	if not clicked.has_connections():
		select_object()
