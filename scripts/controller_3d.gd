extends Node3D


func on_game_state_changed(game_state: int) -> void:
	match game_state:
		Match.GameState.BOARD_CUSTOMIZATION:
			%OverheadCamera.current = true
		Match.GameState.GAMEPLAY:
			if NetworkManager.is_online:
				if NetworkManager.my_player == 0:
					GameController.player.white.camera_object.make_current()
				else:
					GameController.player.black.camera_object.make_current()
			else:
				match Player.current:
					GameController.player.white:
						GameController.player.white.camera_object.make_current()
					GameController.player.black:
						GameController.player.black.camera_object.make_current()



func _ready() -> void:
	Match.game_state_changed.connect(Callable(self,"on_game_state_changed"))
