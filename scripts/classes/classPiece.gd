class_name Piece

## Game Pieces
const TYPE: Dictionary = {
	"PAWN": {
		"MESH": "res://assets/pawn_mesh.obj",
		"DISTANCE_INITIAL": 2,
		"DISTANCE": 1,
		"DIRECTION": [
			Vector2i(1,0)
		],
		"DIRECTION_CAPTURE": [
			Vector2i(1,1),Vector2i(1,-1)
		]
	},
	"BISHOP": {
		"MESH": "res://assets/bishop_mesh.obj",
		"DISTANCE": 8,
		"DIRECTION": [
			Vector2i(1,1), 
			Vector2i(1,-1),
			Vector2i(-1,-1),
			Vector2i(-1,1),
		],
	},
	"KNIGHT": {
		"MESH": "res://assets/knight_mesh.obj",
		"DISTANCE": 1,
		"DIRECTION": [
			Vector2i(1,2),  
			Vector2i(2,1),
			Vector2i(2,-1), 
			Vector2i(1,-2), 
			Vector2i(-1,2), 
			Vector2i(-2,-1),
			Vector2i(-2,1), 
			Vector2i(-1,-2),
		],
	},
	"ROOK": {
		"MESH": "res://assets/rook_mesh.obj",
		"DISTANCE": 8,
		"DIRECTION": [
			Vector2i(1,0), 
			Vector2i(0,1), 
			Vector2i(-1,0), 
			Vector2i(0,-1),
		],
	},
	"QUEEN": {
		"MESH": "res://assets/queen_mesh.obj",
		"DISTANCE": 8,
		"DIRECTION": [
			Vector2i(1,0), 
			Vector2i(1,1), 
			Vector2i(0,1), 
			Vector2i(1,-1), 
			Vector2i(0,-1), 
			Vector2i(-1,-1), 
			Vector2i(-1,0), 
			Vector2i(-1,1),
		],
	},
	"KING": {
		"MESH": "res://assets/king_mesh.obj",
		"DISTANCE": 1,
		"DIRECTION": [
			Vector2i(1,0), 
			Vector2i(1,1), 
			Vector2i(0,1), 
			Vector2i(1,-1), 
			Vector2i(0,-1), 
			Vector2i(-1,-1), 
			Vector2i(-1,0), 
			Vector2i(-1,1),
		],
	},
}

enum State{
		NONE,
		SELECTED,
		THREATENED,
		CAPTURED,
		CHECKED,
		CHECKING,
		SPECIAL,
	}


static var selected: Piece = null


var castling_moveset: Array[Tile] = []


var collision_object: CollisionShape3D


var complete_moveset:Array[Array] = []


var current_state: State = State.NONE


var has_moved: bool = false


## Color of the mesh object
var mesh_color: Color:
	set(color):
		mesh_color = color
		mesh_object.get_surface_override_material(0).albedo_color = color


var mesh_object: MeshInstance3D


## Directions the piece can move in.
var movement_direction: Array 


## The distance covered by the movement directions.
var movement_distance: int 


## Node containing the Mesh, Outline, and CollisionBox
var object: Node3D:
	set(node):
		object = node
		mesh_object = node.find_child("Mesh")
		outline_object = node.find_child("Outline")
		collision_object = node.find_child("Collision")


## Color of the mesh object
var outline_color: Color:
	set(color):
		outline_color = color
		outline_object.material_override.albedo_color = color


var outline_object: MeshInstance3D


## determines which direction is the front
var parity: int 


var player_parent: Player:
	set(player):
		player_parent = player
		parity = 1 if player.color != Game.Colour.PALETTE[Game.Colour.PLAYER][0] else -1


var possible_moveset: Array[Tile]:
	get: 
		return valid_moveset + threatening_moveset + castling_moveset


var state_order: Array[State] = []


var threatening_moveset: Array[Tile] = []


## Tile that the piece is on/parented
var on_tile: Tile


var valid_moveset: Array[Tile] = []


## Returns the piece class of the given piece object.
## Returns null if no piece class can be found.
static func find_from_object(piece_object: Node3D) -> Piece:
	for piece in Board.all_pieces: 
		if piece.object == piece_object:
			return piece
	return null
	
func _init(player: Player, tile: Tile, piece_object: Node3D) -> void:
	object = piece_object
	player_parent = player
	on_tile = tile
	mesh_color = player.color


## Node tree function that reparents the piece object to the tile object
func _reparent_piece_to_new_tile(tile:Node3D) -> void:
		object.reparent(tile)
		object.set_owner(tile)
		object.global_position = (
				tile.global_position 
				* Vector3(1,0,1)
				+ object.global_position 
				* Vector3(0,1,0)
		)


func _set_outline_to(new_color:= Color(0,0,0)) -> void:
	if (new_color == Color(0,0,0)):
		outline_object.visible = false
		return
	outline_color = new_color
	outline_object.visible = true


func is_king_of(player:Player) -> bool:
	return self is King and self.is_piece_of(player)


func is_piece_of(player:Player) -> bool:
	return self in player.pieces


func is_same_piece(piece: Piece) -> bool:
	return self == piece

func promote_to(placeholder_variable_piecetype: String):
	pass

