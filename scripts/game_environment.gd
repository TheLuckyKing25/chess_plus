extends Node3D


func _ready() -> void:
	Global.create_players()
	
	var board_path = $"/root/gameEnvironment/Board"
	var board_base_path = $"/root/gameEnvironment/Board/BoardBase"
	Global.board = Board.new(board_path,board_base_path)
	
	for tile_node in board_path.find_children("Tile_*","",false):
		var tile_row = tile_node.name.substr(6,1).to_int()
		var tile_column = tile_node.name.substr(8,1).to_int()
		Global.tiles.append(Tile.new(
						Vector2i(tile_row,tile_column),
						tile_node))
						
	for tile in Global.tiles: 
		var child = tile.object_tile.find_child("*_P*",false)
		if child:
			var player
			match child.name.get_slice("_", 1):
				"P1": 
					player = Global.players[0]
				"P2": 
					player = Global.players[1]
					
			match child.name.get_slice("_", 0):
				"Pawn": 
					tile.occupant = Pawn.new(player, tile, child)
					player.pawns.append(tile.occupant)
				"Rook": 
					tile.occupant = Rook.new(player, tile, child)
					player.rooks.append(tile.occupant)
				"Bishop": 
					tile.occupant = Bishop.new(player, tile, child)
					player.bishops.append(tile.occupant)
				"Knight": 
					tile.occupant = Knight.new(player, tile, child)
					player.knights.append(tile.occupant)
				"Queen": 
					tile.occupant = Queen.new(player, tile, child)
					player.queens.append(tile.occupant)
				"King": 
					tile.occupant = King.new(player, tile, child)
					player.king = tile.occupant
			tile.occupant.outline_object.visible = false
			tile.occupant.outline_object.material_override.grow_amount = (
					Global.setting[Global.PIECE_OUTLINE_THICKNESS]
			)
					
	for player in Global.players:
		Global.pieces.append_array(player.pieces)
		player.king.calculate_complete_moveset()
		player.king.generate_valid_moveset()

	for piece in Global.pieces:
		if piece is King:
			continue
		piece.calculate_complete_moveset()
		piece.generate_valid_moveset()
	
	for player in Global.players:
		player.compile_threatened_tiles()
	
	Global.current_player = Global.players[Global.player_turn]
		
func _process(delta: float) -> void:
	if (
			Global.selected_piece 
			and Global.selected_tile 
			and Global.selected_tile.is_valid_move(Global.selected_piece, Global.current_player)
	):
		Global.print_move()
		
		Global.move_piece(Global.selected_piece, Global.selected_tile)
