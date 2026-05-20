class_name TileObject
extends Node3D

#region Signals
signal clicked(tile:TileObject)
#endregion


#region Enums
# starts at 32 to prevent overlap with already existing notification constants
enum {
	NOTIFICATION_CLEAR_CHECK_STATE = 32,
	NOTIFICATION_CLEAR_OTHER_STATES = 33,
}
#endregion


#region Constants
# Standard Tile Colors
const BASE_COLOR: Color = Color(0.75, 0.5775, 0.435, 1)
const LIGHT_COLOR: Color = BASE_COLOR * 4/3
const DARK_COLOR: Color = BASE_COLOR * 2/3 + Color(0,0,0,1)


const TILE_SCENE:PackedScene = preload("uid://clmimmf3c1qpt")
#endregion


#region Static Variables
static var selection_mode: Constants.SelectionMode = Constants.SelectionMode.SINGLE


static var en_passant: TileObject = null
#endregion


#region Exported Variables
@export var state: TileStateComponent


@export var data: TileDataChess = TileDataChess.new():
	set(value):
		data.assigned_object = null
		value.assigned_object = self
		assign_new_data(value)
		data = value
#endregion


#region Public Variables
var occupant: PieceObject:
	set(value):
		if occupant and is_connected("clicked",Callable(self, "_on_occupant_clicked")):
			occupant.clicked.disconnect(Callable(self, "_on_occupant_clicked"))
		if value:
			value.clicked.connect(Callable(self, "_on_occupant_clicked"))
		data.occupant = value.data
	get():
		if data.occupant and data.occupant.assigned_object:
			return data.occupant.assigned_object
		else:
			return null


var occupant_data: PieceData:
	get():
		if occupant: return occupant.data
		else: return null


var is_occupied:bool:
	get(): return occupant != null


var neighbors: Dictionary[Constants.Direction, TileObject] = {
	Constants.Direction.NORTH: null,
	Constants.Direction.NORTHEAST: null,
	Constants.Direction.EAST: null,
	Constants.Direction.SOUTHEAST: null,
	Constants.Direction.SOUTH: null,
	Constants.Direction.SOUTHWEST: null,
	Constants.Direction.WEST: null,
	Constants.Direction.NORTHWEST: null,
}
#endregion


#region Private Variables
var _is_mouse_on_tile: bool = false


var _tile_color: Color:
	set(value):	_tile_material.albedo_color = value
	get: return _tile_material.albedo_color


var _tile_material: StandardMaterial3D:
	get(): return $Tile_Mesh.material_override


var _state_material: StandardMaterial3D:
	get(): return _tile_material.next_pass


var _mouseover_material: StandardMaterial3D:
	get(): return _state_material.next_pass
#endregion


#region Object Generation
static func new_tile_object() -> TileObject:
	var new_tile:TileObject = TILE_SCENE.instantiate()
	return new_tile


func assign_new_data(new_data:TileDataChess):
	_translate_tile(new_data) # move tile to proper location in 3D space
	_tile_color =  _set_base_tile_color(new_data) # set tile color

	# show modifiers


func _translate_tile(new_data: TileDataChess):
	var board_rank_count = GameData.match_settings.board_size.rank
	var board_file_count = GameData.match_settings.board_size.file
	position = (Vector3(
		new_data.file-(float(board_file_count)/2)+0.5,
		0.1,
		(float(board_rank_count)/2)-new_data.rank-0.5
	))


func _set_base_tile_color(new_data:TileDataChess) -> Color:
	match (new_data.file + new_data.rank) % 2:
		0: return LIGHT_COLOR
		1: return DARK_COLOR
		_: return Color(0,0,0)
#endregion


#region Player Interaction
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Select") and _is_mouse_on_tile:
		if occupant:
			occupant.clicked.emit(occupant)
		else:
			clicked.emit(self)


func _on_occupant_clicked(piece: PieceObject):
	clicked.emit(self)


func _on_mouse_entered() -> void:
	_is_mouse_on_tile = true
	_mouseover_material.render_priority = 1
	_mouseover_material.albedo_color = Color(1,1,1,0.25)


func _on_mouse_exited() -> void:
	_mouseover_material.albedo_color = Color(1,1,1,0)
	_mouseover_material.render_priority = 0
	_is_mouse_on_tile = false


