class_name TileObject
extends InteractableGameObject


#region Signals
signal modifier_order_changed()
#endregion


#region Enums

#endregion


#region Constants
const BASE_COLOR: Color = Color(0.75, 0.5775, 0.435, 1)
const LIGHT_COLOR: Color = BASE_COLOR * 4/3
const DARK_COLOR: Color = BASE_COLOR * 2/3 + Color(0,0,0,1)
#endregion


#region Static Variables
static var selection_mode: Constants.SelectionMode = Constants.SelectionMode.SINGLE

static var en_passant: TileObject = null
#endregion


#region Exported Variables
@export var occupant_component: OccupantComponent

var occupant: InteractableGameObject:
	set(value): occupant_component.occupant = value
	get: return occupant_component.occupant
#endregion


#region Public Variables
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

var rank: int


var file: int


var index: int


@export var position_vector: Vector2i:
	set(value):
		rank = value.x
		file = value.y
	get():
		return Vector2i(rank,file)
#endregion


func set_position_data(index:int, vector: Vector2i) -> void:
	self.index = index
	rank = vector.x
	file = vector.y
	_set_base_tile_color() # set tile color


#region Private Variables
var _original_position_in_space: Vector3
#endregion


func _ready() -> void:
	super()
	occupant_component.occupant_clicked.connect(_on_clicked)
	modifier_order_changed.connect(Callable(self,"_on_tile_modifier_order_changed"))


#region Object Generation
func _translate_tile():
	var board_rank_count = GameData.match_settings.board_size.rank
	var board_file_count = GameData.match_settings.board_size.file
	position = (Vector3(
		file-(float(board_file_count)/2)+0.5,
		0.1,
		(float(board_rank_count)/2)-rank-0.5
	))
	_original_position_in_space = position


func _set_base_tile_color() -> void:
	match (file + rank) % 2:
		0: mesh_component.set_main_color(LIGHT_COLOR)
		1: mesh_component.set_main_color(DARK_COLOR)
		_: mesh_component.set_main_color(Color(0,0,0))
#endregion


#region Player Interaction
func select_object():
	match selection_mode:
		Constants.SelectionMode.MULTIPLE: _multiple_tile_select()
		Constants.SelectionMode.SINGLE: _single_tile_select()

	if is_instance_valid(occupant):
		occupant.select_object()


func _multiple_tile_select() -> void:
	state.set_state(ObjectStateComponent.STATE_SELECTED)


func _single_tile_select() -> void:
	state.set_state(ObjectStateComponent.STATE_SELECTED)

#endregion


var modifier_order: Array[TileModifier] = []:
	set(new_order):
		modifier_order = new_order
		modifier_order_changed.emit()

#region Position
var algebraic_notation: String:
	get(): return char(97 + rank) + str((1 + file))
#endregion

# ===============================================================================
# ============================== [END OF REFACTOR] ==============================
# ===============================================================================


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


func _on_tile_modifier_order_changed():
	for child in %FlowContainer.get_children():
		%FlowContainer.remove_child(child)
		child.queue_free()

	var modifier_panel:PackedScene = load("uid://dmyh3g5g0c8ou")
	#for modifier in data.modifier_order:
		#var new_modifier = modifier_panel.instantiate()
		#new_modifier.panel.bg_color = modifier.color
		#new_modifier.set_icon(modifier.icon)
		#%FlowContainer.add_child(new_modifier)
	pass
