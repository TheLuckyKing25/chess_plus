class_name FEN
extends Resource


var FE_notation: String


var piece_placement: String:
	get(): return FE_notation.split(" ")[0]


var active_player: String:
	get(): return FE_notation.split(" ")[1]


var castling_availability: String:
	get(): return FE_notation.split(" ")[2]


var en_passant_target_tile: String:
	get(): return FE_notation.split(" ")[3]


var halfmove_clock: String:
	get(): return FE_notation.split(" ")[4]


var fullmove_number: String:
	get(): return FE_notation.split(" ")[5]


func _init(layout:String) -> void:
	FE_notation = layout
