extends Node3D


func _ready() -> void:
	Global.players.append(Player.new(1,Global.PLAYER_COLOR[0]))
	Global.players.append(Player.new(2,Global.PLAYER_COLOR[1]))
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
				"Rook": 
					tile.occupant = Rook.new(player, tile, child)
				"Bishop": 
					tile.occupant = Bishop.new(player, tile, child)
				"Knight": 
					tile.occupant = Knight.new(player, tile, child)
				"Queen": 
					tile.occupant = Queen.new(player, tile, child)
				"King": 
					tile.occupant = King.new(player, tile, child)
					player.king = tile.occupant
			tile.occupant.outline.visible = false
			tile.occupant.outline.material_override.grow_amount = (
					Global.setting_piece_outline_thickness
			)
			player.add_piece(tile.occupant)
					
	for player in Global.players:
		Global.pieces += player.pieces
		player.color_pieces()
		player.king.calculate_all_movements()
		player.king.validate_movements()

	for piece in Global.pieces:
		if piece is King:
			continue
		piece.calculate_all_movements()
		piece.validate_movements()
		
func _process(delta: float) -> void:
	if (
			Global.selected_piece 
			and Global.selected_tile 
			and Global.is_valid_move()
	):
		print(
			"%10s" % Global.selected_piece.object_piece.name 
			+ " moves from " 
			+ Global.selected_piece.tile_parent.object_tile.name 
			+ " to " 
			+ Global.selected_tile.object_tile.name
		)
		Global.move_piece(Global.selected_piece, Global.selected_tile)
