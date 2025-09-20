class_name Rook 
extends Piece

var moved: bool = false

func _init(piece_tile: Tile, piece_object: Node3D):
	tile = piece_tile
	object = piece_object
	movement_direction = [
		Vector2(1,0), 
		Vector2(0,1), 
		Vector2(-1,0), 
		Vector2(0,-1)
		]
	movement_distance = 8
