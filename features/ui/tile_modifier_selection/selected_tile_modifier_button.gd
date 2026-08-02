@tool
extends Control

signal up_pressed(index:int)
signal down_pressed(index:int)
signal remove_pressed()
signal modifier_pressed()

# modifier that is associated with this button
var associated_modifier: TileModifier:
	set(new_modifier):
		new_modifier.create_dropdown_ui()
		if new_modifier.dropdown_ui:
			%DropdownOptions.add_child(new_modifier.dropdown_ui)
		associated_modifier = new_modifier


var index: int = 0:
	set(new_index):
		if new_index == 0:
			%MoveUpButton.disabled = true
		else:
			%MoveUpButton.disabled = false
		index = new_index


var text: String:
	set(name):
		$BoxContainer/ModifierButton.text = name
		text = name


func _on_modifier_button_toggled(toggled_on: bool) -> void:
	modifier_pressed.emit()
	%DropdownOptions.visible = toggled_on


func _on_remove_button_pressed() -> void:
	remove_pressed.emit()
	queue_free()


func _on_move_up_button_pressed() -> void:
	up_pressed.emit(index)


func _on_move_down_button_pressed() -> void:
	down_pressed.emit(index)
