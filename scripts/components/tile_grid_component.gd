class_name TileGridComponent
extends Node

signal generation_finished

const TILE_SCENE:PackedScene = preload("uid://clmimmf3c1qpt")


@export var rank_count: int = GameData.match_settings.board_size.rank
@export var file_count: int = GameData.match_settings.board_size.file

var max_length: int:
	get = _max_length_getter

var tile_list: Array[TileObject]
var piece_list: Array[PieceObject]
var vector_position_tile_dict: Dictionary[Vector2i,TileObject] = {
	# Vector2i: TileObject
}

func _max_length_getter() -> int:
	return maxi(file_count,rank_count)

func generate_tile_grid(ranks: int, files: int) -> void:
	rank_count = ranks
	file_count = files

	_generate_tiles()
	_set_tile_data()
	_assign_tile_neighbors()
	_generate_pieces()

	generation_finished.emit()


func _generate_tiles() -> void:
	var current_number_of_tiles:int = tile_list.size()
	var total_number_of_tiles:int = rank_count * file_count

	while current_number_of_tiles < total_number_of_tiles:
		var tile: TileObject = TILE_SCENE.instantiate()
		#tile.clicked.connect(_on_tile_clicked)
		tile_list.append(tile)
		current_number_of_tiles += 1

	while current_number_of_tiles > total_number_of_tiles:
		tile_list.pop_back().queue_free()
		current_number_of_tiles -= 1


func _set_tile_data() -> void:
	for tile in tile_list:
		add_child(tile)
		var index: int = tile_list.find(tile)
		var position_vector: Vector2i = Vector2i(index/file_count, index%file_count)
		tile.set_position_data(index,position_vector)
		vector_position_tile_dict.set(position_vector,tile)
		tile.name = "Tile " + tile.algebraic_notation
		tile.position = (Vector3(
			position_vector.y -(float(file_count)/2)+0.5,
			0.1,
			(float(rank_count)/2)-position_vector.x-0.5
		))

func _assign_tile_neighbors() -> void:
	for tile:TileObject in tile_list:
		for direction:StringName in Constants.Direction:
			var direction_int:int = Constants.Direction.get(direction)
			var neighbor_position: Vector2i = (
					tile.position_vector
					+ Constants.DIRECTION_VECTOR.get(direction_int)
				)

			if _is_out_of_bounds(neighbor_position):
				tile.neighbors.set(direction_int, null)
				continue

			tile.neighbors.set(direction_int, vector_position_tile_dict.get(neighbor_position))


func _is_out_of_bounds(postition: Vector2i) -> bool:
	return (
			postition.x > rank_count-1
			or postition.y > file_count-1
			or postition.x < 0
			or postition.y < 0
		)


func _generate_pieces() -> void:
	const PIECE_UID_DICT:Dictionary = Constants.PIECE_SCENE_UID_DICT
	const TYPE_PIECE: Dictionary = Constants.TypePiece
	var fen: FEN = get_parent().fen
	var tile_count: int = 0
	var new_piece: PieceObject

	for character:String in fen.piece_placement:
		var tile_index: int = tile_count%file_count + (rank_count - (tile_count/file_count)-1)*file_count
		var piece_uid: String = ""
		match character.to_lower():
			"p": piece_uid = PIECE_UID_DICT.get(TYPE_PIECE.PAWN)
			"r": piece_uid = PIECE_UID_DICT.get(TYPE_PIECE.ROOK)
			"b": piece_uid = PIECE_UID_DICT.get(TYPE_PIECE.BISHOP)
			"n": piece_uid = PIECE_UID_DICT.get(TYPE_PIECE.KNIGHT)
			"q": piece_uid = PIECE_UID_DICT.get(TYPE_PIECE.QUEEN)
			"k": piece_uid = PIECE_UID_DICT.get(TYPE_PIECE.KING)
			"1","2","3","4","5","6","7","8","9":
				tile_count += character.to_int()
				continue
			var no_match:
				if no_match == "/": continue
				printerr("No match found for " + no_match)
				print_stack()
				continue

		new_piece = load(piece_uid).instantiate()

		var piece_player = new_piece.player_ownership
		var player_dict: Dictionary = get_parent().player_component.player_dictionary
		match character:
			"p","r","b","n","q","k":
				piece_player.player = player_dict.black
			"P","R","B","N","Q","K":
				piece_player.player = player_dict.white

		var position_vector: Vector2i = Vector2i(tile_index/file_count, tile_index%file_count)
		var tile = tile_list.get(tile_index)
		piece_list.append(new_piece)
		tile.occupant_component.occupant = new_piece
		new_piece.position_vector = position_vector

		tile_count += 1
