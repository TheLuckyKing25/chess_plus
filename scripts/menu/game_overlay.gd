extends Control

signal new_placement_selected(placement:FEN)
signal promotion_piecetype_selected(piece_name: String)

@onready var horizontal_slider:HSlider = %HorizontalCameraSlider
@onready var forward_slider:VSlider = %ForwardCameraSlider

var placement_tree: Dictionary = {
	"Standard Board": "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
	"Castling": {
			"All Valid": "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1",
			"Kingside Valid": "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w Kk - 0 1",
			"Queenside Valid": "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w Qq - 0 1",
			"None Valid": "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w - - 0 1",
			"King Checked": "r3k2r/pppp1ppp/8/4Q3/4q3/8/PPPP1PPP/R3K2R w KQkq - 0 1",
			"Checked Close Movement": "r3k2r/ppp1p1pp/8/3Q1Q2/3q1q2/8/PPP1P1PP/R3K2R w KQkq - 0 1",
			"Checked Far Movement": "r3k2r/pp1ppp1p/8/2Q3Q1/2q3q1/8/PP1PPP1P/R3K2R w KQkq - 0 1",
			},
	"Promotion": "8/PPPPPPPP/8/7K/k7/8/pppppppp/8 w KQkq - 0 1",
	"Fool's Mate": "rnbqkbnr/pppp1ppp/4p3/8/6P1/5P2/PPPPP2P/RNBQKBNR b KQkq - 0 1",
	"16x16 Board": {
		"Doubled layout": "rnbbnrbqkbrnbbnr/pppppppppppppppp/88/88/88/88/88/88/88/88/88/88/88/88/PPPPPPPPPPPPPPPP/RNBBNRBQKBRNBBNR w KQkq - 0 1",
		"Centered layout": "88/88/88/88/4rnbqkbnr4/4pppppppp4/88/88/88/88/4PPPPPPPP4/4RNBQKBNR4/88/88/88/88 w KQkq - 0 1"

	}
}

var promotion_menu_list: Array = [
	"Bishop",
	"Knight",
	"Rook",
	"Queen"
]

var move_num: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var root: TreeItem = %PiecePlacementList.create_item()
	for section in placement_tree.keys():
		var new_item: TreeItem = %PiecePlacementList.create_item(root)
		if typeof(placement_tree[section]) != TYPE_STRING:
			new_item.set_text(0,section)
			new_item.set_selectable(0,false)
			add_placements_to_section(new_item, section)
			new_item.collapsed = true
		else:
			new_item.set_text(0,section)
			new_item.set_metadata(0, placement_tree[section])
			new_item.set_selectable(0,true)

	for piecetype in promotion_menu_list:
		%PromotionList.add_item(piecetype)

func add_placements_to_section(item: TreeItem, section:String):
	for placement in placement_tree[section].keys():
		var new_item: TreeItem = item.create_child()
		new_item.set_text(0,placement)
		new_item.set_metadata(0, placement_tree[section][placement])
		new_item.set_selectable(0,true)

func show_checkmate(winner:Player):
	$Checkmate.show()
	$Checkmate/MarginContainer/VBoxContainer/WinnerLabel.text = winner.name + " wins"


func _on_piece_placement_list_item_selected() -> void:
	var selected_item: TreeItem = %PiecePlacementList.get_selected()
	var placement_key: FEN = FEN.new(selected_item.get_metadata(0))
	new_placement_selected.emit(placement_key)


func add_move(move:	Move):
	$Rightside/HBoxContainer/RightsideMenu/Panel/MarginContainer/ItemList.add_item(str(move_num) + ") " + move.algebraic_notation,null,false)
	move_num += 1


func _connect_to_pause_button(function: Callable):
	%PauseButton.pressed.connect(function)


func _connect_to_rulebook_button(function: Callable):
	#$MenuButtons/MenuButtons/RuleBookButton.pressed.connect(function)
	pass

# When Escape pressed: pause game or resume game, depenent on state.
func _input(event) -> void:
	if event.is_action_pressed("ui_cancel") and !get_tree().paused:
		pass


func _on_pause_menu_leave_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/StartScreen.tscn")
	#get_tree().quit()


func _on_leftside_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		%LeftsideMenu.show()
		%LeftsideButton.text = "<"
	elif not toggled_on:
		%LeftsideMenu.hide()
		%LeftsideButton.text = ">"


func _on_rightside_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		%RightsideMenu.show()
		%RightsideButton.text = ">"
	elif not toggled_on:
		%RightsideMenu.hide()
		%RightsideButton.text = "<"


func show_timers():
	%WhiteTimer.show()
	%BlackTimer.show()


func _get_ui_timer_white():
	return %WhiteTimer/MarginContainer/Label


func _get_ui_timer_black():
	return %BlackTimer/MarginContainer/Label


func _on_promotion_list_item_selected(index: int) -> void:
	promotion_piecetype_selected.emit(promotion_menu_list[index])

func _show_promotion_menu(mouse_position:Vector2):
	$PromotionMenu.show()
	$PromotionMenu.position = mouse_position

func _hide_promotion_menu():
	$PromotionMenu.hide()


func _on_camera_movement_button_toggled(toggled_on: bool) -> void:
	%HorizontalCameraSlider.visible = toggled_on
	%ForwardCameraSlider.visible = toggled_on
