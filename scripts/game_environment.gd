extends Node3D

var piece_to_promote = null

func _ready() -> void:
	
	Board.all_tiles.clear()
	Board.all_pieces.clear()
	Player.turn_num = 0
	Board.players.clear()
	Board.board = $"/root/gameEnvironment/Board"
	Board.base = $"/root/gameEnvironment/Board/BoardBase"
	Global.create_players()
	
	for tile_node in Board.board.find_children("Tile_*","",false):
		var tile_row = tile_node.name.substr(6,1).to_int()
		var tile_column = tile_node.name.substr(8,1).to_int()
		var tile_position = Vector2i(tile_row,tile_column)
		Board.all_tiles.append(Tile.new(tile_position,tile_node))

	
	for tile in Board.all_tiles: 
		var piece: Node3D = tile.object_tile.find_child("*_P*",false)
		if piece:
			var player: Player
			match piece.name.get_slice("_", 1):
				"P1": 
					player = Board.players[0]
				"P2": 
					player = Board.players[1]
					
			Board.create_new_piece(player, tile, piece)


	for player in Board.players:
		Board.all_pieces.append_array(player.pieces)

	for piece in Board.all_pieces:
		piece.calculate_complete_moveset()

	for piece in Board.all_pieces:
		piece.generate_valid_moveset()
	
	for player in Board.players:
		player.compile_threatened_tiles()
	
	Player.current = Board.players[Player.turn_num]
	
	for piece in Board.all_pieces:
		piece.promotion_requested.connect(_on_piece_promotion_requested)

func _process(delta: float) -> void:
	if (
			Piece.selected 
			and Tile.selected 
			and Tile.selected.is_valid_move(Piece.selected, Player.current)
	):
		Global.print_move()
		
		Piece.selected.move_to(Tile.selected)
		
		
func _on_piece_promotion_requested(piece):
	get_tree().paused = true
	piece_to_promote = piece
	var mouse_pos = get_viewport().get_mouse_position()
	$CanvasLayer/PromoteMenu.position = mouse_pos
	$CanvasLayer/PromoteMenu.show()
	

func _on_queen_pressed():
	get_tree().paused = false
	piece_to_promote.promote_to("Queen")
	piece_to_promote = null
	$CanvasLayer/PromoteMenu.hide()

func _on_knight_pressed():
	get_tree().paused = false
	piece_to_promote.promote_to("Knight")
	piece_to_promote = null
	$CanvasLayer/PromoteMenu.hide()
	
func _on_rook_pressed():
	get_tree().paused = false
	piece_to_promote.promote_to("Rook")
	piece_to_promote = null
	$CanvasLayer/PromoteMenu.hide()

func _on_bishop_pressed():
	get_tree().paused = false
	piece_to_promote.promote_to("Bishop")
	piece_to_promote = null
	$CanvasLayer/PromoteMenu.hide()