func _on_tile_clicked(tile: TileObject) -> void:
	match selection_mode:
		Constants.SelectionMode.MULTIPLE: _multiple_tile_select()
		Constants.SelectionMode.SINGLE: _single_tile_select()


func _multiple_tile_select() -> void:
	state.set_state(TileStateComponent.Type.SELECTED)


func _single_tile_select() -> void:
	state.set_state(TileStateComponent.Type.SELECTED)

#endregion


func set_state_color(color: Color, has_emission: bool = false) -> void:
	_state_material.albedo_color = color
	_state_material.emission_enabled = has_emission
	_state_material.emission = color




#func _single_tile_select() -> void:
	#if NetworkManager.is_online and not Match.is_my_turn():
		#return
#
	## select clicked tile
	#if (
			#not PieceObject.is_selected # no piece selected
			#and is_occupied
			#and occupant.is_in_group(Player.current.name) # occupant piece belongs to current player
		#):
		#Match.select_tile(self)
#
	#elif PieceObject.is_selected and TileObject.is_selected: # object already selected
		#if is_occupied: # Clicked Tile is occupied
#
			## Unselect currently selected piece
			#if (
					#PieceObject.selected == occupant
					#and TileObject.selected == self # Clicked tile and selected tile are the same
				#):
				#Match.unselect_tile()
#
			## Select a different piece
			#elif occupant.is_in_group(Player.current.name): # occupant piece belongs to current player
				#Match.unselect_tile()
				#Match.select_tile(self)
#
			## capture opponent piece
			#elif (
					#not occupant.is_in_group(Player.current.name) # occupant piece belongs to opponent
					#and data.flag.is_threatened.enabled
				#):
				#Match.board.submit_move(TileObject.selected.data.index, data.index, Move.Outcome.CAPTURING)
#
		#elif not is_occupied:
			## move selected piece to clicked tile
			#if data.flag.is_movement.enabled:
				#var ep_piece_idx: int = -1
				#var ep_tile_idx: int = -1
#
				## set en passant if conditions are met
				#if (
						#PieceObject.selected.is_in_group("Pawn")
						#and not PieceObject.selected.data.flag.has_moved.enabled
						#and abs(data.rank - TileObject.selected.data.rank) == 2 # Pawn piece has moved two tiles
						#):
					#Match.board._set_en_passant(self)
					#ep_piece_idx = PieceObject.en_passant.data.index
					#ep_tile_idx = TileObject.en_passant.data.index
#
				#Match.board.submit_move(TileObject.selected.data.index, data.index, 0, ep_piece_idx, ep_tile_idx)
#
			## perform castling movement
			#elif data.flag.is_castling.enabled:
				#Match.board.submit_move(TileObject.selected.data.index, data.index, Move.Outcome.CASTLING_KINGSIDE | Move.Outcome.CASTLING_QUEENSIDE)
#
			## capture pawn via en passant
			#elif (	data.flag.is_threatened.enabled
					#and TileObject.en_passant == self
					#and PieceObject.en_passant != null
					#and not PieceObject.en_passant.is_in_group(Player.current.name)
					#):
						#Match.board.capture_piece(PieceObject.en_passant)
						#Match.board.submit_move(TileObject.selected.data.index, data.index, Move.Outcome.CAPTURING | Move.Outcome.EN_PASSANT, PieceObject.en_passant.data.index, TileObject.en_passant.data.index)






#static func new_tile(index: int) -> TileObject:
	#var new_tile_data:TileDataChess = TileDataChess.new()
	#new_tile_data.index = index
#
	#var new_tile:TileObject = TILE_SCENE.instantiate()
	#new_tile.data = new_tile_data
	#Match.add_tile(new_tile)
	#return new_tile


func _on_occupant_changed(new_occupant):
	pass


func _notification(what: int) -> void:
	if what == NOTIFICATION_CLEAR_CHECK_STATE:
		data.clear_check_flag()
	if what == NOTIFICATION_CLEAR_OTHER_STATES:
		state.current = TileStateComponent.Type.NONE


func _ready() -> void:
	assign_new_data(data)
	clicked.connect(Callable(self, "_on_tile_clicked"))
	data.modifier_order_changed.connect(Callable(self,"_on_tile_modifier_order_changed"))

	state.current = TileStateComponent.Type.NONE


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


func get_next_tile(direction: Constants.Direction):
	return neighbors[direction]
