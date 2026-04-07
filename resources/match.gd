class_name Match
extends RefCounted


static var board_data:BoardData


static var board_object:BoardObject


static var player_one: Player = load("uid://dxvl1tq0afyxx")
static var player_two: Player = load("uid://dc7e5u71wtrpp")

# move history
static var move_history:MoveList


static var is_timed: bool = false


static var tiles:Dictionary[TileObject,TileDataChess] = {

}


static var pieces: Dictionary[PieceObject, PieceData] = {

}


static func add_tile(tile_object:TileObject):
	tiles[tile_object] = tile_object.data


static func remove_tile(tile_object:TileObject):
	tiles.erase(tile_object)


static func add_piece(piece_object:PieceObject):
	pieces[piece_object] = piece_object.data


static func remove_piece(piece_object:PieceObject):
	tiles.erase(piece_object)


static func get_opponent_of(player: Player) -> Player:
	if player == player_one:
		return player_two
	elif player == player_two:
		return player_one
	else:
		return null
