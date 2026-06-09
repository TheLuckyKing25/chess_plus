extends Node3D

@export var board: BoardObject:
	set(value):
		_connect_object_signals(value)
		board = value


func _connect_object_signals(board: BoardObject):
	for tile in board.tile_objects:
		pass

	for piece in board.piece_objects:
		pass


func _on_object_selected(selected_object:Node3D):
	pass


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
				Player.current.camera_object.make_current()


func _ready() -> void:
	Match.game_state_changed.connect(Callable(self,"on_game_state_changed"))
