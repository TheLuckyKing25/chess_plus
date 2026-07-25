# this is a state of a board.
# should be seperate from the Board Object
class_name BoardData
extends Resource


#signal player_to_move_changed(new_player_data: PlayerData)
#signal board_representation_changed()
#
#
#enum {
	#TILE_DATA_INDEX = 0,
	#PIECE_DATA_INDEX = 1
	#}
#
#
#@export var rules: Array[GameRule] = [
	#FiftyMoveRule.new()
#]
#
#
#@export var rank_count: int = GameData.match_settings.board_size.rank
#@export var file_count: int = GameData.match_settings.board_size.file
#
#
#@export var max_length: int:
	#get = _max_length_getter
#
#
#@export_custom(PROPERTY_HINT_NONE,"",PROPERTY_USAGE_NEVER_DUPLICATE) var assigned_object: BoardObject
#
#
#@export var tiles: Array[TileDataChess] = []
#@export var pieces: Array[PieceData] = []
#
#
#@export var valid_selections: Array = []
#@export var valid_destinations: Dictionary[PieceData,Dictionary] = {
	##PieceData: {TileData: ObjectStateComponent.Type, ...}
#}
#
#
#var fen:FEN = FEN.new("rnbqkbnr/pppppppp/8/7B/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
#
#
##region Data
## Entries of this dictionary are of the format "Vector2i: [TileData, PieceData]"
#@export var board_representation: Dictionary[Vector2i, Array] = {}:
	#set = _board_representation_setter
#
#
#@export var player_to_move: PlayerData:
	#set = _player_to_move_setter
#
#
#@export var board_history: Array[BoardChange] = []
#
#
#@export var castling_rights: Dictionary = {
	#"white": {
		#"kingside": true,
		#"queenside": true,
	#},
	#"black": {
		#"kingside": true,
		#"queenside": true,
	#},
#}
#
#
## Defines the Tile a pawn must land on to capture Piece.
## Piece is not on Tile.
#@export var en_passant: Dictionary = {
	#"tile": null,
	#"piece": null
#}
#
#
#@export var fullmove_counter: int = 0
##endregion
#
#
#func print_properties():
	#var property_list: Array[Dictionary] = get_property_list()
	#var property_dict: Dictionary[StringName,Variant] = {}
	#for property in property_list:
		#property_dict.set(property.name,get(property.name))
#
	#DebugPrinter.print_pretty(property_dict, false)
#
#
##region Getter/Setters
#func _max_length_getter() -> int:
	#return maxi(file_count,rank_count)
#
#
#func _board_representation_setter(value) -> void:
	#board_representation = value
	#board_representation_changed.emit()
#
#
#func _player_to_move_setter(value:PlayerData) -> void:
	#player_to_move_changed.emit(value)
	#player_to_move = value
##endregion
#
## This is not run through the _init function because there are some cases where
## we do not want to generate new tiles when creating a new board.
#static func create_board(ranks:int = 8, files:int = 8) -> BoardData:
	#var board:BoardData = BoardData.new(ranks,files)
#
	#if board.board_representation.is_empty():
		#board._generate_position_vectors()
		#board._generate_tile_data()
#
	#board._assign_tile_neighbors()
	#board._generate_pieces()
	#board._set_player_to_move()
#
	#var search: BoardSearch = BoardSearch.new()
	#search.search(board,1)
#
	#return board
#
#
#func _init(ranks:int = 8, files:int = 8) -> void:
	#rank_count = ranks
	#file_count = files
#
	#GameData.players.white.promotion_rank = rank_count - 1
	#GameData.players.black.promotion_rank = 0
#
	#player_to_move_changed.connect(_on_player_to_move_changed)
#
#
#func _generate_position_vectors() -> void:
	#for index in range(rank_count*file_count):
		#board_representation.set(Vector2i(index/file_count, index%file_count),[])
#
#
#func _generate_tile_data() -> void:
	#for index in range(rank_count*file_count):
		#var new_tile: TileDataChess = TileDataChess.new()
		#tiles.append(new_tile)
#
		#var position_vector: Vector2i = Vector2i(index/file_count, index%file_count)
		#new_tile.set_position_data(index,position_vector)
		#board_representation.set(position_vector, [new_tile,null])
#
		#new_tile.resource_name = "Tile " + new_tile.algebraic_notation
#
#
#func _assign_tile_neighbors() -> void:
	#for tile:TileDataChess in tiles:
		#for direction:Constants.Direction in range(0,8):
			#var neighbor_position: Vector2i = (
					#tile.position_vector
					#+ Constants.DIRECTION_VECTOR.get(direction)
				#)
#
			#if _is_out_of_bounds(neighbor_position):
				#tile.neighbors.set(direction, null)
				#continue
#
			#tile.neighbors.set(direction, board_representation.get(neighbor_position).get(TILE_DATA_INDEX))
#
#
#func _is_out_of_bounds(postition: Vector2i) -> bool:
	#return (
			#postition.x > rank_count-1
			#or postition.y > file_count-1
			#or postition.x < 0
			#or postition.y < 0
		#)
#
#
#func _generate_pieces() -> void:
	#var tile_count: int = 0
	#var new_piece: PieceObject
