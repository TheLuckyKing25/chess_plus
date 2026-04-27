extends Node3D

func on_game_state_changed(game_state: int) -> void:
	match game_state:
		Match.GameState.BOARD_CUSTOMIZATION:
			%OverheadCamera.current = true
		Match.GameState.GAMEPLAY:
			if NetworkManager.is_online:
				if NetworkManager.my_player == 0:
					Match.players.white.camera_object.make_current()
				else:
					Match.players.black.camera_object.make_current()
			else:
				match Player.current:
					Match.players.white:
						Match.players.white.camera_object.make_current()
					Match.players.black:
						Match.players.black.camera_object.make_current()

func _ready() -> void:

	Match.game_state_changed.connect(Callable(self,"on_game_state_changed"))
