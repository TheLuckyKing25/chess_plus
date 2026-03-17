extends Control

signal back_button_pressed()
signal continue_button_pressed()
signal board_verified(rank_count: int, file_count: int, FEN_notation: FEN)


var row_num: int = 8
var column_num: int = 8

func _on_back_button_pressed() -> void:
	back_button_pressed.emit()

func _on_continue_button_pressed() -> void:
	board_verified.emit(row_num,column_num,FEN.new(%BoardStateFEN.text))
	continue_button_pressed.emit()


func _on_row_number_spin_box_value_changed(value: float) -> void:
	row_num = value


func _on_column_number_spin_box_value_changed(value: float) -> void:
	column_num = value


func _on_board_state_fen_text_changed() -> void:
	%PieceLayoutERRORLabel.hide()
	var split_text = FEN.new(%BoardStateFEN.text)

	var row_representation = split_text.piece_placement.split("/",false)
	if row_representation.size() != row_num:
		%PieceLayoutERRORLabel.show()
		return
	for row in row_representation:
		var column_length = 0
		for column in row:
			match column:
				"K","Q","N","R","B","P":
					column_length += 1
				"k","q","n","r","b","p":
					column_length += 1
				"0","1","2","3","4","5","6","7","8","9":
					column_length += column.to_int()

		if column_length != column_num:
			%PieceLayoutERRORLabel.show()
			return
	board_verified.emit(row_num, column_num, FEN.new(%BoardStateFEN.text))
