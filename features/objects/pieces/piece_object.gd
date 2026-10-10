class_name PieceObject
extends InteractableGameObject

@warning_ignore("unused_signal")
signal player_changed(new_player:Player)
signal piece_type_changed(old_piece: PieceObject, new_piece: PieceObject)

static var unique_piece_id: int = 0

@export var player_ownership: PlayerOwnershipComponent
@export var movement_component: MovementComponent
@export var rules_component: RulesComponent


static var selection_mode: Constants.SelectionMode = Constants.SelectionMode.SINGLE


#var data_dict: Dictionary[StringName,Variant] = {
	#"name": name,
	#"owner": player_ownership.player,
	#"base_movement": movement_component.base_movement,
	#"rules": []
#}

## Objects that are in at least one group contained within this list
## can be threatened by the movement of this piece.
var threatenable_groups: Array[StringName] = [Constants.Groups.IS_OCCUPIED]


var rank_index: int


var file_index: int


var position_vector: Vector2i:
	set(value):
		rank_index = value.x
		file_index = value.y
	get:
		return Vector2i(rank_index,file_index)


var has_moved: bool:
	get: return is_in_group("hasMoved")


func _ready() -> void:
	super()
	player_ownership.player_changed.connect(_on_player_changed)
	_on_player_changed(player_ownership.player)


func _on_player_changed(new_player:Player):
	if not is_instance_valid(new_player):
		return
	mesh_component.set_main_color(new_player.color)
	rotation.y = new_player.piece_rotation_parity
	movement_component.base_movement.set_facing_direction(new_player.facing_direction)
	movement_component.reset_movement()
	name = "{0}_{1}_{2}".format([unique_piece_id,new_player.name.left(1),name.get_slice("_",0)])
	unique_piece_id += 1


func select_object():
	state.set_state(ObjectStateComponent.STATE_SELECTED)


func change_piece_type(new_piece: PieceObject):
	piece_type_changed.emit(self,new_piece)
