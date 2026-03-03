extends Node3D

func print_array(array, indent:int = 0):
	for item in array:
		if typeof(item) == TYPE_ARRAY:
			print("\t".repeat(indent),"[")
			print_array(item, indent+1)
			print("\t".repeat(indent), "],")
		elif item is Movement:
			print("\t".repeat(indent), "{")
			print_rule(item, indent+1)
			print("\t".repeat(indent), "},")
		else:
			print("\t".repeat(indent), item ,", ")
	
func print_rule(rule, indent:int = 0):
	print("\t".repeat(indent),"{")
	print_better(rule.move_flags, indent+1)
	print_better(rule.distance, indent+1)
	print_better(rule.direction, indent+1)
	print_better(rule.branches, indent+1)
	print("\t".repeat(indent), "}")

func print_better(tree,indent:int = 0):
	if tree is Movement:
		print("\t".repeat(indent),"{")
		print_rule(tree,indent+1)
		print("\t".repeat(indent),"}")
	elif typeof(tree) == TYPE_ARRAY:
		print("\t".repeat(indent),"[")
		print_array(tree,indent+1)
		print("\t".repeat(indent),"]")
	else:
		print("\t".repeat(indent), tree)



#region Bit Flag Manipulation

var Flag:	Dictionary[String,Callable] = {
	"set_func": Callable(self,"set_flag"),
	"unset_func": Callable(self,"unset_flag"),
	"toggle_func": Callable(self,"toggle_flag"),
	"is_enabled_func": Callable(self,"flag_is_enabled"),
}

func unset_flag(bitfield: int, flag: int) -> int:
	bitfield &= ~(1 << flag)
	return bitfield
	

func set_flag(bitfield: int, flag: int) -> int:
	bitfield |= 1 << flag
	return bitfield


func toggle_flag(bitfield: int, flag: int) -> int:
	bitfield ^= 1 << flag
	return bitfield
	
func flag_is_enabled(bitfield: int, flag: int) -> bool:
	return bitfield & (1 << flag)

#endregion
