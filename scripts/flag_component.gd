class_name FlagComponent
extends Resource

@export var color:Color

var enabled:bool = false:
	set(new_state):
		enabled = new_state
		emit_changed()
