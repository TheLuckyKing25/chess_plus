extends Node3D

func on_game_state_changed(game_state: int) -> void:
	match game_state:
		Match.GameState.BOARD_CUSTOMIZATION:
			%OverheadCamera.current = true
		Match.GameState.GAMEPLAY:
			if NetworkManager.is_online:
				if NetworkManager.my_player == 0:
					Match.players.white.camera_camera.make_current()
				else:
					Match.players.black.camera_camera.make_current()
			else:
				match Player.current:
					Match.players.white:
						Match.players.white.camera_camera.make_current()
					Match.players.black:
						Match.players.black.camera_camera.make_current()

func _ready() -> void:
	#Match.board._game_overlay_ready.connect(Callable(self,"_on_board_game_overlay_ready"))
	Match.game_state_changed.connect(Callable(self,"on_game_state_changed"))

#func on_board_game_overlay_ready():
	#Match.board._connect_to_game_overlay_forward_camera_slider(Callable(self,"_change_camera_forward_offset"))
	#Match.board._connect_to_game_overlay_horizontal_camera_slider(Callable(self,"_change_camera_horizontal_offset"))
#
#func _change_camera_forward_offset(value:float):
	#match Player.current:
		#Match.players.white:
			#Match.players.white.camera_camera.forward_offset = value * Player.current.parity
		#Match.players.black:
			#Match.players.black.camera_camera.forward_offset = value * Player.current.parity
#
#func _change_camera_horizontal_offset(value:float):
	#match Player.current:
		#Match.players.white:
			#Match.players.white.camera_camera.horizonatal_offset = value * Player.current.parity
		#Match.players.black:
			#Match.players.black.camera_camera.horizonatal_offset = value * Player.current.parity
