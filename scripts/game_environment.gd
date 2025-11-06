extends Node3D

@export_group("Settings")

# Player settings
@export var PIECE_OUTLINE_THICKNESS: int = 0.1
# Debug settings
@export var DEBUG_RESTRICT_MOVEMENT: bool = true
# Game settings
## Show the path that a piece uses to check a king
@export var GAME_SHOW_CHECKING_PIECE_PATH: bool = true
## Show the piece that is checking a king
@export var GAME_SHOW_CHECKING_PIECE: bool = true
## You must move the first piece you select
@export var GAME_TOUCH_MOVE_RULE: bool = false # Not implimented


## Settings that may or may not be implimented as game options
var options: Dictionary = {
	# Debug settings
	"DEBUG_RESTRICT_MOVEMENT": true,
	
	# Game settings
	## Show the path that a piece uses to check a king
	"SHOW_CHECKING_PIECE_PATH": true,
	## Show the piece that is checking a king
	"SHOW_CHECKING_PIECE": true,
	## You must move the first piece you select
	"TOUCH_MOVE": false, # Not implimented
	
	# Player settings
	"PIECE_OUTLINE_THICKNESS": 0.1,
}

func _ready() -> void:
	
	var board = $"/root/gameEnvironment/Board"
	var base = $"/root/gameEnvironment/Board/BoardBase"
	#Global.create_players()
	
	#get_tree().call_group("Piece","calculate_complete_moveset")
	#get_tree().call_group("Piece","generate_valid_moveset")
	
	#for player in Board.players:
		#player.compile_threatened_tiles()
	#
	#Player.current = Board.players[Player.turn_num]
		

#func _process(delta: float) -> void:
	#if (
			#Piece.selected 
			#and Tile.selected 
			#and Tile.selected.is_valid_move(Piece.selected, Player.current)
	#):
		#Global.print_move()
		#
		#Piece.selected.move_to(Tile.selected)
#
#
### Moves the given piece to the given tile, 
### and captures opponent pieces if tile is occupied.
#func move_to(new_tile) -> void:
	#if new_tile.is_valid_move(self, Player.current):
		#
		#if new_tile.occupant:
			#new_tile.occupant.set_state(State.CAPTURED)
		#if self is Pawn and new_tile.en_passant_occupant:
			#new_tile.en_passant_occupant.set_state(State.CAPTURED)
		#
		## Parents the piece to the new tile in the node tree.
		#_reparent_piece_to_new_tile(new_tile.object_tile)
		#
		## Adjusts tile and piece class values
		#var starting_tile 
		#
		#starting_tile = on_tile
		#on_tile = new_tile
		#on_tile.occupant = self
		#starting_tile.occupant = null	
		#
		#if self is Pawn and not has_moved:
			#movement_distance = pawn.distance
			#if abs(starting_tile.board_position.x - on_tile.board_position.x) == 2:
				#self.en_passant_tile = Tile.find_from_position(on_tile.board_position + Vector2i(parity * -1,0))
				#self.threatened_by_en_passant = true
				#self.en_passant_tile.en_passant_occupant = self
		#has_moved = true
		#
		#if self is Pawn:
			#if (
					#(on_tile.board_position.x == 1 and player_parent == Board.players[0])
					#or (on_tile.board_position.x == 8 and player_parent == Board.players[1])
			#):
				#promote_to("knight")
		#
		#if self is King and new_tile in castling_moveset:
			#for relation in Global.king_rook_relation:
				#if relation["King_Destination_Tile"] == new_tile:
					#var rook 
					#var rook_position: Vector2i 
					#var distance_to_new_tile: Vector2i 
					#var new_position: Vector2i
					#var rook_new_tile
					#
					#rook = relation["Rook"]
					#rook_position = rook.on_tile.board_position
					#distance_to_new_tile = abs(rook_position - new_tile.board_position)
					#
					#if distance_to_new_tile.y == 2:
						#new_position = rook_position + Vector2i(0,3)
					#elif distance_to_new_tile.y == 1:
						#new_position = rook_position + Vector2i(0,-2)
					#rook_new_tile = Tile.find_from_position(new_position)
					#rook.move_to(rook_new_tile)
		#else:
			#Global.new_turn()
