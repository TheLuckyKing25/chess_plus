class_name Board
extends Node

var restrict_movement: bool = false

var object: Node3D

var tile_base_color_light: Color = Color(1.0, 0.77, 0.58)
var tile_base_color_dark: Color = Color(1.0, 0.77, 0.58).darkened(0.5)
var tile_highlight_color: Color = Color(0.25, 0.75, 0.25)
var tile_threatened_color: Color = Color(0.75, 0.25, 0.25)
var tile_special_color: Color = Color(1, 1, 1) #Castling, promotion, en pesant

var piece_outline_threatened_color: Color = Color(0.9, 0, 0)
var piece_outline_selected_color: Color = Color(0, 0.9, 0.9)

var board_size: Vector2 = Vector2(8,8)
var tiles: Array[Tile] = []
var pieces: Array[Piece] = []

var player_colors: Array[Color] = [
	Color(0.9, 0.9, 0.9), 
	Color(0.1, 0.1, 0.1)
]

var players: Array[Player] = []
var player_turn: int = 0

var selected_tile: Tile = null
var selected_piece: Piece = null
var selected_piece_movement: Array[Tile] = []

func _init(board_object: Node3D):
	set_object(board_object)
	for tile_object in object.find_children("Tile_*","",false):
		var tile_position = Vector2(tile_object.name.substr(6,1).to_int(),tile_object.name.substr(8,1).to_int())
		
		# Sums the row and column numbers then sets their color based on if the sum is even or odd
		# 0 = light color, 1 = dark color
		match (tile_object.name.substr(6,1).to_int() + tile_object.name.substr(8,1).to_int()) % 2:
			0: tiles.append(Tile.new(tile_base_color_light,tile_position,tile_object))
			1: tiles.append(Tile.new(tile_base_color_dark,tile_position,tile_object))

	players.append(Player.new(1,player_colors[0]))
	players.append(Player.new(2,player_colors[1]))
	for tile in tiles:
		if tile.is_occupied(): 
			match tile.get_occupant().get_object().name.get_slice("_", 1):
				"P1": players[0].add_piece(tile.get_occupant())
				"P2": players[1].add_piece(tile.get_occupant())
	for player in players:
		pieces += player.get_pieces()
		player.apply_color_to_pieces()


func find_tile_class_from_object(tile_object: Node3D):
	for tile in tiles: if tile.get_object() == tile_object:
		return tile
	return null
func find_tile_class_from_name(tile_name: String):
	for tile in tiles: if tile.get_object().name == tile_name:
		return tile
	return null
func find_tile_class_from_position(tile_position: Vector2):
	for tile in tiles: if tile.get_position() == tile_position:
		return tile
	return null
func find_piece_class_from_object(piece_object: Node3D):
	for piece in pieces: if piece.get_object() == piece_object:
		return piece
	return null


func select_piece(piece: Piece):
	if selected_piece != null:
		reset_tile_colors(selected_piece_movement)
		selected_piece.unselect()
	piece.set_outline_color(piece_outline_selected_color)
	piece.select()
	selected_piece = piece
	highlight_possible_valid_moves(selected_piece)


func highlight_possible_valid_moves(piece: Piece): 
	var move_directions = piece.get_movement_directions()
	var move_distance = piece.get_movement_distance() + 1
	var parent_tile = piece.get_tile()
	var position = parent_tile.get_position()
	var flip = 1
	
	var complete_moveset: Array[Tile] = []
	
	if piece is Pawn and piece.get_base_color() == player_colors[0]:
		flip = -1
			
	for direction in move_directions:
		for n in range(1,move_distance):
			var new_position = position + (direction * n * flip)
			var new_tile = find_tile_class_from_position(new_position)
			if new_tile != null and (not new_tile.is_occupied() or not is_same_team(piece,new_tile.occupant)):
				complete_moveset.append(find_tile_class_from_position(new_position))
			else:
				print("Break")
				break
			print("next")
		
	if len(complete_moveset) != 0:
		selected_piece_movement = complete_moveset
		highlight_tiles(complete_moveset)



func highlight_tiles(tiles: Array[Tile]):
	for tile in tiles: highlight_tile(tile)
func highlight_tile(tile: Tile):
	tile.set_color(tile.color * tile_highlight_color)


func color_tile(tile_object: Tile, tile_color: Color):
	tile_object.set_color(tile_color)
func color_tiles(tile_objects: Array[Tile], tile_color: Color):
	for tile_object in tile_objects: color_tile(tile_object, tile_color)

func reset_tile_colors(tiles: Array[Tile]):
	for tile in tiles: reset_tile_color(tile)
func reset_tile_color(tile: Tile):
	match (int(tile.get_position()[0]) + int(tile.get_position()[1])) % 2:
		0: tile.set_color(tile_base_color_light)
		1: tile.set_color(tile_base_color_dark)

func is_same_team(piece1: Piece, piece2: Piece): 
	return piece1.object.name.get_slice("_", 1) == piece2.object.name.get_slice("_", 1)
func is_movement_restricted(): return restrict_movement
func is_valid_move(): return selected_tile in selected_piece_movement

func move_piece(piece: Piece, tile_destination: Tile):
	if is_valid_move():
		piece.object.reparent(tile_destination.object)
		piece.object.set_owner(tile_destination.object)
		piece.object.global_position = tile_destination.object.global_position * Vector3(1,0,1) + piece.object.global_position * Vector3(0,1,0)
		
		var old_tile = piece.get_tile()
		piece.set_tile(tile_destination)
		piece.get_tile().set_occupant(piece)
		old_tile.set_occupant(null)
		
		if piece is Pawn and !piece.has_moved():
			piece.set_movement_distance(1)
			piece.moved = true
		
		selected_piece = null
		selected_tile = null
		reset_tile_colors(selected_piece_movement)
		selected_piece_movement = []

func get_tiles() -> Array[Tile]: return tiles
func get_object() -> Node3D: return object

func set_object(board_object: Node3D): object = board_object
