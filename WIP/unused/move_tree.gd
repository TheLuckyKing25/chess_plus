@tool
class_name MoveTree extends Resource

var root_item: MoveTreeItem
@export var move_list: Array[String]

func convert_movement_to_tree(root_tile: Tile, movement:AbstractMovement):
	var root: MoveTreeItem = MoveTreeItem.new()
	root.position_vector = root_tile.position.vector
	root_item = root
	if movement is BranchingMovement:
		for branch in movement.branches:
			root_item.add_child(construct_children(root_item,branch))
	extract_move_from_item(root_item)

func construct_children(parent:MoveTreeItem, movement:AbstractMovement):
	var new_item: MoveTreeItem = MoveTreeItem.new()

	if movement is SlidingMovement:
		if movement.distance > 0:
			new_item.position_vector = parent.position_vector + AbstractMovement.direction_vector[movement.direction]
			movement.distance -= 1
			new_item.add_child(construct_children(new_item,movement))
			return new_item

		elif movement.distance == 0 and movement.next_movement:
			new_item.add_child(construct_children(new_item,movement.next_movement))
			return new_item

	elif movement is JumpingMovement:
		new_item.position_vector = parent.position_vector + movement.offset_vector
		if movement.next_movement:
			new_item.add_child(construct_children(new_item,movement.next_movement))
		return new_item

	elif movement is BranchingMovement:
		for branch in movement.branches:
			new_item.add_child(construct_children(new_item,branch))


func extract_move_from_item(item:MoveTreeItem):
	if item != root_item:
		move_list.append(root_item.tile.position.algebraic_notation + " --> " + item.tile.position.algebraic_notation)
	if not item.children.is_empty():
		for child_item in item.children:
			extract_move_from_item(child_item)


func trim_tree():
	pass
