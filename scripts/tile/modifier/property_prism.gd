class_name PropertyPrism
extends TileModifier

func _init():
	flag = ModifierType.PROPERTY_PRISM
	can_modify_movement = true

func modify_movement(movement: Movement) -> void:
	if movement == null: 
		return
	if movement.distance <= 1:
		return
	if movement.is_branching:
		return
	
	var left_dir := (movement.direction + -1 + 8) % 8
	var right_dir := (movement.direction + 1 + 8) % 8
	var remaining_distance := movement.distance - 1
	
	var left_branch := Movement.new()
	left_branch.direction = left_dir
	left_branch.distance = remaining_distance
	left_branch.is_move = movement.is_move
	left_branch.is_threaten = movement.is_threaten
	left_branch.is_jump = movement.is_jump
	left_branch.is_castling = movement.is_castling
	left_branch.is_branching = false
	
	var right_branch := Movement.new()
	right_branch.direction = right_dir
	right_branch.distance = remaining_distance
	right_branch.is_move = movement.is_move
	right_branch.is_threaten = movement.is_threaten
	right_branch.is_jump = movement.is_jump
	right_branch.is_castling = movement.is_castling
	right_branch.is_branching = false
	
	movement.distance = 1
	movement.is_branching = true
	movement.branches = [left_branch, right_branch]
