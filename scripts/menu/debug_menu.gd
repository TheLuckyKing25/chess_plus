extends Control

signal clear_pieces_pressed()
signal capture_piece_pressed()
signal unrestrict_movement_toggled(toggled_on: bool)
signal has_moved_checkbox_toggled(toggled_on: bool)
signal player_owner_option_item_selected(index: int)
signal player_turn_option_item_selected(index: int)

func _on_piece_selected(piece: Piece) -> void:
	%PieceName.text = piece.name
	if piece.is_in_group("has_moved"):
		%HasMovedCheckbox.button_pressed = true
	else:
		%HasMovedCheckbox.button_pressed = false
	

func _on_clear_pieces_pressed() -> void:
	clear_pieces_pressed.emit()


func _on_capture_piece_pressed() -> void:
	capture_piece_pressed.emit()


func _on_unrestrict_movement_toggled(toggled_on: bool) -> void:
	unrestrict_movement_toggled.emit(toggled_on)


func _on_has_moved_checkbox_toggled(toggled_on: bool) -> void:
	has_moved_checkbox_toggled.emit(toggled_on)


func _on_player_owner_option_item_selected(index: int) -> void:
	player_owner_option_item_selected.emit(index)


func _on_player_turn_option_item_selected(index: int) -> void:
	player_turn_option_item_selected.emit(index)
