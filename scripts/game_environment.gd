extends GameNode3D

@onready var board = %"Board"
@onready var base = %"BoardBase"
@onready var player1_camera = %"P1_Camera"
@onready var player2_camera = %"P2_Camera"
@onready var player1_camera_twist_pivot = %"Twist Pivot P1"
@onready var player2_camera_twist_pivot = %"Twist Pivot P2"
@onready var promotion_menu = $CanvasLayer/PromoteMenu

const CAMERA_ROTATION_DELAY_MSEC:int = 500
var time_turn_ended:int = 0
var camera_rotation: float = 0
var piece_to_promote = null

## Sets up the next turn
func _next_turn() -> void:
	# Discover if king is still in check
	for piece in get_tree().get_nodes_in_group(player_groups[(current_player+1)%2]):
		piece.get_parent().discover_checks()
	
	# Clear previous checks
	get_tree().call_group("Tile","_clear_checks")
	
	# Discover which pieces check which tiles
	for piece in get_tree().get_nodes_in_group(player_groups[current_player]):
		piece.get_parent().discover_checks()
	
	# increments the turn number
	turn_num += 1
	prev_player = current_player
	current_player = ((current_player + 1) % 2 ) as Player
	
	get_tree().call_group("Tile","_clear_castling_occupant")
	get_tree().call_group("Tile","_clear_en_passant",current_player)


func _process(delta: float) -> void:
	if prev_player != current_player:
		if time_turn_ended == 0:
			time_turn_ended = Time.get_ticks_msec()
		if (Time.get_ticks_msec() - time_turn_ended) >= CAMERA_ROTATION_DELAY_MSEC:
			camera_rotation += delta * user_setting.CAMERA_ROTATION_SPEED
			match current_player:
				Player.PLAYER_ONE:
					player2_camera_twist_pivot.rotation = Vector3(0,camera_rotation,0)
					base.get_surface_override_material(0).albedo_color = COLOR_PALETTE.PLAYER_COLOR[prev_player].lerp(COLOR_PALETTE.PLAYER_COLOR[current_player],camera_rotation/PI)
					if camera_rotation > PI:
						player2_camera_twist_pivot.rotation = Vector3(0,PI,0)
						player1_camera.make_current()				
						player2_camera_twist_pivot.rotation = Vector3(0,0,0)
						prev_player = current_player
						camera_rotation = 0
						time_turn_ended = 0
						base.get_surface_override_material(0).albedo_color = COLOR_PALETTE.PLAYER_COLOR[current_player]
				Player.PLAYER_TWO:
					player1_camera_twist_pivot.rotation = Vector3(0,camera_rotation,0)
					base.get_surface_override_material(0).albedo_color = COLOR_PALETTE.PLAYER_COLOR[prev_player].lerp(COLOR_PALETTE.PLAYER_COLOR[current_player],camera_rotation/PI)
					if camera_rotation > PI:
						player1_camera_twist_pivot.rotation = Vector3(0,PI,0)
						player2_camera.make_current()		
						player1_camera_twist_pivot.rotation = Vector3(0,0,0)
						prev_player = current_player
						camera_rotation = 0
						time_turn_ended = 0
						base.get_surface_override_material(0).albedo_color = COLOR_PALETTE.PLAYER_COLOR[current_player]


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
	board.promote(piece_to_promote, PawnPromotion.QUEEN)
	piece_to_promote = null
	promotion_menu.hide()

func _on_knight_pressed():
	get_tree().paused = false
	board.promote(piece_to_promote, PawnPromotion.KNIGHT)
	piece_to_promote = null
	promotion_menu.hide()
	
func _on_rook_pressed():
	get_tree().paused = false
	board.promote(piece_to_promote, PawnPromotion.ROOK)
	piece_to_promote = null
	promotion_menu.hide()

func _on_bishop_pressed():
	get_tree().paused = false
	board.promote(piece_to_promote, PawnPromotion.BISHOP)
	piece_to_promote = null
	promotion_menu.hide()
