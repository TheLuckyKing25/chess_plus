class_name TileObject
extends Node3D

signal clicked(tile:TileObject)

# starts at 32 to prevent overlap with already existing notification constants
enum {
	NOTIFICATION_CLEAR_CHECK_STATE = 32,
	NOTIFICATION_CLEAR_OTHER_STATES = 33,
}

# Standard Tile Colors
const BASE_COLOR: Color = Color(0.75, 0.5775, 0.435, 1)
const LIGHT_COLOR: Color = BASE_COLOR * 4/3
const DARK_COLOR: Color = BASE_COLOR * 2/3 + Color(0,0,0,1)

const THREATENED_COLOR: Color = Color(1, 0.2, 0.2, 1)
const VALID_COLOR: Color = Color(0.6, 1, 0.6, 1)
const SELECT_COLOR: Color = Color(0.1, 1, 1, 1)
const CHECKED_COLOR: Color = Color(1, 0.2, 0.2, 1)
const CASTLING_COLOR: Color = Color(1,1,1,1)
const MOVE_CHECKING_COLOR: Color = Color(1, 0.392, 0.153)

const TILE_SCENE:PackedScene = preload("uid://clmimmf3c1qpt")

static var selected: TileObject = null
static var en_passant: TileObject = null

static var is_selected: bool:
	get():
		return selected != null

var _tile_color: Color:
	set(value):
		tile_material.albedo_color = value
	get:
		return tile_material.albedo_color


var tile_material: StandardMaterial3D

var state_material: StandardMaterial3D:
	get():
		return tile_material.next_pass

var mouseover_material: StandardMaterial3D:
	get():
		return state_material.next_pass


var occupant: PieceObject:
	set(value):
		if occupant:
			occupant.clicked.disconnect(Callable(self, "_on_occupant_clicked"))
		if value:
			value.clicked.connect(Callable(self, "_on_occupant_clicked"))
		data.occupant = value
	get():
		return data.occupant


var occupant_data: PieceData:
	get():
		return occupant.data


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
	get(): return occupant != null


var data: TileDataChess = TileDataChess.new():
	set(value):
		value.occupant_changed.connect(Callable(self,"_on_occupant_changed"))
		data = value


static func new_tile(index: int):
	var new_tile_data:TileDataChess = TileDataChess.new()
	new_tile_data.index = index

	var new_tile:TileObject = TILE_SCENE.instantiate()
	new_tile.data = new_tile_data
	Match.add_tile(new_tile)
	return new_tile

func _on_occupant_changed(new_occupant):
	pass

func _notification(what: int) -> void:
	if what == NOTIFICATION_CLEAR_CHECK_STATE:
		data.clear_check_flag()
	if what == NOTIFICATION_CLEAR_OTHER_STATES:
		data.clear_flags()


func _ready() -> void:
	clicked.connect(Callable(self, "_on_tile_clicked"))
	data.connect_flag_changed_components(Callable(self, "on_flags_changed"))
	data.modifier_order_changed.connect(Callable(self,"_on_tile_modifier_order_changed"))

	tile_material = $Tile_Mesh.material_override
	state_material.albedo_color = Color(1,1,1,0)

	_tile_color = _set_base_tile_color()

func _set_base_tile_color() -> Color:
	match (data.file + data.rank) % 2:
		0: return LIGHT_COLOR
		1: return DARK_COLOR
		_: return Color(0,0,0)


func _set_state_color(color: Color, has_emission: bool = false):
	state_material.albedo_color = color
	state_material.emission_enabled = has_emission

#region Player Interaction
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Select") and is_mouse_on_tile:
		clicked.emit(self)

func _on_occupant_clicked(piece: PieceObject):
	clicked.emit(self)


func _on_mouse_entered() -> void:
	is_mouse_on_tile = true
	mouseover_material.render_priority = 1
	mouseover_material.albedo_color = Color(1,1,1,0.25)


func _on_mouse_exited() -> void:
	mouseover_material.albedo_color = Color(1,1,1,0)
	mouseover_material.render_priority = 0
	is_mouse_on_tile = false
#endregion


