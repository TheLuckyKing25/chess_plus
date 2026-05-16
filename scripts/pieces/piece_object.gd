class_name PieceObject
extends Node3D

signal clicked(piece: PieceObject)
signal data_changed(new_data: PieceData)

signal promoted

@export var mesh_instance: MeshInstance3D


const PIECE_SCENE:PackedScene = preload("uid://dnismskxjehm6")


const THREATENED_COLOR:= Color(0.9, 0, 0, 1)
const CHECKING_COLOR:= Color(0.9, 0.9, 0)
const SELECT_COLOR:= Color(0, 0.9, 0.9, 1)
const CHECKED_COLOR:= Color(0.9, 0, 0, 1)
const CASTLING_COLOR:= Color(1,1,1,1)


static var en_passant: PieceObject = null
static var selected: PieceObject = null


static var is_selected: bool:
	get():
		return PieceObject.selected != null


var is_mouse_on_piece: bool = false


@onready var piece_material: StandardMaterial3D:
	get():
		return mesh_instance.material_override


@onready var mouseover_material: StandardMaterial3D:
	get():
		return piece_material.next_pass


@onready var outline_material: StandardMaterial3D:
	get():
		return piece_material.next_pass.next_pass


@export var data: PieceData:
	set(new_data):
		data_changed.emit(new_data)
		data = new_data


func _ready() -> void:
	data_changed.connect(Callable(self,"_on_data_changed"))
	clicked.connect(Callable(self,"_on_clicked"))

	# reloads data if data was assigned when the object was not ready
	data_changed.emit(data)


#region Piece Object Generation
static func new_piece_object() -> PieceObject:
	var new_piece:PieceObject = PIECE_SCENE.instantiate()
	return new_piece


func _on_data_changed(new_data:PieceData):
	_unload_data(data)
	_load_data(new_data)
	_on_type_changed(new_data.type)
	_on_player_changed(new_data.player)


func _unload_data(old_data: PieceData):
	if old_data:
		# disconnect signals from old data
		if old_data.is_connected("type_changed",Callable(self,"_on_type_changed")):
			old_data.type_changed.disconnect(Callable(self,"_on_type_changed"))
		if old_data.is_connected("player_changed",Callable(self,"_on_type_changed")):
			old_data.player_changed.disconnect(Callable(self,"_on_player_changed"))
		old_data.disconnect_flag_components(Callable(self,"apply_state"))

		# clear connection between object and old data
		old_data.assigned_object = null



func _load_data(new_data: PieceData):
	if new_data:
		# connect signals from new data
		new_data.type_changed.connect(Callable(self,"_on_type_changed"))
		new_data.player_changed.connect(Callable(self,"_on_player_changed"))
		new_data.connect_flag_components(Callable(self,"apply_state"))

		# connect this object and the new data
		new_data.assigned_object = self

		outline_material.albedo_color = Color(0,0,0,0)


func _on_type_changed(new_type:PieceType):
	if data and data.type:
		remove_from_group(data.type.name)
	if new_type and mesh_instance:
		mesh_instance.mesh = new_type.object_mesh
		add_to_group(new_type.name)


func _on_player_changed(new_player:Player):
	if data and data.player:
		remove_from_group(data.player.name)
	if new_player:
		piece_material.albedo_color = new_player.color
		rotation.y = new_player.piece_rotation_parity
		add_to_group(new_player.name)
#endregion

func _on_mouse_entered() -> void:
	is_mouse_on_piece = true
	mouseover_material.render_priority = 2
	mouseover_material.albedo_color = piece_material.albedo_color * 1.5


func _on_mouse_exited() -> void:
	mouseover_material.albedo_color = Color(0,0,0,0)
	mouseover_material.render_priority = 0
	is_mouse_on_piece = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Select") and is_mouse_on_piece:
		clicked.emit(self)

func _on_clicked(object: PieceObject):
	pass







#static func new_piece(piece_type: PieceData, player_owner:Player, max_move_distance:int, index:int) -> PieceObject:
	#var new_piece:PieceObject = PIECE_SCENE.instantiate()
	#var new_piece_data: PieceData = piece_type.duplicate(true)
#
	#piece_type.resource_local_to_scene = true
#
	#new_piece_data.movement = new_piece_data.movement.get_duplicate()
#
	#new_piece_data.player = player_owner
	#new_piece_data.movement.set_max_distance(max_move_distance)
	#new_piece_data.index = index
#
	#new_piece.data = new_piece_data
	#new_piece.data.player.add_piece(new_piece)
	#Match.add_piece(new_piece)
	#return new_piece


func promote(piece_name: String):
	var new_data: PieceData
	match piece_name:
		"Bishop":
			new_data = load("uid://b12vykyoafcox")
		"Knight":
			new_data = load("uid://brd0i5dnuyf6l")
		"Rook":
			new_data = load("uid://b5r63cf4oeak3")
		"Queen":
			new_data = load("uid://bccbxx63wac0s")

	Match.remove_piece(self)
	data.player.remove_piece(self)

	data = new_data

	Match.add_piece(self)
	data.player.add_piece(self)

	promoted.emit()


func apply_state():
	if data.flag.is_captured.enabled:
		_captured()
	elif data.flag.is_castling.enabled:
		outline_material.albedo_color = CASTLING_COLOR
	elif data.flag.is_threatened.enabled:
		outline_material.albedo_color = THREATENED_COLOR
	elif data.flag.is_selected.enabled:
		outline_material.albedo_color = SELECT_COLOR
	elif data.flag.is_checked.enabled:
		outline_material.albedo_color = CHECKED_COLOR
	else:
		outline_material.albedo_color = Color(0,0,0,0)

	if data.flag.has_moved.enabled:
		add_to_group("has_moved")
	else:
		remove_from_group("has_moved")


func move_to(tile: TileObject):
	tile.occupant = self
	global_position = (position * Vector3(0,1,0)) + tile.global_position
	global_rotation = tile.global_rotation + global_rotation
	reparent(tile)
	data.index = tile.data.index


func _captured():
	visible = false
	$Collision.disabled = true
	translate(Vector3(0,-5,0))


func moved(state:bool):
	data.flag.has_moved.enabled = state
	if state:
		if data.type.name == "Pawn":
			data.movement = load("uid://bpexpwlvi0ymy")
		add_to_group("has_moved")
	else:
		if data.type.name == "Pawn":
			data.movement = load("uid://dl1o3ayyjvnlf")
		remove_from_group("has_moved")
