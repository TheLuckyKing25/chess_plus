# TileDataChess doesn't fit naming scheme of other Data classes
# because TileData is a Godot class
class_name TileDataChess
extends Resource

signal modifier_order_changed()
signal occupant_changed(occupant: PieceData)


var modifier_order: Array[TileModifier] = []:
	set(new_order):
		modifier_order = new_order
		modifier_order_changed.emit()


var neighbors: Dictionary[Constants.Direction, TileDataChess] = {
	Constants.Direction.NORTH: null,
	Constants.Direction.NORTHEAST: null,
	Constants.Direction.EAST: null,
	Constants.Direction.SOUTHEAST: null,
	Constants.Direction.SOUTH: null,
	Constants.Direction.SOUTHWEST: null,
	Constants.Direction.WEST: null,
	Constants.Direction.NORTHWEST: null,
}

#region Position
var rank: int


var file: int


var index: int


var algebraic_notation: String:
	get(): return char(97 + rank) + str((1 + file))


var board_position: Vector2i = Vector2i(-1,-1):
	set(value):
		rank = value.x
		file = value.y
	get():
		return Vector2i(rank,file)
#endregion


var occupant: PieceData = null:
	set(new_occupant):
		if assigned_object and assigned_object.get_parent() == self:
			assigned_object.add_child(new_occupant.assigned_object)
		occupant = new_occupant
		occupant_changed.emit(new_occupant)


var assigned_object: TileObject


func _init() -> void:
	resource_local_to_scene = true


func clear_modifiers():
	modifier_order = []


func set_position_data(index:int, vector: Vector2i):
	self.index = index
	rank = vector.x
	file = vector.y
