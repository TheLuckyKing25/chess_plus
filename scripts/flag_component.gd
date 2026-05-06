class_name FlagComponent
extends Resource

var enabled:bool = false:
	set(new_state):
		enabled = new_state
		emit_changed()
