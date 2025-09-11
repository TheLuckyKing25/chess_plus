extends Node

# Sets the color of the outline for the selected piece
func _on_selected_outline_ready() -> void:
	find_child("Outline").get_surface_override_material(0).albedo_color = Global.selected_outline_color

# Sets the color of the outline for any pieces that can be captured
func _on_threatened_outline_ready() -> void:
	find_child("Outline").get_surface_override_material(0).albedo_color = Global.threatened_outline_color

# Sets the color of the pieces and board
func _on_ready() -> void:
	var player1_pieces = find_children("*_P1")
	var player2_pieces = find_children("*_P2")
	var tiles = find_children("Tile_*", "", false)
	
	# Sums the row and column numbers then sets their color based on if the sum is even or odd
	# 0 = light color, 1 = dark color
	for tile in tiles:
		match (tile.name.substr(6,1).to_int() + tile.name.substr(8,1).to_int()) % 2:
			0: tile.find_child("Mesh").get_surface_override_material(0).albedo_color = Global.light_tile_color
			1: tile.find_child("Mesh").get_surface_override_material(0).albedo_color = Global.dark_tile_color
	
	for piece in player1_pieces:
		piece.find_child("Mesh").get_surface_override_material(0).albedo_color = Global.player1_color
	for piece in player2_pieces:
		piece.find_child("Mesh").get_surface_override_material(0).albedo_color = Global.player2_color
