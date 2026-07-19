#class_name PlayerData
#extends Resource

#signal piece_list_changed()
#
#@export var player_name:String
#@export var color:Color
#
### determines which direction to face the piece object
#@export var parity: int:
	#set(value):
		#facing_direction = int(remap(value,-1,1,4,0)) as Constants.Direction
		#piece_rotation_parity = remap(value,-1,1,0,PI)
		#parity = value
#
### Used to rotate the movement of the piece
#var facing_direction: Constants.Direction
#
#
#var piece_rotation_parity: float
#
#
#@export_custom(PROPERTY_HINT_NONE,"",PROPERTY_USAGE_DEFAULT|PROPERTY_USAGE_NEVER_DUPLICATE) var assigned_object: Player
#
#
#@export var pieces:Dictionary[String,Array] = {}
#
#
## rank that a piece must reach to be promoted
#var promotion_rank: int
#
#
#var all_pieces: Array[PieceObject]:
	#get:
		#var array: Array[PieceObject] = []
		#for piece_configs in pieces.values():
			#array.append_array(piece_configs)
		#return array
