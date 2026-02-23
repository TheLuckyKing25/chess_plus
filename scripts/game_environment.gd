extends GameNode3D

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
	if proceed or Player.previous != Player.current:
		if board.time_elapsed_since_turn_ended > 0:
			proceed = true
		if proceed and board.time_elapsed_since_turn_ended * board.TURN_TRANSITION_SPEED <= 1:
			camera_rotation += PI * board.TURN_TRANSITION_SPEED * delta * 1000
			match Player.current:
				board.player_one:
					player2_camera_twist_pivot.rotation = Vector3(0,camera_rotation,0)
					if camera_rotation >= PI:
						player2_camera_twist_pivot.rotation = Vector3(0,PI,0)
						player1_camera.make_current()				
						player2_camera_twist_pivot.rotation = Vector3(0,0,0)
						if player1_camera_twist_pivot.rotation != Vector3(0,0,0):
							player1_camera_twist_pivot.rotation = Vector3(0,0,0)
						camera_rotation = 0
						proceed = false
				board.player_two:
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
		GameState.BoardCustomization:
			$OverheadCamera.current = true
		GameState.Gameplay:
			match Player.current:
				board.player_one:
					player1_camera.current = true
				board.player_two:
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
