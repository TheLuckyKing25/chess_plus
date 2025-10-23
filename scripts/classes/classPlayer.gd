class_name Player

static var current: Player

static var turn_num: int = 0


var player_num: int


var king: King


var queens: Array[Queen]


var rooks: Array[Rook]


var bishops: Array[Bishop]


var knights: Array[Knight]


var pawns: Array[Pawn]


var pieces: Array:
	get:
		return [king] + queens + rooks + bishops + knights + pawns


var all_threatened_tiles: Array[Tile]


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


func opponent() -> Player:
	if self == Board.players[0]:
		return Board.players[1]
	elif self == Board.players[1]:
		return Board.players[0]
	else:
		return null
