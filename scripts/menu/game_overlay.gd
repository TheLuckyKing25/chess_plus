extends Control

signal new_placement_selected(placement:String)

var placement_list: Dictionary[String,String] = {
	"Standard Board": "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
	"Castling Test 1": "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1"
}

func _ready():
	for placement in placement_list.keys():
		%PiecePlacementList.add_item(placement)

func _on_piece_placement_list_item_selected(index: int) -> void:
	var placement_key = %PiecePlacementList.get_item_text(index)
	new_placement_selected.emit(placement_list[placement_key])

func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	$ScreenController.position = Vector2(-1,-1) * $ScreenController/PauseMenu.position


func _on_pause_menu_resume_button_pressed() -> void:
	get_tree().paused = false
	$ScreenController.position = Vector2(0,0)

# When Escape pressed: pause game or resume game, depenent on state.
func _input(event) -> void:
	if event.is_action_pressed("ui_cancel") and !get_tree().paused:
		_on_pause_button_pressed()
			

func _on_pause_menu_leave_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/StartScreen.tscn")
	#get_tree().quit()


func _on_debug_toggled(toggled_on: bool) -> void:
	$ScreenController/ReferenceRect/MarginContainer/DebugMenu.visible = toggled_on
