class_name TileStats
extends Resource

var is_selected:bool = false:
	set(new_state):
		is_selected = new_state
		emit_changed()

var is_movement:bool = false:
	set(new_state):
		is_movement = new_state
		emit_changed()

var is_checking:bool = false:
	set(new_state):
		is_checking = new_state
		emit_changed()

var is_special:bool = false:
	set(new_state):
		is_special = new_state
		emit_changed()

var is_threatened:bool = false:
	set(new_state):
		is_threatened = new_state
		emit_changed()

var is_checked:bool = false:
	set(new_state):
		is_checked = new_state
		emit_changed()

var is_checked_movement:bool = false:
	set(new_state):
		is_checked_movement = new_state
		emit_changed()

var modifier_order: Array[TileModifier] = []

func _init():
	resource_local_to_scene = true
