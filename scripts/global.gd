extends Node

func print_array(array, indent:int = 0):
	for item in array:
		if typeof(item) == TYPE_ARRAY:
			print("\t".repeat(indent),"[")
			print_array(item, indent+1)
			print("\t".repeat(indent), "],")
		elif typeof(item) == TYPE_DICTIONARY:
			print("\t".repeat(indent), "{")
			print_dict(item, indent+1)
			print("\t".repeat(indent), "},")
		else:
			print("\t".repeat(indent), item ,", ")
	
func print_dict(dict, indent:int = 0):
	for item in dict:
		if typeof(dict[item]) == TYPE_ARRAY:
			print("\t".repeat(indent), item ,": [")
			print_array(dict[item], indent+1)
			print("\t".repeat(indent), "]")
		elif typeof(dict[item]) == TYPE_DICTIONARY:
			print("\t".repeat(indent), item ,": {")
			print_dict(dict[item], indent+1)
			print("\t".repeat(indent), "}")
		else:
			print("\t".repeat(indent), item ,": ", dict[item])

func print_better(tree):
	if typeof(tree) == TYPE_DICTIONARY:
		print("{")
		print_dict(tree,1)
		print("}")
	elif typeof(tree) == TYPE_ARRAY:
		print("[")
		print_array(tree,1)
		print("]")
	else:
		print(tree)

#func print_move() -> void:
		#print(
			#"%10s" % Piece.selected.object.name 
			#+ " moves from " 
			#+ Piece.selected.on_tile.object_tile.name 
			#+ " to " 
			#+ Tile.selected.object_tile.name
		#)
