class_name PriorityStack
extends RefCounted


@export var _stack: Dictionary[int,String] = {}


func add_item(item: GameData.ItemState):
	if item.priority in _stack.keys():
		printerr("Priority already exists in stack. No action taken.")
		return null
	_stack.set(item.priority,item)


func replace_item(item: GameData.ItemState):
	if not item.priority in _stack.keys():
		printerr("Priority does not exist in Stack. Adding item to stack instead.")
	_stack.set(item.priority,item)


func remove_item(item: GameData.ItemState):
	if not item.priority in _stack.keys():
		printerr("Priority does not exist in Stack. No action taken.")
		return null
	_stack.set(item.priority,item)


func get_highest_priority():
	if _stack.is_empty():
		printerr("Priority Stack is empty. No item returned.")
		return null
	_stack.sort()
	return _stack.get(_stack.keys()[0])


func clear_stack():
	_stack.clear()
