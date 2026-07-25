class_name PieceObject
extends InteractableGameObject

signal type_changed(new_type:PieceConfig)
signal player_changed(new_player:Player)
#signal captured


@export var player_ownership: PlayerOwnershipComponent
@export var movement_component: MovementComponent


const PIECE_SCENE:PackedScene = preload("uid://dnismskxjehm6")


const THREATENED_COLOR:= Color(0.9, 0, 0, 1)
const CHECKING_COLOR:= Color(0.9, 0.9, 0)
const SELECT_COLOR:= Color(0, 0.9, 0.9, 1)
const CHECKED_COLOR:= Color(0.9, 0, 0, 1)
const CASTLING_COLOR:= Color(1,1,1,1)


static var en_passant: PieceObject = null


static var selection_mode: Constants.SelectionMode = Constants.SelectionMode.SINGLE


#var type: PieceConfig:
	#set(value):
		#if is_instance_valid(type):
			#type.base_movement_changed.disconnect(func(): set("_adjusted_movement",type.base_movement))
		#if is_instance_valid(value):
			#value.base_movement_changed.connect(func(): set("_adjusted_movement",value.base_movement))
		#type_changed.emit(value)
		#_adjusted_movement = value.base_movement.duplicate(true)
		#type = value
#
#
## movement that accounts for the player the piece belongs to.
## used to reset current_movement
#var _adjusted_movement: AbstractMovement:
	#set(value):
		#_adjusted_movement = value
		#_apply_facing_direction_to_movement()
	#get:
		#return _adjusted_movement


# movement used by modifiers
var current_movement: AbstractMovement

var rank: int


var file: int


var index: int


var position_vector: Vector2i:
	set(value):
		rank = value.x
		file = value.y
	get():
		return Vector2i(rank,file)

var has_moved: bool:
	get: return is_in_group("Moved")


#var is_captured: bool = false:
	#set(value):
		#if value:
			#captured.emit()
		#is_captured = value


#func _apply_facing_direction_to_movement():
	#if player_ownership.player and _adjusted_movement:
		#_adjusted_movement.set_facing_direction(player_ownership.player.facing_direction)
		#current_movement = _adjusted_movement.duplicate_deep()


func _ready() -> void:
	super()
	player_ownership.player_changed.connect(_on_player_changed)
	_on_player_changed(player_ownership.player)


#region Piece Object Generation
func _on_player_changed(new_player:Player):
	if not is_instance_valid(new_player):
		return
	mesh_component.set_main_color(new_player.color)
	rotation.y = new_player.piece_rotation_parity
	movement_component.base_movement.set_facing_direction(new_player.facing_direction)
	movement_component.reset_movement()
	name = name.get_slice("_",0)
	name += "_" + new_player.name.left(1)


#func _on_captured():
	#get_parent().remove_child(self)
	#hide()
#endregion

func select_object():
	state.set_state(ObjectStateComponent.STATE_SELECTED)


#func assign_player(new_player:String):
	#player = GameData.players[new_player.to_lower()].data


#func _on_player_changed(player_data: PlayerData):
	#if player:
		#player.pieces.get(type.name.to_lower()).erase(self)
	#if player_data:
		#player_data.pieces.get_or_add(type.name.to_lower(),[]).append(self)


#func evaluate_rules(current_changes: BoardChange) -> void:
	#for rule:PieceRule in type.rules:
		#rule.evaluate_rule_application(current_changes, self)



#func _on_data_changed(new_data:PieceObject):
	#_unload_data(data)
	#_load_data(new_data)
	#_on_type_changed(new_data.type)
	#_on_player_changed(new_data.player)


#func _unload_data(old_data: PieceObject):
	#if old_data:
		## disconnect signals from old data
		#if old_data.is_connected("type_changed",Callable(self,"_on_type_changed")):
			#old_data.type_changed.disconnect(Callable(self,"_on_type_changed"))
		#if old_data.is_connected("player_changed",Callable(self,"_on_type_changed")):
			#old_data.player_changed.disconnect(Callable(self,"_on_player_changed"))
		##old_data.disconnect_flag_components(Callable(self,"apply_state"))
#
		## clear connection between object and old data
		#old_data.assigned_object = null
#
#
#func _load_data(new_data: PieceObject):
	#if new_data:
		## connect signals from new data
		#new_data.type_changed.connect(Callable(self,"_on_type_changed"))
		#new_data.player_changed.connect(Callable(self,"_on_player_changed"))
		#new_data.captured.connect(_on_captured)
#
		## connect this object and the new data
		#new_data.assigned_object = self
#
		#mesh_component.set_outline_color(Color(0,0,0,0))


#func _on_type_changed(new_type:PieceConfig):
	#if data and data.type:
		#remove_from_group(data.type.name)
	#if new_type and mesh_component:
		#mesh_component.mesh = new_type.object_mesh
		#add_to_group(new_type.name)
