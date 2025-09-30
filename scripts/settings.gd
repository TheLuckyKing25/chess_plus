extends Control

func _ready():
	hide()

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		hide()
