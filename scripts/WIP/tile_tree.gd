class_name TileTree
extends Resource

var root_item: TileTreeItem

func convert_movement_to_tree(starting_tile:TileObject, movement:Movement):
	root_item = TileTreeItem.new(starting_tile)
	if movement.is_branching and movement.distance == 0:
		for branch in movement.branches:
			convert_branch_to_tree(root_item,branch)

func convert_branch_to_tree(root:TileTreeItem, branch:Movement):
	var item_ptr: TileTreeItem = root
	while branch.distance > 0:
		if item_ptr.tile.neighbors[branch.direction] != null:
			var new_child = TileTreeItem.new(item_ptr.tile.neighbors[branch.direction])
			item_ptr.add_child(new_child)
			item_ptr = new_child
			branch.distance -= 1
		else:
			break

	if branch.is_branching and branch.distance == 0:
		for new_branch in branch.branches:
			convert_branch_to_tree(root, new_branch)

func extract_movelist_from_tree():

	pass


func extract_move_from_item():
	pass