## Moves the given piece to the given tile, 
## and captures opponent pieces if tile is occupied.
func move_to(new_tile: Tile) -> void:
	if new_tile.is_valid_move(self, Player.current):
		
		if new_tile.occupant:
			new_tile.occupant.set_state(Piece.State.CAPTURED)
		if self is Pawn and new_tile.en_passant_occupant:
			new_tile.en_passant_occupant.set_state(Piece.State.CAPTURED)
		
		# Parents the piece to the new tile in the node tree.
		_reparent_piece_to_new_tile(new_tile.object_tile)
		
		# Adjusts tile and piece class values
		var starting_tile: Tile 
		
		starting_tile = on_tile
		on_tile = new_tile
		on_tile.occupant = self
		starting_tile.occupant = null	
		
		if self is Pawn and not has_moved:
			movement_distance = Piece.TYPE.PAWN.DISTANCE
			if abs(starting_tile.board_position.x - on_tile.board_position.x) == 2:
				self.en_passant_tile = Tile.find_from_position(on_tile.board_position + Vector2i(parity * -1,0))
				self.threatened_by_en_passant = true
				self.en_passant_tile.en_passant_occupant = self
		has_moved = true
		
		if self is Pawn:
			if (
					(on_tile.board_position.x == 1 and player_parent == Board.players[0])
					or (on_tile.board_position.x == 8 and player_parent == Board.players[1])
			):
				promote_to("knight")
		
		if self is King and new_tile in castling_moveset:
			for relation in Global.king_rook_relation:
				if relation["King_Destination_Tile"] == new_tile:
					var rook: Piece 
					var rook_position: Vector2i 
					var distance_to_new_tile: Vector2i 
					var new_position: Vector2i
					var rook_new_tile: Tile
					
					rook = relation["Rook"]
					rook_position = rook.on_tile.board_position
					distance_to_new_tile = abs(rook_position - new_tile.board_position)
					
					if distance_to_new_tile.y == 2:
						new_position = rook_position + Vector2i(0,3)
					elif distance_to_new_tile.y == 1:
						new_position = rook_position + Vector2i(0,-2)
					rook_new_tile = Tile.find_from_position(new_position)
					rook.move_to(rook_new_tile)
		else:
			Global.new_turn()


func previous_state() -> void:
	if not state_order.is_empty():
		set_state(state_order.pop_back())
	else:
		set_state(State.NONE)


## Selects the given piece
func select() -> void:
	if selected:
		# unselect piece by clicking on it again
		if selected.is_same_piece(self):
			selected.unselect()
			selected = null

		# select tile by clicking an opponent piece
		elif is_piece_of(Player.current.opponent()): 
			Tile.selected = on_tile

		# unselect the current piece and select the new piece
		elif is_piece_of(Player.current): 
			selected.unselect()

			selected = self
			selected.set_state(State.SELECTED)
			
	# select the newly selected piece
	elif not selected and is_piece_of(Player.current): 
		selected = self
		selected.set_state(State.SELECTED)
	
	# Highlight tiles if castling applies to selected piece
	if selected and selected is King:
		for rook in Player.current.rooks:
			if not Global.is_castling_legal(selected,rook):
				continue
			rook.set_state(Piece.State.SPECIAL)
			var king_position: Vector2i = selected.on_tile.board_position
			var rook_position: Vector2i = rook.on_tile.board_position
			var new_position: Vector2i
			
			if king_position > rook_position:
				new_position = king_position + Vector2i(0,-2)
			elif king_position < rook_position:
				new_position = king_position + Vector2i(0,2)
				
			var king_new_tile: Tile = Tile.find_from_position(new_position)
			king_new_tile.set_state(Tile.State.SPECIAL)
			selected.castling_moveset.append(king_new_tile)
			Global.king_rook_relation.append({
				"Rook": rook, 
				"King_Destination_Tile": king_new_tile
				})


func set_state(new_state: State) -> void:
	match new_state:
		
		State.NONE: 
			_set_outline_to()
			on_tile.set_state(Tile.State.NONE)
			state_order.clear()
		
		State.SELECTED:
			if current_state != State.NONE:
				state_order.append(current_state)
			_set_outline_to(Game.Colour.PALETTE[Game.Colour.SELECT_PIECE])
			on_tile.set_state(Tile.State.SELECTED)

			for tile in valid_moveset:
				if self is King and tile in Global.checked_king_moveset:
					tile.set_state(Tile.State.MOVE_CHECKING)
				else:
					tile.set_state(Tile.State.VALID)
			for tile in threatening_moveset:
				if self is Pawn and not tile.occupant:
					tile.set_state(Tile.State.THREATENED)
					tile.en_passant_occupant.set_state(State.THREATENED)
				else:
					tile.occupant.set_state(State.THREATENED)
		
		State.THREATENED:
			if current_state != State.NONE:
				state_order.append(current_state)
			_set_outline_to(Game.Colour.PALETTE[Game.Colour.THREATENED_PIECE])
			on_tile.set_state(Tile.State.THREATENED)
		
		State.CAPTURED:
			object.visible = false
			collision_object.disabled = true
			object.translate(Vector3(0,-5,0)) 
		
		State.CHECKED: 
			if current_state != State.NONE:
				state_order.append(current_state)
			_set_outline_to(Game.Colour.PALETTE[Game.Colour.CHECKED_PIECE])
			on_tile.set_state(Tile.State.CHECKED)
		
		State.CHECKING: 
			if current_state != State.NONE:
				state_order.append(current_state)
			_set_outline_to(Game.Colour.PALETTE[Game.Colour.CHECKING_PIECE])
			on_tile.set_state(Tile.State.CHECKING)
		
		State.SPECIAL:
			if current_state != State.NONE:
				state_order.append(current_state)
			_set_outline_to(Game.Colour.PALETTE[Game.Colour.SPECIAL_PIECE])
	
	current_state = new_state


func unselect() -> void:
	for tile in possible_moveset:
		tile.previous_state()
		if tile.is_occupied_by_piece_of(Player.current.opponent()):
			tile.occupant.previous_state()
	for relation in Global.king_rook_relation:
		relation["Rook"].previous_state()
	Global.king_rook_relation.clear()
	previous_state()
