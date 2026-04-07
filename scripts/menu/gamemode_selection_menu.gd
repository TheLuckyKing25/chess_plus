extends Control

signal time_control_selected(time_sec:int, increment_sec:int)
signal back_button_pressed()
signal continue_button_pressed()
signal board_verified(rank_count: int, file_count: int, FEN_notation: FEN)
signal start_button_pressed()
signal host_button_pressed()

const WAIT_SCREEN = preload("uid://crgfep2xyg10g")

var wait_screen: Node

var row_num: int = 8
var column_num: int = 8

func _ready() -> void:
	if NetworkManager.is_online and NetworkManager.my_player == 1:
		queue_free()
		return

func _on_host_game_button_pressed() -> void:
	host_button_pressed.emit(self)
	var result = NetworkManager.host_game()
	if result.is_empty():
		return

	var wait_layer = CanvasLayer.new()
	wait_layer.layer = 10
	add_child(wait_layer)

	wait_screen = WAIT_SCREEN.instantiate()
	wait_layer.add_child(wait_screen)
	wait_screen.set_ip_label(result["ip"])
	wait_screen.set_invite_code_label(result["code"])

	NetworkManager.connected_to_game.connect(_on_opponent_connected)

func _on_opponent_connected() -> void:
	wait_screen.queue_free()
	board_verified.emit(row_num, column_num, FEN.new(%BoardStateFEN.text))
	if %TimeControl/CheckBox.button_pressed:
		time_control_selected.emit(%TimeControl/MinutesPerPlayer/SpinBox.value * 60, %TimeControl/IncrementPerMove/SpinBox.value)
	start_button_pressed.emit()

func _on_back_button_pressed() -> void:
	back_button_pressed.emit()

func _on_continue_button_pressed() -> void:
	board_verified.emit(row_num,column_num,FEN.new(%BoardStateFEN.text))
	continue_button_pressed.emit()


func _on_row_number_spin_box_value_changed(value: float) -> void:
	row_num = value as int


func _on_column_number_spin_box_value_changed(value: float) -> void:
	column_num = value as int


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

func _on_start_button_pressed():
	board_verified.emit(row_num,column_num,FEN.new(%BoardStateFEN.text))
	if %TimeControl/CheckBox.button_pressed:
		time_control_selected.emit(%TimeControl/MinutesPerPlayer/SpinBox.value * 60, %TimeControl/IncrementPerMove/SpinBox.value)
	start_button_pressed.emit()

func _on_check_box_toggled(toggled_on: bool) -> void:
	%TimeControl/MinutesPerPlayer.visible = toggled_on
	%TimeControl/IncrementPerMove.visible = toggled_on
