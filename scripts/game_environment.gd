extends Node3D


func _ready() -> void:
	Global.players.append(Player.new(1,Global.player_color[0]))
	Global.players.append(Player.new(2,Global.player_color[1]))
	var board_path = $"/root/Node3D/Board"
	var board_base_path = $"/root/Node3D/Board/BoardBase"
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
			match child.name.get_slice("_", 0):
				"Pawn": 
					tile.occupant = Pawn.new(tile, child)
				"Rook": 
					tile.occupant = Rook.new(tile, child)
				"Bishop": 
					tile.occupant = Bishop.new(tile, child)
				"Knight": 
					tile.occupant = Knight.new(tile, child)
				"Queen": 
					tile.occupant = Queen.new(tile, child)
				"King": 
					tile.occupant = King.new(tile, child)
			tile.occupant.outline.visible = false
			tile.occupant.outline.material_override.grow_amount = (
					Global.setting_piece_outline_thickness
			)
			var occupant_piece = tile.occupant.object_piece
			match occupant_piece.name.get_slice("_", 1):
				"P1": 
					Global.players[0].add_piece(tile.occupant)
				"P2": 
					occupant_piece.find_child("Collision*").disabled = true
					Global.players[1].add_piece(tile.occupant)
					
	for player in Global.players:
		Global.pieces += player.pieces
		player.color_pieces()

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
