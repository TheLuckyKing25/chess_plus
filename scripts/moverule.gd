class_name MoveRule
extends Game


var action_flags: int = 0


var purpose: PurposeType = 0


var distance: int = 0


var direction:
	set(cardinal):
		if cardinal <= -1:
			direction = -1
		direction = cardinal % 8


var branches: Array

func rotate_clockwise():
	direction = direction + 1

func _init(
			actions: int, 
			moveset_purpose: PurposeType = PurposeType.UNSET, 
			move_distance = -1, 
			move_direction = -1, 
			move_branches = []
	):
	action_flags = actions
	purpose = moveset_purpose
	distance = move_distance
	direction = move_direction
	branches = move_branches


#func _decode_branches():
	#var decoded_branches = []
	#for moverule in branches:
		#moverule.purpose = purpose
		#decoded_branches.append(moverule.decode_into_movement())
	#return decoded_branches


#func _extend_moverule():
	#var movement_extended = []
	#var new_action_flags = action_flags&~(ActionType.SPECIAL|ActionType.BRANCH)
	#movement_extended.resize(distance)	
	#for index in range(0,distance):
		#movement_extended[index] = MoveRule.new(new_action_flags, purpose, -1, direction)
	#return movement_extended

func new():
	return MoveRule.new(action_flags,purpose,distance,direction,branches)

#func decode_into_movement():
	#var movement = []
	#if (	
			#action_flag_is_enabled(ActionType.MOVE) 
			#or action_flag_is_enabled(ActionType.THREATEN)
			#or action_flag_is_enabled(ActionType.JUMP)
	#):
		#movement.append_array(_extend_moverule())
#
	#if action_flag_is_enabled(ActionType.SPECIAL):
		#if movement.size() > 0:
			#movement.back().set_action_flag(ActionType.SPECIAL)
	#
	#if action_flag_is_enabled(ActionType.BRANCH):
		#var movement_branches = _decode_branches()
		#if movement.size() > 0:
			#movement.back().set_action_flag(ActionType.BRANCH)
			#movement.back().branches = movement_branches
		#else:
			#branches = movement_branches
			#return self
	#return movement


#region Manipulating Action Flags
func set_action_flag(flag: ActionType):
	action_flags |= flag
	
	if flag & ActionType.MOVE:
		unset_action_flag(ActionType.JUMP)
	elif flag & ActionType.JUMP:
		unset_action_flag(ActionType.MOVE)


func toggle_action_flag(flag: ActionType):
	action_flags ^= flag

	
func action_flag_is_enabled(flag: ActionType):
	return action_flags & flag


func unset_action_flag(flag: ActionType):
	action_flags &= ~flag
#endregion


func is_checking_movement():
	return purpose == PurposeType.CHECK_DETECTING


func is_branching_movement():
	return action_flag_is_enabled(ActionType.BRANCH)


func is_finding_castling_rook():
	return purpose == PurposeType.ROOK_FINDING


func is_threatening():
	return action_flag_is_enabled(ActionType.THREATEN)


func is_castling_movement():
	return (	
			purpose == PurposeType.CASTLING
			and action_flag_is_enabled(ActionType.JUMP)
	)


func is_jumping():
	return action_flag_is_enabled(ActionType.JUMP)
