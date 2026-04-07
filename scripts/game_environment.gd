extends Node3D

@onready var player_one_camera = $CameraWhite
@onready var player_two_camera = $CameraBlack

var camera_rotation: float = 0
var can_proceed = false

func _on_board_game_state_changed(game_state: int) -> void:
	match game_state:
		BoardObject.GameState.BoardCustomization:
			$OverheadCamera.current = true
		BoardObject.GameState.Gameplay:
			if NetworkManager.is_online:
				if NetworkManager.my_player == 0:
					player_one_camera.make_current()
				else:
					player_two_camera.make_current()
			else:
				match Player.current:
					Match.player_one:
						player_one_camera.make_current()
					Match.player_two:
						player_two_camera.make_current()

func _ready() -> void:
	Match.board_object._game_overlay_ready.connect(Callable(self,"_on_board_game_overlay_ready"))

func _on_board_game_overlay_ready():
	Match.board_object._connect_to_game_overlay_forward_camera_slider(Callable(self,"_change_camera_forward_offset"))
	Match.board_object._connect_to_game_overlay_horizontal_camera_slider(Callable(self,"_change_camera_horizontal_offset"))

func _change_camera_forward_offset(value:float):
	match Player.current:
		Match.player_one:
			player_one_camera.forward_offset = value * Player.current.parity
		Match.player_two:
			player_two_camera.forward_offset = value * Player.current.parity

func _change_camera_horizontal_offset(value:float):
	match Player.current:
		Match.player_one:
			player_one_camera.horizonatal_offset = value * Player.current.parity
		Match.player_two:
			player_two_camera.horizonatal_offset = value * Player.current.parity
