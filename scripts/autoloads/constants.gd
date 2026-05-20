# Constants Autoload
# contains values that are constants and need to be accessed in multiple locations
extends Node

enum SelectionMode{
	SINGLE = 0,
	MULTIPLE = 1,
}

enum Direction{
	NONE = -1, # TEMP: REMOVE FROM SCRIPT ONCE UNUSED
	NORTH = 0,
	NORTHEAST = 1,
	EAST = 2,
	SOUTHEAST = 3,
	SOUTH = 4,
	SOUTHWEST = 5,
	WEST = 6,
	NORTHWEST = 7,
	}


enum TypePiece{
	PAWN = 0,
	BISHOP = 1,
	KING = 2,
	QUEEN = 3,
	KNIGHT = 4,
	ROOK = 5,
}


const piece_type: Dictionary = {
	TypePiece.PAWN: "uid://bih6lr0cwxuk",
	TypePiece.BISHOP: "uid://b7mqdwuvfi3nh",
	TypePiece.KING: "uid://bfy5ow4fdbo1l",
	TypePiece.QUEEN: "uid://oqdygo3fdmd2",
	TypePiece.KNIGHT: "uid://cgvt2kihfm4em",
	TypePiece.ROOK: "uid://csqiux6uupcb2",
}


const direction_vector: Dictionary[Constants.Direction, Vector2i] = {
	Constants.Direction.NORTH: Vector2i(1,0),
	Constants.Direction.NORTHEAST: Vector2i(1,1),
	Constants.Direction.EAST: Vector2i(0,1),
	Constants.Direction.SOUTHEAST: Vector2i(-1,1),
	Constants.Direction.SOUTH: Vector2i(-1,0),
	Constants.Direction.SOUTHWEST: Vector2i(-1,-1),
	Constants.Direction.WEST: Vector2i(0,-1),
	Constants.Direction.NORTHWEST: Vector2i(1,-1)
}


#static func get_nodes_in_groups(scene_tree: SceneTree, groups: Array[String]) -> Array[Node]:
	#var nodes: Array[Node]
	#for group in groups:
		#if nodes.is_empty():
			#nodes = scene_tree.get_nodes_in_group(group)
			#if nodes.is_empty(): return []
			#else: continue
		#nodes = nodes.filter(func(node): return node.is_in_group(group))
	#return nodes
