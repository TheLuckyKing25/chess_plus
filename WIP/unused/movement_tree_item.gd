# UNFINISHED
class_name MovementTreeItem extends RefCounted

var root: MovementTreeItem

var tile: TileObject

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


var children: Array[MovementTreeItem]


func _init(tile:TileObject, movement: Movement):
	self.tile = tile
	set_states(movement)

func set_states(movement:Movement):
	for modifier in tile.data.modifier_order:
		if modifier.is_stopping:
			tile_flags.is_stopped = true
		if modifier.is_blocking:
			tile_flags.is_blocked = true

	if tile.occupant:
		tile_flags.is_occupied = true

	if movement.is_jump:
		tile_flags.is_skipped = true
	if movement.is_move:
		tile_flags.is_movement = true
	if movement.is_threaten:
		tile_flags.is_threatened = true
	if movement.is_castling:
		tile_flags.is_castling = true



func add_child(item: MovementTreeItem):
	children.append(item)


func remove_child(item: MovementTreeItem):
	if children.has(item):
		children.erase(item)


func get_children():
	return children
