class_name Board

## Node containing the tiles and pieces
static var board: Node3D


static var base: Node3D


static var all_pieces: Array[Piece]:
	get:
		var pieces: Array[Piece]
		for player in players:
			pieces.append_array(player.pieces)
		return pieces


static var all_tiles: Array[Tile] = []


static var players: Array[Player] = []


static var color: Color:
	set(new_color):
		color = new_color
		base.get_surface_override_material(0).albedo_color = new_color
	

static func create_new_piece(player: Player, tile: Tile, piece: Node3D):
	match piece.name.get_slice("_", 0).to_lower():
		"pawn": 
			tile.occupant = Pawn.new(player, tile, piece)
			player.pawns.append(tile.occupant)
		"rook": 
			tile.occupant = Rook.new(player, tile, piece)
			player.rooks.append(tile.occupant)
		"bishop": 
			tile.occupant = Bishop.new(player, tile, piece)
			player.bishops.append(tile.occupant)
		"knight": 
			tile.occupant = Knight.new(player, tile, piece)
			player.knights.append(tile.occupant)
		"queen": 
			tile.occupant = Queen.new(player, tile, piece)
			player.queens.append(tile.occupant)
		"king": 
			tile.occupant = King.new(player, tile, piece)
			player.king = tile.occupant
	tile.occupant.outline_object.visible = false
	tile.occupant.outline_object.material_override.grow_amount = (
			Game.Settings.options[Game.Settings.PIECE_OUTLINE_THICKNESS]
	)
