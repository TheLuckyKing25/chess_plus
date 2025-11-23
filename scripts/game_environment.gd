extends Game

@onready var board = $"/root/gameEnvironment/Board"
@onready var base = $"/root/gameEnvironment/Board/BoardBase"

var camera_rotation: float = 0

## Sets up the next turn
func _next_turn() -> void:
	# Discover if king is still in check
	for piece in get_tree().get_nodes_in_group(player_groups[(current_player+1)%2]):
		piece.get_parent().discover_checks()
	
	# Clear previous checks
	get_tree().call_group("Tile","clear_checks")
	
	# Discover which pieces check which tiles
	for piece in get_tree().get_nodes_in_group(player_groups[current_player]):
		piece.get_parent().discover_checks()
	
	# increments the turn number and switches the board color
	turn_num += 1
	prev_player = current_player
	current_player = (current_player + 1) % 2
	
	get_tree().call_group("Tile","clear_castling_occupant")
	get_tree().call_group("Tile","clear_en_passant",current_player)
	
	%BoardBase.get_surface_override_material(0).albedo_color = COLOR_PALETTE.PLAYER_COLOR[current_player]


func _process(delta: float) -> void:
	if prev_player != current_player:
		camera_rotation += delta * user_setting.CAMERA_ROTATION_SPEED
		match current_player:
			Player.PLAYER_ONE:
				%"Twist Pivot P2".rotation = Vector3(0,camera_rotation,0)
				if camera_rotation > PI:
					%"Twist Pivot P2".rotation = Vector3(0,PI,0)
					%P1_Camera.make_current()				
					%"Twist Pivot P2".rotation = Vector3(0,0,0)
					prev_player = current_player
					camera_rotation = 0
			Player.PLAYER_TWO:
				%"Twist Pivot P1".rotation = Vector3(0,camera_rotation,0)
				if camera_rotation > PI:
					%"Twist Pivot P1".rotation = Vector3(0,PI,0)
					%P2_Camera.make_current()		
					%"Twist Pivot P1".rotation = Vector3(0,0,0)
					prev_player = current_player
					camera_rotation = 0
