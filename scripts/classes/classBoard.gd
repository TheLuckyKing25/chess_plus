class_name Board

## Node containing the tiles and pieces
static var board: Node3D


static var base: Node3D


static var all_pieces: Array[Piece] = []


static var all_tiles: Array[Tile] = []


static var players: Array[Player] = []


static var color: Color:
	set(new_color):
		color = new_color
		base.get_surface_override_material(0).albedo_color = new_color

	
