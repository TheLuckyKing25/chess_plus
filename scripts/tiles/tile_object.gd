class_name TileObject
extends Node3D

signal clicked(tile:TileObject)

const TILE_SCENE:PackedScene = preload("uid://cega76qfg50kj")

static var selected: TileObject = null
static var en_passant: TileObject = null

var tile_material: StandardMaterial3D
var mouseover_material: StandardMaterial3D
var state_material: StandardMaterial3D

var occupant: PieceObject = null:
	set(new_occupant):
		if occupant:
			occupant.clicked.disconnect(Callable(self, "_on_occupant_clicked"))
		if new_occupant:
			new_occupant.clicked.connect(Callable(self, "_on_occupant_clicked"))
		occupant = new_occupant

var neighbors: Dictionary[Movement.Direction, TileObject] = {
	Movement.Direction.NORTH: null,
	Movement.Direction.NORTHEAST: null,
	Movement.Direction.EAST: null,
	Movement.Direction.SOUTHEAST: null,
	Movement.Direction.SOUTH: null,
	Movement.Direction.SOUTHWEST: null,
	Movement.Direction.WEST: null,
	Movement.Direction.NORTHWEST: null,
}


var is_mouse_on_tile: bool = false

var is_occupied:bool:
	get():
		return occupant != null

var is_blocked:bool:
	get():
		return is_occupied and occupant.data.player == Player.current

var can_perform_capture: bool:
	get():
		return occupant != null and occupant.data.player != Player.current

var data: TileDataChess = TileDataChess.new()

static func new_tile(index: int):
	var new_tile_data:TileDataChess = TileDataChess.new()
	new_tile_data.index = index

	var new_tile:TileObject = TILE_SCENE.instantiate()
	new_tile.data = new_tile_data
	Match.add_tile(new_tile)
	return new_tile



func _ready() -> void:
	data.changed.connect(Callable(self, "_on_stats_changed"))
	data.modifier_order_changed.connect(Callable(self,"_on_tile_modifier_order_changed"))

	tile_material = $Tile_Mesh.material_override
	state_material = tile_material.next_pass
	state_material.albedo_color = Color(1,1,1,0)
	mouseover_material = state_material.next_pass

	match (data.file + data.rank) % 2:
		0: tile_material.albedo_color = TileDataChess.LIGHT_COLOR
		1: tile_material.albedo_color = TileDataChess.DARK_COLOR


func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if (	is_mouse_on_tile
			and event is InputEventMouseButton
			and event.is_pressed()
			and event.button_index == MOUSE_BUTTON_LEFT
			):
		clicked.emit(self)


func _on_occupant_clicked(piece: PieceObject):
	clicked.emit(self)


#region Mouse Over
func _on_mouse_entered() -> void:
	is_mouse_on_tile = true
	mouseover_material.render_priority = 1
	mouseover_material.albedo_color = Color(1,1,1,0.25)


func _on_mouse_exited() -> void:
	mouseover_material.albedo_color = Color(1,1,1,0)
	mouseover_material.render_priority = 0
	is_mouse_on_tile = false
#endregion


func tile_checked_movement():
	state_material.albedo_color = data.MOVE_CHECKING_COLOR
	state_material.emission_enabled = false

#region States
func _select():
	data.is_selected = true
	if occupant:
		occupant.data.is_selected = true

func _unselect():
	data.is_selected = false
	if occupant:
		occupant.data.is_selected = false

func _threaten():
	data.is_threatened = true
	if occupant:
		occupant.data.is_threatened = true

func _unthreaten():
	data.is_threatened = false
	if occupant:
		occupant.data.is_threatened = false

func _show_castling():
	data.is_castling = true
	if occupant:
		occupant.data.is_castling = true

func _hide_castling():
	data.is_castling = false
	if occupant:
		occupant.data.is_castling = false

func _set_check():
	data.is_checked = true
	if occupant:
		occupant.data.is_checked = true

func _unset_check():
	data.is_checked = false
	if occupant:
		occupant.data.is_checked = false
#endregion

func _on_stats_changed():
	state_material.albedo_color.a = 0
	state_material.emission_enabled = false

	if data.is_checked_movement:
		state_material.albedo_color = data.MOVE_CHECKING_COLOR
	elif data.is_castling:
		state_material.albedo_color = data.CASTLING_COLOR
		state_material.emission_enabled = true
	elif data.is_checking:
		state_material.albedo_color = data.CHECKING_COLOR
	elif data.is_checked:
		state_material.albedo_color = data.CHECKED_COLOR
	elif data.is_threatened:
		state_material.albedo_color = data.THREATENED_COLOR
	elif data.is_selected:
		state_material.albedo_color = data.SELECT_COLOR
	elif data.is_movement:
		state_material.albedo_color = data.VALID_COLOR

func clear_states():
	_unselect()
	_unthreaten()
	_hide_castling()
	data.is_checked_movement = false
	data.is_movement = false

func _on_tile_modifier_order_changed():
	for child in %FlowContainer.get_children():
		%FlowContainer.remove_child(child)

	var modifier_panel:PackedScene = load("uid://dmyh3g5g0c8ou")
	for modifier in data.modifier_order:
		var new_modifier = modifier_panel.instantiate()
		new_modifier.panel.bg_color = modifier.color
		new_modifier.set_icon(modifier.icon)
		%FlowContainer.add_child(new_modifier)
