extends Control

signal continue_button_pressed()

var ip:   String = ""
var port: String = ""


func _ready():
	if GameNode3D.debug_setting.DEBUG_SKIP_TITLE:
		get_tree().change_scene_to_file("res://scenes/gameEnvironment.tscn")
	NetworkManager.connected_to_game.connect(_on_connected_to_game)

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		$ScreenController.position = Vector2(0,0)


func _on_settings_pressed():
	$ScreenController/SettingsScreen/Settings.show()
	$ScreenController.position = Vector2(-1,-1) * $ScreenController/SettingsScreen.position

func _on_exit_pressed():
	get_tree().quit()

func _on_new_match_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gameEnvironment.tscn")

func _on_join_pressed() -> void:
	$ScreenController.position = Vector2(-2,-2) * $ScreenController/SettingsScreen.position
	#NetworkManager.join_game("127.0.0.1", "PUOA")

func _on_connected_to_game():
	print("Both players connected")
	get_tree().change_scene_to_file("res://scenes/gameEnvironment.tscn")

func _on_ip_line_text_changed(updated_ip: String) -> void:
	ip = updated_ip.strip_edges()

func _on_port_line_text_changed(updated_port: String) -> void:
	port = updated_port.to_upper().strip_edges()

func _on_join__game_button_pressed() -> void:
	if ip.is_empty() or port.length() < 4:
		return
		
	NetworkManager.join_game(ip, port)
