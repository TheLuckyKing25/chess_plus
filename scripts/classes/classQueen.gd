class_name Queen 
extends Piece

func _init(player: Player, parent_tile: Tile, piece_object: Node3D) -> void:
	movement_direction = Global.QUEEN_MOVEMENT_DIRECTIONS
	movement_distance = 8
	object_piece = piece_object
	player_parent = player
	tile_parent = parent_tile
