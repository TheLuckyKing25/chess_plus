extends Control

var move_num: int = 1

func add_move(move:	Move):
	$Panel/MarginContainer/ItemList.add_item(str(move_num) + ") " + move.algebraic_notation,null,false)
	move_num += 1
