class_name Board
extends Node

var setting_restrict_movement: bool = true
var setting_show_threatened: bool = true

var object: Node3D

var tile_basecolor_light: Color = Color(1.0, 0.77, 0.58)
var tile_basecolor_dark: Color = Color(1.0, 0.77, 0.58).darkened(0.5)

var tile_move_color: Color = Color(0.25, 0.75, 0.25)
var threatened_color: Color = Color(0.9, 0, 0)
var select_color: Color = Color(0, 0.9, 0.9)

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
		match (tile_object.name.substr(6,1).to_int() + tile_object.name.substr(8,1).to_int()) % 2:
			0: tiles.append(Tile.new(tile_basecolor_light,tile_position,tile_object))
			1: tiles.append(Tile.new(tile_basecolor_dark,tile_position,tile_object))

	players.append(Player.new(1,player_colors[0]))
	players.append(Player.new(2,player_colors[1]))
	for tile in tiles:
		if tile.is_occupied(): 
			match tile.get_occupant().get_object().name.get_slice("_", 1):
				"P1": players[0].add_piece(tile.get_occupant())
				"P2": 
					tile.get_occupant().object.find_child("Collision*").disabled = true
					players[1].add_piece(tile.get_occupant())
	for player in players:
		pieces += player.get_pieces()
		player.apply_color_to_pieces()
	

func get_tiles() -> Array[Tile]: return tiles
func get_object() -> Node3D: return object

func set_object(board_object: Node3D): object = board_object

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


func highlight_tiles(tiles: Array[Tile], color: Color):
	for tile in tiles: highlight_tile(tile, color)
func highlight_tile(tile: Tile, color: Color):
	tile.set_color(tile.color * color)

func color_tile(tile_object: Tile, tile_color: Color):
	tile_object.set_color(tile_color)
func color_tiles(tile_objects: Array[Tile], tile_color: Color):
	for tile_object in tile_objects: color_tile(tile_object, tile_color)

func reset_all_tile_colors():
	for tile in tiles: 
		match (int(tile.get_position()[0]) + int(tile.get_position()[1])) % 2:
			0: tile.set_color(tile_basecolor_light)
			1: tile.set_color(tile_basecolor_dark)


func is_same_team(piece1: Piece, piece2: Piece): 
	return piece1.object.name.get_slice("_", 1) == piece2.object.name.get_slice("_", 1)
func is_movement_restricted(): return setting_restrict_movement
func is_valid_move(): return selected_tile in selected_piece_movement


func new_turn():
	for piece in players[player_turn].get_pieces():
		piece.object.find_child("Collision").disabled = true
	player_turn = (player_turn + 1) % 2
	for piece in players[player_turn].get_pieces():
		piece.object.find_child("Collision").disabled = false
	object.get_parent().get_surface_override_material(0).albedo_color = player_colors[player_turn]	


func select_piece(piece: Piece):
	if selected_piece != null:
		reset_all_tile_colors()
		for tile in selected_piece_movement:
			if tile.is_occupied() and not is_same_team(selected_piece, tile.occupant):
				tile.occupant.unthreaten()
		selected_piece.unselect()
	piece.set_outline_color(select_color)
	highlight_tile(piece.tile,select_color)
	piece.select()
	selected_piece = piece
	calculate_valid_moves(selected_piece)


func calculate_valid_moves(piece:Piece):
	var move_directions = piece.get_movement_directions()
	var move_distance = piece.get_movement_distance() + 1
	var parent_tile = piece.get_tile()
	var position = parent_tile.get_position()
	var flip = 1
	
	var complete_moveset: Array[Tile] = []
	var threatened_tiles: Array[Tile] = []
	
	if piece is Pawn and piece.get_base_color() == player_colors[0]:
		flip = -1
			
	for direction in move_directions:
		for n in range(1,move_distance):
			var new_position = position + (direction * n * flip)
			var new_tile = find_tile_class_from_position(new_position)
			if new_tile == null: 
				break
			if not new_tile.is_occupied():
				if piece is Pawn and direction != move_directions[0]: 
					break	
				complete_moveset.append(find_tile_class_from_position(new_position))
			elif new_tile.is_occupied():
				if is_same_team(piece, new_tile.occupant) \
				or (piece is Pawn and direction == move_directions[0]): 
					break					
				threatened_tiles.append(find_tile_class_from_position(new_position))
				break
			
	if len(complete_moveset) != 0:
		selected_piece_movement = complete_moveset
		highlight_tiles(complete_moveset, tile_move_color)
	if len(threatened_tiles) != 0:
		selected_piece_movement += threatened_tiles
		highlight_tiles(threatened_tiles, threatened_color)
		for tile in threatened_tiles:
			tile.occupant.set_outline_color(threatened_color)
			tile.occupant.threaten()

func move_piece(piece: Piece, tile_destination: Tile):
	if is_valid_move():
		reset_all_tile_colors()
		for tile in selected_piece_movement:
			if tile.is_occupied() and not is_same_team(selected_piece, tile.occupant):
				tile.occupant.unthreaten()
		
		if tile_destination.is_occupied():
			# PLACEHOLDER: CAPTURE MECHANIC
			tile_destination.get_occupant().object.visible = false
			
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
		
		selected_piece.object.find_child("Outline").visible = false
		selected_piece = null
		selected_tile = null
		selected_piece_movement = []
		new_turn()
