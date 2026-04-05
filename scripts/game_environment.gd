extends Node3D

@onready var board = %"Board"
@onready var player1_camera = $"CameraWhite"
@onready var player2_camera = $"CameraBlack"

var camera_rotation: float = 0
var can_proceed = false

func _process(delta: float):
	if NetworkManager.is_online:
		return
	if can_proceed or Player.previous != Player.current:
		if board._time_elapsed_since_turn_ended > 0:
			can_proceed = true
		if can_proceed and board._time_elapsed_since_turn_ended * BoardData.TURN_TRANSITION_SPEED <= 1:
			camera_rotation += 180 * BoardData.TURN_TRANSITION_SPEED * delta * 1000
			match Player.current:
				board.data.player_one:
					player2_camera.yaw = camera_rotation + 180
					if camera_rotation >= 180:
						player2_camera.yaw = 180
						player1_camera.make_current()
						if player2_camera.yaw != 180:
							player2_camera.yaw = 180
						camera_rotation = 0
						can_proceed = false
				board.data.player_two:
					player1_camera.yaw = camera_rotation
					if camera_rotation >= 180:
						player1_camera.yaw = 180
						player2_camera.make_current()
						if player1_camera.yaw != 0:
							player1_camera.yaw = 0
						camera_rotation = 0
						can_proceed = false



func _on_board_game_state_changed(game_state: int) -> void:
	match game_state:
		BoardObject.GameState.BoardCustomization:
			$OverheadCamera.current = true
		BoardObject.GameState.Gameplay:
			if NetworkManager.is_online:
				if NetworkManager.my_player == 0:
					player1_camera.make_current()
				else:
					player2_camera.make_current()
			else:
				match Player.current:
					board.data.player_one:
						player1_camera.make_current()
					board.data.player_two:
						player2_camera.make_current()

func _on_ready() -> void:
	board._game_overlay_ready.connect(Callable(self,"_on_board_game_overlay_ready"))

func _on_board_game_overlay_ready():
	board._connect_to_game_overlay_forward_camera_slider(Callable(self,"_change_camera_forward_offset"))
	board._connect_to_game_overlay_horizontal_camera_slider(Callable(self,"_change_camera_horizontal_offset"))

func _change_camera_forward_offset(value:float):
	match Player.current:
		board.data.player_one:
			player1_camera.forward_offset = value * Player.current.parity
		board.data.player_two:
			player2_camera.forward_offset = value * Player.current.parity

func _change_camera_horizontal_offset(value:float):
	match Player.current:
		board.data.player_one:
			player1_camera.horizonatal_offset = value * Player.current.parity
		board.data.player_two:
			player2_camera.horizonatal_offset = value * Player.current.parity
