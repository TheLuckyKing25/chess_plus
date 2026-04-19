class_name PieceObject
extends Node3D

signal promoted
signal clicked(piece: PieceObject)

const PIECE_SCENE:PackedScene = preload("uid://dnismskxjehm6")

static var selected: PieceObject = null
static var en_passant: PieceObject = null

static var is_selected: bool:
	get():
		return selected != null

var is_mouse_on_piece: bool = false

var piece_material: StandardMaterial3D
var outline_material: StandardMaterial3D
var mouseover_material: StandardMaterial3D

@export var data: PieceData:
	set(new_data):
		if data:
			remove_from_group(data.name)
			new_data.index = data.index
			new_data.player = data.player

		add_to_group(new_data.name)
		$Piece_Mesh.mesh = new_data.object_mesh

		piece_material = $Piece_Mesh.material_override
		mouseover_material = piece_material.next_pass
		outline_material = mouseover_material.next_pass
		outline_material.albedo_color = Color(0,0,0,0)
		piece_material.albedo_color = new_data.player.color
		data = new_data

static func new_piece(piece_type: PieceData, player_owner:Player, max_move_distance:int, index:int) -> PieceObject:
	var new_piece:PieceObject = PIECE_SCENE.instantiate()
	var new_piece_data: PieceData = piece_type.duplicate(true)

	piece_type.resource_local_to_scene = true

	new_piece_data.movement = new_piece_data.movement.get_duplicate()

	new_piece_data.player = player_owner
	new_piece_data.movement.set_max_distance(max_move_distance)
	new_piece_data.index = index

	new_piece.data = new_piece_data
	new_piece.data.player.add_piece(new_piece)
	Match.add_piece(new_piece)
	return new_piece


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
		outline_material.albedo_color = PieceData.CASTLING_COLOR
	elif data.flag.is_threatened.enabled:
		outline_material.albedo_color = PieceData.THREATENED_COLOR
	elif data.flag.is_selected.enabled:
		outline_material.albedo_color = PieceData.SELECT_COLOR
	elif data.flag.is_checked.enabled:
		outline_material.albedo_color = PieceData.CHECKED_COLOR
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


func _ready() -> void:
	data.connect_flag_components(Callable(self,"apply_state"))
	add_to_group(data.name)
	$Piece_Mesh.mesh = data.object_mesh

	piece_material = $Piece_Mesh.material_override
	mouseover_material = piece_material.next_pass
	outline_material = mouseover_material.next_pass
	outline_material.albedo_color = Color(0,0,0,0)

	piece_material.albedo_color = data.player.color
	add_to_group(data.player.name)
	match data.player.name.to_lower():
		"white":
			remove_from_group("white")
			rotate_y(PI)
		"black":
			remove_from_group("black")


func _captured():
	visible = false
	$Collision.disabled = true
	translate(Vector3(0,-5,0))


func moved(state:bool):
	data.flag.has_moved.enabled = state
	if state:
		if data.name == "Pawn":
			data.movement = load("uid://bpexpwlvi0ymy")
		add_to_group("has_moved")
	else:
		if data.name == "Pawn":
			data.movement = load("uid://dl1o3ayyjvnlf")
		remove_from_group("has_moved")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Select") and is_mouse_on_piece:
		clicked.emit(self)


func _on_mouse_entered() -> void:
	is_mouse_on_piece = true
	mouseover_material.render_priority = 2
	mouseover_material.albedo_color = piece_material.albedo_color * 1.5


func _on_mouse_exited() -> void:
	mouseover_material.albedo_color = Color(0,0,0,0)
	mouseover_material.render_priority = 0
	is_mouse_on_piece = false
