@tool
extends Control

signal up_pressed()
signal down_pressed()
signal remove_pressed()
signal modifier_pressed()

@export_custom(PROPERTY_HINT_PLACEHOLDER_TEXT,"ButtonName") var text: String:
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
	up_pressed.emit()


func _on_move_down_button_pressed() -> void:
	down_pressed.emit()
