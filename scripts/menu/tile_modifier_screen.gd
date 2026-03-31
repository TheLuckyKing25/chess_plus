extends Control

signal back_button_pressed()
signal continue_button_pressed()

func _ready():
	print("scene ready, connecting signal")
	NetworkManager.game_hosted.connect(_on_game_hosted)

func _on_game_hosted(ip: String,code: String) -> void:
	print("signal received: ", code)
	$ReferenceRect/BoxContainer/ScreenNavigationMenu/BoxContainer/HostCodeBackgroundPanel/Panel/MarginContainer/HostCodeLabel.text = "Code: %s\nIP: %s" % [code, ip]


func _on_continue_pressed() -> void:
	continue_button_pressed.emit()


func _on_back_button_pressed() -> void:
	back_button_pressed.emit()
