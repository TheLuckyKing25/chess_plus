class_name GameNode3D

##region Tile Constants
#
#enum TileModifierFlag{
	#PROPERTY_COG = 1,
	#CONDITION_ICY = 2,
	#CONDITION_STICKY = 3,
	#PROPERTY_CONVEYER = 4,
	#PROPERTY_PRISM = 5,
	#}
##endregion


##region Game Colors Constants
### Color of a base tile which is lightened or darkened to make the board.
#
#const COLOR_PALETTE: Dictionary = {
	#"TILE_CONDITIONS_BACKGROUND_COLOR": Color(0,0,0),
	#"TILE_PROPERTIES_BACKGROUND_COLOR": Color(0,0,0)
#}
##endregion


## Settings that may or may not be implimented as game options
#region Settings
static var game_setting: Dictionary = {
	## You must move the first piece you select
	"TOUCH_MOVE": false, #Not implimented
}

static var debug_setting: Dictionary = {
	"DEBUG_RESTRICT_MOVEMENT": false,
	"DEBUG_SKIP_TITLE": false,
	"DEBUG_SKIP_MATCHSELECTION": false,
}

const USER_SETTING: Dictionary[String,float] = {
	"PIECE_OUTLINE_THICKNESS": 0.1,
	"CAMERA_ROTATION_SPEED": 5
}
#endregion


#var proceed = true
	#
	#if modifier_order.size() > 0:
		#proceed = _apply_modifiers()

#func _apply_modifiers():
	#var slide_direction: Direction = _moveset.direction
#
	#for modifier in modifier_order:
		#match modifier.flag:
			#TileModifierFlag.PROPERTY_COG:
				#if modifier.rotation == modifier.Rotation.CLOCKWISE:
					#_moveset.call_func_on_moves(Callable(_moveset,"rotate_clockwise"))
				#elif modifier.rotation == modifier.Rotation.COUNTERCLOCKWISE:
					#_moveset.call_func_on_moves(Callable(_moveset,"rotate_counterclockwise"))
			#TileModifierFlag.CONDITION_STICKY:
				## Prevents the piece from moving further,
				## but doesn't prevent movement if the piece is occupying the tile
				#_moveset.distance = 0
			#TileModifierFlag.CONDITION_ICY:
				#var neighboring_tile_occupant = neighboring_tiles[_moveset.direction].occupant
				#if ( 	not _moving_piece.is_in_group("Knight")
						#and neighboring_tiles[_moveset.direction]
						#and (
								#not neighboring_tile_occupant
								#or _moving_piece.is_opponent_to(neighboring_tile_occupant)
								#)
						#and _moving_piece == occupant
						#):
					#_connect_to_neighboring_tile(_moveset, slide_direction)
					#return false
			#TileModifierFlag.PROPERTY_CONVEYER:
				#_connect_to_neighboring_tile(_moveset, modifier.direction)
				#return false
			#TileModifierFlag.PROPERTY_PRISM:
				#pass
	#return true








#func change_piece_resources(old_piece: Node3D, new_piece: Piece_Type):
	#old_piece.find_child("Piece_Mesh").mesh = PIECE_MESH[new_piece]
	#old_piece.set_script(PIECE_SCRIPT[new_piece])
#
#func promote(piece:Piece, promotion: PawnPromotion):
	#var piece_player = piece.player
	#
	#match promotion:
		#PawnPromotion.ROOK:
			#change_piece_resources(piece,Piece_Type.ROOK)
			#piece.add_to_group("Rook")
		#PawnPromotion.BISHOP:
			#change_piece_resources(piece,Piece_Type.BISHOP)
			#piece.add_to_group("Bishop")
		#PawnPromotion.KNIGHT:
			#change_piece_resources(piece,Piece_Type.KNIGHT)
			#piece.add_to_group("Knight")
		#PawnPromotion.QUEEN:
			#change_piece_resources(piece,Piece_Type.QUEEN)
			#piece.add_to_group("Queen")
	#
	#piece.player = piece_player
	#piece.ready.emit()
