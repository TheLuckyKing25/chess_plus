class_name MoveRule


# If Jump and Threaten are set at the same time, then the moverule will checking threaten validity then continue through tile 
enum MoveType{ 
		NONE = 0,			# Unsets all flags
		
		JUMP = 1 << 0, 		# Continue through tile
		MOVEMENT = 1 << 1, 	# Tile unoccupied
		THREATEN = 1 << 2,  # Tile occupied by opponent
		CASTLING = 1 << 3,	# used to find rook and to check if space between king and rook is clear

		
		SPECIAL = 1 << 4,	# Used for special movements, flag set on last moverule of a branch
		BRANCH = 1 << 5,	# Branch from tile, flag set on last moverule of a branch
		
		CHECK = 1 << 6,		# used for check detection
	}



var move_flags:int = 0
var distance: int = 0
var direction:
	set(cardinal):
		if cardinal <= -1:
			direction = -1
		direction = cardinal % 8
var branches: Array


func _init(flags: int, move_distance = -1, move_direction = -1, move_branches = []):
	move_flags = flags
	distance = move_distance
	direction = move_direction
	branches = move_branches

func set_move_flag(flag: MoveType):
	move_flags |= flag
	
	if flag & MoveType.MOVEMENT:
		unset_move_flag(MoveType.JUMP)
	elif flag & MoveType.JUMP:
		unset_move_flag(MoveType.MOVEMENT)


func toggle_move_flag(flag: MoveType):
	move_flags ^= flag

	
func move_flag_is_enabled(flag: MoveType):
	return move_flags & flag


func unset_move_flag(flag: MoveType):
	move_flags &= ~flag


func decode_into_movement():
	var movement = []
	if (	move_flag_is_enabled(MoveType.MOVEMENT) 
			or move_flag_is_enabled(MoveType.THREATEN)
			or move_flag_is_enabled(MoveType.JUMP)
			or move_flag_is_enabled(MoveType.CASTLING)
			):
		movement.append_array(extend_moverule())

	if move_flag_is_enabled(MoveType.SPECIAL):
		if movement.size() > 0:
			movement.back().set_move_flag(MoveType.SPECIAL)
	
	if move_flag_is_enabled(MoveType.BRANCH):
		var movement_branches = decode_branches()
		if movement.size() > 0:
			movement.back().set_move_flag(MoveType.BRANCH)
			movement.back().branches = movement_branches
		else:
			branches = movement_branches
			return self
	return movement
	
func decode_branches():
	var decoded_branches = []
	for moverule in branches:
		if move_flag_is_enabled(MoveType.CHECK):
			moverule.set_move_flag(MoveType.CHECK)
		else:
			moverule.unset_move_flag(MoveType.CHECK)
		decoded_branches.append(moverule.decode_into_movement())
	return decoded_branches

func extend_moverule():
	var movement_extended = []
	var new_move_flags = move_flags&~(MoveType.SPECIAL|MoveType.BRANCH)
	movement_extended.resize(distance)	
	for index in range(0,distance):
		movement_extended[index] = MoveRule.new(new_move_flags,-1,direction)
	return movement_extended
