class_name Pawn 
extends Piece

func _init(player: Player, parent_tile: Tile, piece_object: Node3D):
	movement_direction = Global.PAWN_MOVEMENT_DIRECTIONS
	movement_distance = Global.MovementDistance.PAWN_INITIAL
	object_piece = piece_object
	player_parent = player
	tile_parent = parent_tile
