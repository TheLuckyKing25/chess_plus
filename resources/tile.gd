class_name Tile
extends Resource

static var selected: TileController = null
static var en_passant: TileController = null

static var total_rank_count: int:
	get():
		return Board.rank_count


static var total_file_count: int:
	get():
		return Board.file_count

var occupant: PieceController = null:
	set(new_occupant):
		if occupant:
			occupant.clicked.disconnect(Callable(self, "_on_occupant_clicked"))
		if new_occupant:
			new_occupant.clicked.connect(Callable(self, "_on_occupant_clicked"))
		occupant = new_occupant

#region Position
var board_position: Vector2i

var algebraic_notation: String:
	get():
		return char(97 + rank) + str((1 + file))

var rank: int:
	get():
		return board_position.x

var file: int:
	get():
		return board_position.y

var index: int:
	set(new_index):
		board_position = Vector2i(new_index/total_file_count, new_index%total_file_count)
	get():
		return get_index(rank,file)
#endregion

var tile_object: Node3D

#region States
var is_selected:bool = false:
	set(new_state):
		is_selected = new_state
		emit_changed()

var is_movement:bool = false:
	set(new_state):
		is_movement = new_state
		emit_changed()

var is_checking:bool = false:
	set(new_state):
		is_checking = new_state
		emit_changed()

var is_special:bool = false:
	set(new_state):
		is_special = new_state
		emit_changed()

var is_threatened:bool = false:
	set(new_state):
		is_threatened = new_state
		emit_changed()

var is_checked:bool = false:
	set(new_state):
		is_checked = new_state
		emit_changed()

var is_checked_movement:bool = false:
	set(new_state):
		is_checked_movement = new_state
		emit_changed()
#endregion


var modifier_order: Array[TileModifier] = []

func _init():
	resource_local_to_scene = true

static func get_index(rank:int,file:int) -> int:
	return (file) + ((rank) * total_file_count)


#region States
func _select():
	is_selected = true
	if occupant:
		occupant.is_selected = true

func _unselect():
	is_selected = false
	if occupant:
		occupant.is_selected = false
	
func _threaten():
	is_threatened = true
	if occupant:
		occupant.is_threatened = true
	
func _unthreaten():
	is_threatened = false
	if occupant:
		occupant.is_threatened = false

func _show_castling():
	is_special = true
	if occupant:
		occupant.is_special = true

func _hide_castling():
	is_special = false
	if occupant:
		occupant.is_special = false
	
func _set_check():
	is_checked = true
	if occupant:
		occupant.is_checked = true
	
func _unset_check():
	is_checked = false
	if occupant:
		occupant.is_checked = false
#endregion
	
