extends Control

func _ready() -> void:
	if NetworkManager.is_online and NetworkManager.my_player == 1:
		position = Vector2(-1, -1) * $GameOverlay.position

func _on_gamemode_selection_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/StartScreen.tscn")


func _on_gamemode_selection_continue_button_pressed() -> void:
	position = Vector2(-1,-1) * $TileModifierScreen.position


func _on_tile_modifier_screen_back_button_pressed() -> void:
	position = Vector2(-1,-1) * $GamemodeSelection.position


func _on_tile_modifier_screen_continue_button_pressed() -> void:
	position = Vector2(-1,-1) * $GameOverlay.position
