# WIP
# Need to change how mouse hovering appears
class_name InputComponent
extends Node

var is_moused_over:bool

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("Select") and is_moused_over:
		#selected.emit()


#func _on_mouse_entered() -> void:
	#is_moused_over = true
	#mouseover_material.render_priority = 2
	#mouseover_material.albedo_color = piece_material.albedo_color * 1.5


#func _on_mouse_exited() -> void:
	#mouseover_material.albedo_color = Color(0,0,0,0)
	#mouseover_material.render_priority = 0
	#is_moused_over = false
