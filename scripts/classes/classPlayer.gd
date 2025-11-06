static var current

static var turn_num: int = 0


var player_num: int


var all_threatened_tiles: Array


var color: Color:
	set(new_color):
		color = new_color


func _init(player_number: int, piece_color: Color) -> void:
	player_num = player_number
	color = piece_color


func compile_threatened_tiles() -> void:
	all_threatened_tiles.clear()
	for piece in pieces:
		if piece is Pawn:
			for tile in piece.pawn_threatening_moveset:
				if tile not in all_threatened_tiles:
					all_threatened_tiles.append(tile)
				continue
		else:
			for tile in piece.valid_moveset:
				if tile not in all_threatened_tiles:
					all_threatened_tiles.append(tile)
				continue
