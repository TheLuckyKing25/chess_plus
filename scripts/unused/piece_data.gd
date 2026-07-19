### Contains the data of a piece
### this data can change throughout a game.
### this is separate from the 3D piece.
#class_name PieceData
#extends Resource
#
#signal type_changed(new_type:PieceConfig)
#signal player_changed(new_player:PlayerData)
#signal captured
#
#
#@export var type: PieceConfig:
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
#
#
## movement used by modifiers
#var current_movement: AbstractMovement
#
#
#@export var player: PlayerData:
	#set(new_player):
		#player_changed.emit(new_player)
		#player = new_player
		#_apply_facing_direction_to_movement()
#
#
#var rank: int
#
#
#var file: int
#
#
#var index: int
#
#
#@export var position_vector: Vector2i:
	#set(value):
		#rank = value.x
		#file = value.y
	#get():
		#return Vector2i(rank,file)
#
#
#@export_custom(PROPERTY_HINT_NONE,"",PROPERTY_USAGE_NEVER_DUPLICATE) var assigned_object: PieceObject:
	#set(value):
		#assigned_object = value
#
#
#var has_moved: bool = false:
	#set(value):
		#has_moved = true
#
#var is_captured: bool = false:
	#set(value):
		#if value:
			#captured.emit()
		#is_captured = value
#
#
#func _init():
	#resource_local_to_scene = true
	#player_changed.connect(_on_player_changed)
#
#
#static func new_piece(piece_config: PieceConfig, new_index:int, max_move_distance:int) -> PieceData:
	#var piece: PieceData = PieceData.new()
	#var new_PIECE_DATA_INDEX: PieceConfig = piece_config.duplicate(true)
#
	#piece.type = new_PIECE_DATA_INDEX
	#var base_movement = piece.type.base_movement
	#base_movement.set_max_distance(GameData.max_board_length)
	#piece.type.base_movement = base_movement
	#piece.index = new_index
	#piece.resource_name = piece.type.name
#
	#return piece
#
#
#func assign_player(new_player:String):
	#player = GameData.players[new_player.to_lower()].data
#
#
#func _apply_facing_direction_to_movement():
	#if player and _adjusted_movement:
		#_adjusted_movement.set_facing_direction(player.facing_direction)
		#current_movement = _adjusted_movement.duplicate_deep()
#
#
#func _on_player_changed(player_data: PlayerData):
	#if player:
		#player.pieces.get(type.name.to_lower()).erase(self)
	#if player_data:
		#player_data.pieces.get_or_add(type.name.to_lower(),[]).append(self)
#
#
#func reset_current_movement():
	#current_movement = _adjusted_movement.duplicate_deep()
#
#
#func evaluate_rules(current_changes: BoardChange) -> void:
	#for rule:PieceRule in type.rules:
		#rule.evaluate_rule_application(current_changes, self)
#
#
## ===============================================================================
## ============================== [END OF REFACTOR] ==============================
## ===============================================================================
#
## Poison Tile variables
#var is_poisoned: bool = false
#var poison_turn_applied: int = -1
#var poison_duration: int = -1
