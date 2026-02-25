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
	
	if NetworkManager.is_online:
		return
		
	if proceed or board.previous_player_turn != board.current_player_turn:
		if board.time_elapsed_since_turn_ended > 0:
			proceed = true
		if proceed and board.time_elapsed_since_turn_ended * board.TURN_TRANSITION_SPEED <= 1:
			camera_rotation += PI * board.TURN_TRANSITION_SPEED * delta * 1000
			match board.current_player_turn:
				Player.PLAYER_ONE:
					player2_camera_twist_pivot.rotation = Vector3(0,camera_rotation,0)
					if camera_rotation >= PI:
						player2_camera_twist_pivot.rotation = Vector3(0,PI,0)
						player1_camera.make_current()				
						player2_camera_twist_pivot.rotation = Vector3(0,0,0)
						if player1_camera_twist_pivot.rotation != Vector3(0,0,0):
							player1_camera_twist_pivot.rotation = Vector3(0,0,0)
						camera_rotation = 0
						proceed = false
				Player.PLAYER_TWO:
					player1_camera_twist_pivot.rotation = Vector3(0,camera_rotation,0)
					if camera_rotation >= PI:
						player1_camera_twist_pivot.rotation = Vector3(0,PI,0)
						player2_camera.make_current()		
						player1_camera_twist_pivot.rotation = Vector3(0,0,0)
						if player2_camera_twist_pivot.rotation != Vector3(0,0,0):
							player2_camera_twist_pivot.rotation = Vector3(0,0,0)
						camera_rotation = 0
						proceed = false


func _ready():
	board.promotion_requested.connect(_on_promotion_requested)
	
	if NetworkManager.is_online:
		if NetworkManager.my_player == 0:
			player1_camera.make_current()
		else:
			player2_camera.make_current()


func _on_promotion_requested(piece):
	get_tree().paused = true
	piece_to_promote = piece
	var mouse_pos = get_viewport().get_mouse_position()
	promotion_menu.position = mouse_pos
	promotion_menu.show()

func _on_queen_pressed():
	_finish_promotion(PawnPromotion.QUEEN)

func _on_knight_pressed():
	_finish_promotion(PawnPromotion.KNIGHT)

func _on_rook_pressed():
	_finish_promotion(PawnPromotion.ROOK)

func _on_bishop_pressed():
	_finish_promotion(PawnPromotion.BISHOP)

func _finish_promotion(promotion: PawnPromotion) -> void:
	get_tree().paused = false
	promotion_menu.hide()
	var piece_tile = piece_to_promote.get_parent()
	piece_to_promote = null
	board._sync_promotion.rpc(piece_tile.board_position, promotion)
