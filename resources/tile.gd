class_name Tile
extends Resource

# Standard Tile Colors
const BASE_COLOR: Color = Color(0.75, 0.5775, 0.435, 1) 
const LIGHT_COLOR = BASE_COLOR * 4/3
const DARK_COLOR = BASE_COLOR * 2/3 + Color(0,0,0,1)

# State Tile Colors
const THREATENED_COLOR = Color(1, 0.2, 0.2, 1)
const VALID_COLOR = Color(0.6, 1, 0.6, 1)
const SELECT_COLOR = Color(0.1, 1, 1, 1)
const CHECKED_COLOR = Color(1, 0.2, 0.2, 1)
const CHECKING_COLOR = Color(1, 1, 0.25)
const SPECIAL_COLOR = Color(1,1,1,1)
const MOVE_CHECKING_COLOR = Color(1, 0.392, 0.153)


static var selected: Tile = null
static var en_passant: Tile = null

var occupant: Piece = null:
	set(new_occupant):
		if occupant:
			occupant.controller.clicked.disconnect(Callable(self, "_on_occupant_clicked"))
		if new_occupant:
			new_occupant.controller.clicked.connect(Callable(self, "_on_occupant_clicked"))
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
		board_position = Vector2i(new_index/Board.file_count, new_index%Board.file_count)
	get():
		return get_index(rank,file)
#endregion

var controller: TileController

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
	return (file) + ((rank) * Board.file_count)

func _on_ready():
	match (file + rank) % 2:
		0: controller.tile_material.albedo_color = LIGHT_COLOR
		1: controller.tile_material.albedo_color = DARK_COLOR

	# $Tile_Modifiers.modifiers = modifier_order

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
	
func _on_stats_changed():
	controller.state_material.albedo_color.a = 0
	controller.state_material.emission_enabled = false
	
	if is_checked_movement:
		controller.state_material.albedo_color = MOVE_CHECKING_COLOR
	elif is_special:
		controller.state_material.albedo_color = SPECIAL_COLOR
		controller.state_material.emission_enabled = true
	elif is_checking:
		controller.state_material.albedo_color = CHECKING_COLOR
	elif is_checked:
		controller.state_material.albedo_color = CHECKED_COLOR	
	elif is_threatened:
		controller.state_material.albedo_color = THREATENED_COLOR
	elif is_selected:
		controller.state_material.albedo_color = SELECT_COLOR			
	elif is_movement:
		controller.state_material.albedo_color = VALID_COLOR

func clear_states():
	_unselect()
	_unthreaten()
	_hide_castling()
	is_checked_movement = false
	is_movement = false
