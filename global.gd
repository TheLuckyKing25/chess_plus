# Script contains global variables which can be accessed and changed from any other script.
extends Node

var player1_color = Color(0.9,0.9,0.9) #White
var player2_color = Color(0.1,0.1,0.1) #Black

var light_tile_color = Color(1,0.77,0.58) #White
var dark_tile_color = Color(0.23,0.16,0.07) #Black

var selected_outline_color = Color(0,0.9,0.9) #Cyan
var threatened_outline_color = Color(0.9,0,0) #Red


var is_piece_selected = true
# sets the variables to the objects selected, allowing them to be addressed in other scripts.
var piece_selected = null
var tile_selected = null
	
func _process(delta: float) -> void:
	# Moves the selected piece the the selected tile by setting the piece's XZ coordinates to 
	# the tile's XZ coordinates while keeping the piece's Y coordinate.  
	if piece_selected != null and tile_selected != null:
		if len(tile_selected.find_children("","",false)) == 0:
			print(piece_selected.name + " moves from " + piece_selected.get_parent().name + " to " + tile_selected.name)
			piece_selected.reparent(tile_selected)
			piece_selected.global_position = tile_selected.global_position * Vector3(1,0,1) + piece_selected.global_position * Vector3(0,1,0)
			piece_selected = null
			tile_selected = null
		
		
