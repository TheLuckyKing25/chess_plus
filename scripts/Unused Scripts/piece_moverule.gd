#class_name MoveRule
#extends GameNode3D
#
#
#var action_flags: int = 0
#
#
#var distance: int = 0
#
#
#var direction:
	#set(cardinal):
		#if cardinal <= -1:
			#direction = -1
		#direction = cardinal % 8
#
#
#var branches: Array
#
#
#func _init(
			#actions: int, 
			#moveset_purpose: PurposeType = PurposeType.UNSET, 
			#move_distance:int = 0, 
			#move_direction = -1, 
			#move_branches:Array = []
			#):
	#action_flags = actions
	#purpose = moveset_purpose
	#distance = move_distance
	#direction = move_direction
	#branches = move_branches
#
#
#
#func call_func_on_moves(function: Callable):
		#if action_flags == ActionType.BRANCH:
			#for move in branches:
				#move.call_func_on_moves(Callable(move,function.get_method()))
		#elif action_flag_is_enabled(ActionType.BRANCH):
			#for move in branches:
				#move.call_func_on_moves(Callable(move,function.get_method()))
			#function.call()
		#else:
			#function.call()
#
#
#func rotate_clockwise():
	#direction = direction + 1
	#
	#
#func rotate_counterclockwise():
	## This is set to +7 instead of -1 
	## because it prevents negative numbers from being used as array indices 
	## and because they represent the same number modulo 8
	#direction = direction + 7
	#
	#
#func new_duplicate():
	#var new_branches: Array = []
	#if action_flag_is_enabled(ActionType.BRANCH):
		#for move in branches:
			#new_branches.append(move.new_duplicate())
	#return MoveRule.new(action_flags,purpose,distance,direction,new_branches)
