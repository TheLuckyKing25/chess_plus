class_name PieceObject
extends InteractableGameObject

signal player_changed(new_player:Player)
signal piece_type_changed(old_piece: PieceObject, new_piece: PieceObject)


@export var player_ownership: PlayerOwnershipComponent
@export var movement_component: MovementComponent
@export var rules_component: RulesComponent


static var en_passant: PieceObject = null


static var selection_mode: Constants.SelectionMode = Constants.SelectionMode.SINGLE


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
	name = name.get_slice("_",0)
	name += "_" + new_player.name.left(1)


func select_object():
	state.set_state(ObjectStateComponent.STATE_SELECTED)


func change_piece_type(scene_uid: StringName):
	var new_piece: PieceObject = load(scene_uid).instantiate()
	piece_type_changed.emit(self,new_piece)


#func evaluate_rules(current_changes: BoardChange) -> void:
	#for rule:PieceRule in type.rules:
		#rule.evaluate_rule_application(current_changes, self)
