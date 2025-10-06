class_name Knight 
extends Piece

func _init(player: Player, parent_tile: Tile, piece_object: Node3D):
	movement_direction = Global.KNIGHT_MOVEMENT_DIRECTIONS
	movement_distance = 1
	object_piece = piece_object
	player_parent = player
	tile_parent = parent_tile
