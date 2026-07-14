extends Node3D

@export var board: BoardObject


func on_game_state_changed(game_state: int) -> void:
	match game_state:
		Match.GameState.BOARD_CUSTOMIZATION:
			%OverheadCamera.current = true
		Match.GameState.GAMEPLAY:
			if NetworkManager.is_online:
				if NetworkManager.my_player == 0:
					GameData.players.white.camera_object.make_current()
				else:
					GameData.players.black.camera_object.make_current()
			else:
				var player:Player = board.player_component.player_dictionary.white
				player.camera_component.camera.make_current()



func _ready() -> void:
	Match.game_state_changed.connect(Callable(self,"on_game_state_changed"))
	Match.current_game_state = Match.GameState.GAMEPLAY
