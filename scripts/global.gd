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