#
	#for character:String in fen.piece_placement:
		#var tile_index: int = tile_count%file_count + (rank_count - (tile_count/file_count)-1)*file_count
		#var new_piece_func: Callable = PieceObject.new_piece.bind(max_length, tile_index)
		#var piece_config_uid: String = ""
		#match character.to_lower():
			#"p","r","b","n","q","k":
				#piece_config_uid = Constants.piece_config_lookup.get(character.to_lower())
				#new_piece = new_piece_func.call(load(piece_config_uid))
			#"1","2","3","4","5","6","7","8","9":
				#tile_count += character.to_int()
				#continue
			#var no_match:
				#if no_match == "/": continue
				#printerr("No match found for " + no_match)
				#print_stack()
				#continue
#
		#match character:
			#"p","r","b","n","q","k":
				#new_piece.assign_player("black")
			#"P","R","B","N","Q","K":
				#new_piece.assign_player("white")
#
		#var position_vector: Vector2i = Vector2i(tile_index/file_count, tile_index%file_count)
		#var board_rep_position = board_representation.get(position_vector)
		#board_rep_position[PIECE_DATA_INDEX] = new_piece
		#pieces.append(new_piece)
		#board_rep_position[TILE_DATA_INDEX].occupant = new_piece
		#new_piece.position_vector = position_vector
#
		#tile_count += 1
#
#
#func _set_player_to_move() -> void:
	#match fen.active_player:
		#"w": player_to_move = GameData.players.white.data
		#"b": player_to_move = GameData.players.black.data
#
#
#func _on_player_to_move_changed(new_player_data:PlayerData) -> void:
	#valid_selections.clear()
	#valid_destinations.clear()
	#_find_all_valid_selections(new_player_data)
	#_find_all_valid_destinations()
#
#func _find_all_valid_selections(new_player_data:PlayerData) -> void:
	#var piece_filter:Callable = func(piece: PieceData): if piece.player == new_player_data: return piece
	#var selectable_piece_objects:Array[PieceData] = pieces.filter(piece_filter)
	#valid_selections.append_array(selectable_piece_objects)
#
	#var tile_filter:Callable = func(tile: TileDataChess): if selectable_piece_objects.has(tile.occupant): return tile
	#var selectable_tile_object: Array[TileDataChess] = tiles.filter(tile_filter)
	#valid_selections.append_array(selectable_tile_object)
#
#
#func _find_all_valid_destinations() -> void:
	#var destinations: Dictionary[PieceData,Dictionary] = {}
#
	#var selectable_pieces: Array = valid_selections.filter(
			#func(item): return (item is PieceData)
		#)
	#for piece in selectable_pieces:
		#destinations.set(piece,_find_movement_of_piece(piece))
#
	## filter out moves
#
	#valid_destinations = destinations
#
#
#func _find_movement_of_piece(piece:PieceData) -> Dictionary[TileDataChess,ObjectStateComponent.Type]:
	#var movement: Dictionary[TileDataChess,ObjectStateComponent.Type] = {}
	#var starting_tile: TileDataChess = board_representation.get(piece.position_vector).get(TILE_DATA_INDEX)
	#movement = piece.current_movement.apply_movement(starting_tile, self)
	#piece.reset_current_movement()
	#return movement
#
#
#func process_change(from: TileDataChess, to: TileDataChess) -> void:
	#var new_change: BoardChange = BoardChange.new()
#
	#var move: Dictionary = {
		#to.position_vector: [to, from.occupant],
		#from.position_vector: [from, null],
	#}
#
	#new_change.add_change(BoardChange.MOVE_RULE_NAME, move)
	#new_change.add_change(BoardChange.PLAYER_TO_MOVE_RULE_NAME, GameData.opponent(player_to_move))
	#if is_instance_valid(to.occupant):
		#new_change.add_change(BoardChange.CAPTURED_RULE_NAME, [to.occupant])
#
#
	#_evaluate_piece_rules(new_change)
	#_evaluate_game_rules(new_change)
#
	#BoardChange.apply_change(new_change,self)
	#DebugPrinter.print_pretty(board_history[-1].changed_data,false)
#
#
#func _evaluate_piece_rules(current_changes: BoardChange):
	#for piece:PieceData in pieces:
		#piece.evaluate_rules(current_changes)
#
#
#func _evaluate_game_rules(current_changes: BoardChange):
	#var _validation_filter: Callable = func(item): return is_instance_valid(item)
	#var new_changes: Array[BoardChange] = []
	#for rule:GameRule in rules:
		#new_changes.append(rule.evaluate_rule_application(current_changes,self))


# ===============================================================================
# ============================== [END OF REFACTOR] ==============================
# ===============================================================================



var tile_array: Array[TileObject] = []
var piece_array: Array[PieceObject] = []

var legal_moves: MoveList


var FEN_board_state: FEN


#func _get_from_vector(vector: Vector2i) -> Dictionary:
	#return board_representation.get(vector)


func find_tile_using_vector(vector: Vector2i) -> TileObject:
	for tile in tile_array:
		if tile.data.position_vector == vector:
			return tile

	return null # tile not found
