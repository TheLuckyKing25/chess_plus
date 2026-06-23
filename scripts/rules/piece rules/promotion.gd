class_name Promotion
extends PieceRule


@export var promotion_options: Array[PieceConfig]


static func _handle_promotion(board_data: BoardData, value: Variant):
	pass


func _init():
	BoardChange.add_handler("promote",Callable(Promotion,"_handle_promotion"))


func evaluate_rule_application(current_change: BoardChange, piece:PieceData):
	pass
