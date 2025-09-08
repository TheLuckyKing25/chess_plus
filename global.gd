# Script contains global variables which can be accessed and changed from any other script.
extends Node

var is_piece_selected = true
# sets the variables to the objects selected, allowing them to be addressed in other scripts.
var piece_selected = null
var tile_selected = null
	
func _process(delta: float) -> void:
	# Moves the selected piece the the selected tile by setting the piece's XZ coordinates to 
	# the tile's XZ coordinates while keeping the piece's Y coordinate.  
	if piece_selected != null and tile_selected != null:
		if tile_selected.get_child_count() == 2:
			piece_selected.reparent(tile_selected)
			piece_selected.global_position = tile_selected.global_position * Vector3(1,0,1) + piece_selected.global_position * Vector3(0,1,0)
			piece_selected = null
			tile_selected = null
		
		
