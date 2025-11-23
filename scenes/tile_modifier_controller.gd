extends Node3D
#
#@export_range(0,9) var num_of_modifiers:int = 0
#@export var base_modifier_plane: MeshInstance3D
#
#const MAX_SIDE_LENGTH: float = 0.8
#const DISTANCE_ABOVE_TILE: float = 0.07
#
#func _on_ready():
	#match num_of_modifiers:
		#0: grid_size_0()
		#1: grid_size_1()
		#2,3,4: grid_size_2()
		#5,6,7,8,9: grid_size_3()
#
#func modifier_display():
	#pass
#
#func grid_size_0():
	#$Modifier.visible = false
#
#func grid_size_1():
	#modifiers.resize(1)
	#modifiers.append(base_modifier_plane.duplicate())
	#
	#
#func grid_size_2():
	#modifiers.resize(4)
	#modifiers.fill(base_modifier_plane.duplicate())
	#for modifier in modifiers:
		#if modifier:
			#modifier.mesh.size = MAX_SIDE_LENGTH/2 - 0.05
	#
#func grid_size_3():
	#modifiers.resize(9)
	#modifiers.append(base_modifier_plane.duplicate())
