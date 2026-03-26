extends Node3D

@onready var board = %"Board"
@onready var player1_camera_twist_pivot = %"Twist Pivot P1"
@onready var player2_camera_twist_pivot = %"Twist Pivot P2"
@onready var player1_camera = %"P1_Camera"
@onready var player2_camera = %"P2_Camera"
@onready var promotion_menu = $CanvasLayer/PromoteMenu

var camera_rotation: float = 0
var piece_to_promote = null
var proceed = false

func _process(delta: float):
	if NetworkManager.is_online:
		return
	if proceed or Player.previous != Player.current:
		if board._time_elapsed_since_turn_ended > 0:
			proceed = true
		if proceed and board._time_elapsed_since_turn_ended * BoardData.TURN_TRANSITION_SPEED <= 1:
			camera_rotation += PI * BoardData.TURN_TRANSITION_SPEED * delta * 1000
			match Player.current:
				board.data.player_one:
					player2_camera_twist_pivot.rotation = Vector3(0,camera_rotation,0)
					if camera_rotation >= PI:
						player2_camera_twist_pivot.rotation = Vector3(0,PI,0)
						player1_camera.make_current()
						player2_camera_twist_pivot.rotation = Vector3(0,0,0)
						if player1_camera_twist_pivot.rotation != Vector3(0,0,0):
							player1_camera_twist_pivot.rotation = Vector3(0,0,0)
						camera_rotation = 0
						proceed = false
				board.data.player_two:
					player1_camera_twist_pivot.rotation = Vector3(0,camera_rotation,0)
					if camera_rotation >= PI:
						player1_camera_twist_pivot.rotation = Vector3(0,PI,0)
						player2_camera.make_current()
						player1_camera_twist_pivot.rotation = Vector3(0,0,0)
						if player2_camera_twist_pivot.rotation != Vector3(0,0,0):
							player2_camera_twist_pivot.rotation = Vector3(0,0,0)
						camera_rotation = 0
						proceed = false

func _on_board_game_state_changed(game_state: int) -> void:
	match game_state:
		BoardObject.GameState.BoardCustomization:
			$OverheadCamera.current = true
		BoardObject.GameState.Gameplay:
			if NetworkManager.is_online:
				if NetworkManager.my_player == 0:
					player1_camera.current = true
				else:
					player2_camera.current = true
			else:
				match Player.current:
					board.data.player_one:
						player1_camera.current = true
					board.data.player_two:
						player2_camera.current = true

func _ready():
	board.promotion_requested.connect(_on_promotion_requested)


func _on_promotion_requested(piece):
	get_tree().paused = true
	piece_to_promote = piece
	var mouse_pos = get_viewport().get_mouse_position()
	promotion_menu.position = mouse_pos
	promotion_menu.show()


func _on_queen_pressed():
	get_tree().paused = false
	#board.promote(piece_to_promote, PawnPromotion.QUEEN)
	piece_to_promote = null
	promotion_menu.hide()

func _on_knight_pressed():
	get_tree().paused = false
	#board.promote(piece_to_promote, PawnPromotion.KNIGHT)
	piece_to_promote = null
	promotion_menu.hide()

func _on_rook_pressed():
	get_tree().paused = false
	#board.promote(piece_to_promote, PawnPromotion.ROOK)
	piece_to_promote = null
	promotion_menu.hide()

func _on_bishop_pressed():
	get_tree().paused = false
	#board.promote(piece_to_promote, PawnPromotion.BISHOP)
	piece_to_promote = null
	promotion_menu.hide()
