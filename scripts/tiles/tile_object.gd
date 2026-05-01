class_name TileObject
extends Node3D

signal clicked(tile:TileObject)

const TILE_SCENE:PackedScene = preload("uid://cega76qfg50kj")

static var selected: TileObject = null
static var en_passant: TileObject = null

static var is_selected: bool:
	get():
		return selected != null

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
	get(): return occupant != null


var data: TileDataChess = TileDataChess.new()


static func new_tile(index: int):
	var new_tile_data:TileDataChess = TileDataChess.new()
	new_tile_data.index = index

	var new_tile:TileObject = TILE_SCENE.instantiate()
	new_tile.data = new_tile_data
	Match.add_tile(new_tile)
	return new_tile


func _ready() -> void:
	clicked.connect(Callable(self, "_on_tile_clicked"))
	data.connect_flag_components(Callable(self, "on_flags_changed"))
	data.modifier_order_changed.connect(Callable(self,"_on_tile_modifier_order_changed"))

	tile_material = $Tile_Mesh.material_override
	state_material = tile_material.next_pass
	state_material.albedo_color = Color(1,1,1,0)
	mouseover_material = state_material.next_pass

	set_tile_color(data.get_tile_color())


func set_tile_color(color: Color):
	tile_material.albedo_color = color

func set_state_color(color: Color, has_emission: bool = false):
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


func change(flag:String, enabled:bool):
	data.flag[flag].enabled = enabled
	if occupant and occupant.data.flag.has(flag):
		occupant.data.flag[flag].enabled = enabled


func on_flags_changed():
	state_material.albedo_color.a = 0
	state_material.emission_enabled = false

	if data.flag.is_checked_movement.enabled:
		set_state_color(data.MOVE_CHECKING_COLOR)


	elif data.flag.is_castling.enabled:
		set_state_color(data.CASTLING_COLOR, true)


	elif data.flag.is_checked.enabled:
		set_state_color(data.CHECKED_COLOR, true)


	elif data.flag.is_threatened.enabled:
		set_state_color(data.THREATENED_COLOR)


	elif data.flag.is_selected.enabled:
		set_state_color(data.SELECT_COLOR)


	elif data.flag.is_movement.enabled:
		set_state_color(data.VALID_COLOR)


func clear_flags():
	change("is_selected",false)
	change("is_threatened",false)
	change("is_castling",false)
	change("is_checked_movement", false)
	change("is_movement", false)


func clear_check_flag():
	change("is_checked",false)


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
		customization_tile_select()
	elif Match.current_game_state == Match.GameState.GAMEPLAY:
		gameplay_tile_select()

func customization_tile_select() -> void:
	if data.flag.is_selected.enabled == true:
		remove_from_group("Selected")
		change("is_selected",false)
	elif data.flag.is_selected.enabled == false:
		add_to_group("Selected")
		change("is_selected",true)

func gameplay_tile_select() -> void:
	if NetworkManager.is_online and not Match.is_my_turn():
		return
	# select clicked tile
	if (	not PieceObject.is_selected # no piece selected
			and is_occupied and occupant.is_in_group(Player.current.name) # occupant piece belongs to current player
			):
		Match.select_tile(self)

	elif PieceObject.is_selected and TileObject.is_selected: # object already selected
		if is_occupied: # Clicked Tile is occupied

			# Unselect currently selected piece
			if (	PieceObject.selected == occupant
					and TileObject.selected == self # Clicked tile and selected tile are the same
					):
				Match.unselect_tile()

			# Select a different piece
			elif occupant.is_in_group(Player.current.name): # occupant piece belongs to current player
				Match.unselect_tile()
				Match.select_tile(self)

			# capture opponent piece
			elif (	not occupant.is_in_group(Player.current.name) # occupant piece belongs to opponent
					and data.flag.is_threatened.enabled
					):
				Match.board.submit_move(TileObject.selected.data.index, data.index, Move.Outcome.CAPTURING)

		elif not is_occupied:
			# move selected piece to clicked tile
			if data.flag.is_movement.enabled:
				var ep_piece_idx: int = -1
				var ep_tile_idx: int = -1

				# set en passant if conditions are met
				if (	PieceObject.selected.is_in_group("Pawn")
						and not PieceObject.selected.data.flag.has_moved.enabled
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
