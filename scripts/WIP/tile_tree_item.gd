# UNFINISHED
class_name TileTreeItem
extends Resource

var tile: TileObject


var children: Array[TileTreeItem]


func _init(tile:TileObject):
	self.tile = tile


func add_child(item: TileTreeItem):
	children.append(item)


func remove_child(item: TileTreeItem):
	if children.has(item):
		children.erase(item)


func get_children():
	return children
