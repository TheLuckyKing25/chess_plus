extends Control


var ip:   String = ""
var port: String = ""

const LOADING_SCREEN = preload("res://scenes/menu/loading_screen.tscn")

func _on_ip_line_text_changed(updated_ip: String) -> void:
	ip = updated_ip.strip_edges()

func _on_port_line_text_changed(updated_port: String) -> void:
	port = updated_port.to_upper().strip_edges()

func _on_join__game_button_pressed() -> void:
	if ip.is_empty() or port.length() < 4:
		return

	NetworkManager.connected_to_game.connect(_on_connected_to_game)
	NetworkManager.join_game(ip, port)

func _on_connected_to_game() -> void:
	get_tree().change_scene_to_file("res://scenes/game_environment.tscn")
