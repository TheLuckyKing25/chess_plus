class_name Rook 
extends Piece

func _init(player: Player, parent_tile: Tile, piece_object: Node3D) -> void:
	movement_direction = Global.ROOK_MOVEMENT_DIRECTIONS
	movement_distance = Global.MovementDistance.ROOK
	object_piece = piece_object
	player_parent = player
	tile_parent = parent_tile
