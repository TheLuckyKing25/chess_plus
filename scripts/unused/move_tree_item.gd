@tool
class_name MoveTreeItem extends Resource

var root: MoveTreeItem

var position_vector: Vector2i:
	set(value):
		tile = Board.current_board.tile_vector_dict.get(value)
		position_vector = value

@export var tile: Tile

var tile_flags: Dictionary[String,bool] = {
	"is_selected": false,
	"is_movement": false,
	"is_castling": false,
	"is_threatened": false,

	"is_movement_legal": false,

	"is_occupied": false,

	"is_skipped": false,
	"is_blocked": false,
	"is_stopped": false,
}

@export var children: Array[MoveTreeItem]

func add_child(child: MoveTreeItem):
	children.append(child)
