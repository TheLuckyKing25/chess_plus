class_name MeshComponent
extends MeshInstance3D


@onready var main_material: StandardMaterial3D:
	get: return material_override


@onready var mouseover_material: StandardMaterial3D:
	get: return material_overlay


@onready var outline_material: StandardMaterial3D:
	get: return main_material.next_pass


func show_mouse_hover() -> void:
	mouseover_material.albedo_color = main_material.albedo_color * 1.25


func hide_mouse_hover() -> void:
	mouseover_material.albedo_color = Color(0,0,0,0)


func set_main_color(color: Color) -> void:
	main_material.albedo_color = color


func set_outline_color(color: Color) -> void:
	outline_material.albedo_color = color
