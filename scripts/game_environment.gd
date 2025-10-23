extends Node3D


func _ready() -> void:
	
	Board.board = $"/root/gameEnvironment/Board"
	Board.base = $"/root/gameEnvironment/Board/BoardBase"
	Global.create_players()
	
	for tile_node in Board.board.find_children("Tile_*","",false):
		var tile_row = tile_node.name.substr(6,1).to_int()
		var tile_column = tile_node.name.substr(8,1).to_int()
		var tile_position = Vector2i(tile_row,tile_column)
		Board.all_tiles.append(Tile.new(tile_position,tile_node))
	
	
	for tile in Board.all_tiles: 
		var child: Node3D = tile.object_tile.find_child("*_P*",false)
		if child:
			var player: Player
			match child.name.get_slice("_", 1):
				"P1": 
					player = Board.players[0]
				"P2": 
					player = Board.players[1]
					
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
					Game.Settings.options[Game.Settings.PIECE_OUTLINE_THICKNESS]
			)

	for player in Board.players:
		Board.all_pieces.append_array(player.pieces)

	for piece in Board.all_pieces:
		piece.calculate_complete_moveset()

	for piece in Board.all_pieces:
		piece.generate_valid_moveset()
	
	for player in Board.players:
		player.compile_threatened_tiles()
	
	Player.current = Board.players[Player.turn_num]
		

func _process(delta: float) -> void:
	if (
			Piece.selected 
			and Tile.selected 
			and Tile.selected.is_valid_move(Piece.selected, Player.current)
	):
		Global.print_move()
		
		Piece.selected.move_to(Tile.selected)
