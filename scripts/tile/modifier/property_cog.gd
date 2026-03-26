class_name PropertyCog
extends TileModifier

# The cog property changes the direction a piece is able to move in. Currently, this is temporary
# and the piece gains its normal movement back after moving off the piece.

@export var rotation: int = 90

func _init():
	flag = ModifierEnums.TileModifierFlag.PROPERTY_COG

func modify_moveset(board, piece, tile, moveset):
	if moveset == null:
		return moveset
	
	var duplicated: Movement = moveset.get_duplicate()
	var parity := int(rotation / 45)
	duplicated.set_direction_parity(parity)
	return duplicated