func on_flags_changed():
	state_material.albedo_color.a = 0
	state_material.emission_enabled = false

	if data.flag.is_checked_movement.enabled:
		_set_state_color(MOVE_CHECKING_COLOR)

	elif data.flag.is_castling.enabled:
		_set_state_color(CASTLING_COLOR, true)

	elif data.flag.is_checked.enabled:
		_set_state_color(CHECKED_COLOR, true)

	elif data.flag.is_threatened.enabled:
		_set_state_color(THREATENED_COLOR)

	elif data.flag.is_selected.enabled:
		_set_state_color(SELECT_COLOR)

	elif data.flag.is_movement.enabled:
		_set_state_color(VALID_COLOR)


func _on_tile_modifier_order_changed():
	for child in %FlowContainer.get_children():
		%FlowContainer.remove_child(child)
		child.queue_free()

	var modifier_panel:PackedScene = load("uid://dmyh3g5g0c8ou")
	for modifier in data.modifier_order:
		var new_modifier = modifier_panel.instantiate()
		new_modifier.panel.bg_color = modifier.color
		new_modifier.set_icon(modifier.icon)
		%FlowContainer.add_child(new_modifier)


func get_next_tile(direction: Movement.Direction):
	return neighbors[direction]


#region Tile Clicked
func _on_tile_clicked(tile: TileObject) -> void:
	if Match.current_game_state == Match.GameState.BOARD_CUSTOMIZATION:
		_customization_tile_select()
	elif Match.current_game_state == Match.GameState.GAMEPLAY:
		_gameplay_tile_select()

func _customization_tile_select() -> void:
	if data.flag.is_selected.enabled == true:
		remove_from_group("Selected")
		data.change("is_selected",false)
	elif data.flag.is_selected.enabled == false:
		add_to_group("Selected")
		data.change("is_selected",true)

func _gameplay_tile_select() -> void:
	if NetworkManager.is_online and not Match.is_my_turn():
		return
	# select clicked tile
	if (
			not PieceObject.is_selected # no piece selected
			and is_occupied
			and occupant.is_in_group(Player.current.name) # occupant piece belongs to current player
		):
		Match.select_tile(self)

	elif PieceObject.is_selected and TileObject.is_selected: # object already selected
		if is_occupied: # Clicked Tile is occupied

			# Unselect currently selected piece
			if (
					GameController.selected.piece == occupant
					and TileObject.selected == self # Clicked tile and selected tile are the same
				):
				Match.unselect_tile()

			# Select a different piece
			elif occupant.is_in_group(Player.current.name): # occupant piece belongs to current player
				Match.unselect_tile()
				Match.select_tile(self)

			# capture opponent piece
			elif (
					not occupant.is_in_group(Player.current.name) # occupant piece belongs to opponent
					and data.flag.is_threatened.enabled
				):
				Match.board.submit_move(TileObject.selected.data.index, data.index, Move.Outcome.CAPTURING)

		elif not is_occupied:
			# move selected piece to clicked tile
			if data.flag.is_movement.enabled:
				var ep_piece_idx: int = -1
				var ep_tile_idx: int = -1

				# set en passant if conditions are met
				if (
						GameController.selected.piece.is_in_group("Pawn")
						and not GameController.selected.piece.data.flag.has_moved.enabled
						and abs(data.rank - TileObject.selected.data.rank) == 2 # Pawn piece has moved two tiles
						):
					Match.board._set_en_passant(self)
					ep_piece_idx = PieceObject.en_passant.data.index
					ep_tile_idx = TileObject.en_passant.data.index

				Match.board.submit_move(TileObject.selected.data.index, data.index, 0, ep_piece_idx, ep_tile_idx)

			# perform castling movement
			elif data.flag.is_castling.enabled:
				Match.board.submit_move(TileObject.selected.data.index, data.index, Move.Outcome.CASTLING_KINGSIDE | Move.Outcome.CASTLING_QUEENSIDE)

			# capture pawn via en passant
			elif (	data.flag.is_threatened.enabled
					and TileObject.en_passant == self
					and PieceObject.en_passant != null
					and not PieceObject.en_passant.is_in_group(Player.current.name)
					):
						Match.board.capture_piece(PieceObject.en_passant)
						Match.board.submit_move(TileObject.selected.data.index, data.index, Move.Outcome.CAPTURING | Move.Outcome.EN_PASSANT, PieceObject.en_passant.data.index, TileObject.en_passant.data.index)
#endregion
