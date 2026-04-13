class_name PropertyCog
extends TileModifier

# The cog property changes the direction a piece is able to move in. Currently, this is temporary
# and the piece gains its normal movement back after moving off the piece.

func _init():
	name = "Cog"
	flag = ModifierType.PROPERTY_COG
	color = Color(0.77,0.42,0)
	icon = load("uid://rpbtfnubhk8n")
	can_modify_movement = true
	components[RotationComponent.NAME] = RotationComponent.new()

func modifier_strategy(current_move:CustomTreeNode):
	if current_move.remaining_movement == null:
		return
	current_move.remaining_movement.rotate_movement(components[RotationComponent.NAME].value)


func modify_movement(movement: Movement):
	if movement == null:
		return
	else:
		movement.rotate_movement(components[RotationComponent.NAME].value)
