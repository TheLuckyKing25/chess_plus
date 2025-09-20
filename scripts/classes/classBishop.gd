class_name Bishop 
extends Piece

func _init(piece_tile: Tile, piece_object: Node3D):
	tile = piece_tile
	object = piece_object
	movement_direction = [
		Vector2(1,1), 
		Vector2(-1,1), 
		Vector2(1,-1), 
		Vector2(-1,-1)
		]
	movement_distance = 8
