# counts the number of moves
class_name HalfMoveCounter
extends Rule

const RULE_NAME: StringName = "half_move_counter"

@export_range(0,1000) var turns_until_draw: int = 50

var half_turn_count: int = 0

# Specify when the counter resets
# default: reset on captures and pawn moves
#region WIP Reset Specifications
#@export_tool_button("Reload List") var tool_button: Callable = Callable(reload_list)
#@export_group("Reset When","reset_on_")
#@export var reset_on_piecetype_moves: Array[String] = []


#func reload_list():
	#DebugPrinter.print_pretty(get_property_list())
	#notify_property_list_changed()
#
#func _validate_property(property: Dictionary) -> void:
	#if property.name in ["reset_on_piecetype_moves"]:
		#var options:String = ",".join(Constants.TypePiece.keys())
		#property.hint = PROPERTY_HINT_TYPE_STRING
		#property.hint_string = "%d/%d:%s" % [TYPE_STRING,PROPERTY_HINT_ENUM,options]
#endregion


static func _handle_change(board_data: BoardObject, value: Variant):
	#var full_turn_count: int = floor(count/2)
	#if full_turn_count == TURNS_UNTIL_DRAW:
		# DRAW
	pass


func _ready():
	var change_function:Callable = Callable(HalfMoveCounter,"_handle_change")
	BoardChange.add_change_handler(RULE_NAME, change_function)


func evaluate_rule(board:BoardObject):
	var current_changes: BoardChange = board.current_changes
	var was_pawn_moved: bool = current_changes.changed_data.move.occupant.name.contains("Pawn")
	var was_piece_captured:bool = current_changes.changed_data.has(BoardChange.CAPTURED_RULE_NAME)
	if not was_piece_captured and not was_pawn_moved:
		half_turn_count += 1
	else:
		half_turn_count = 0
	board.current_changes.add_change(RULE_NAME, half_turn_count)
