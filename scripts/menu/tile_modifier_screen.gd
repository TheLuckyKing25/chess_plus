extends Control

signal back_button_pressed()
signal continue_button_pressed()

func _on_continue_pressed() -> void:
	continue_button_pressed.emit()


func _on_back_button_pressed() -> void:
	back_button_pressed.emit()
