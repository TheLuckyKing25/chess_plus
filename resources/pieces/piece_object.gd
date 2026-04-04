class_name PieceObject
extends Node3D

signal promoted
signal clicked(piece: PieceObject)

const PIECE_SCENE:PackedScene = preload(Constants.SCENE_PATHS.piece)

static var selected: PieceObject = null
static var en_passant: PieceObject = null

var is_mouse_on_piece: bool = false

var piece_material: StandardMaterial3D
var outline_material: StandardMaterial3D
var mouseover_material: StandardMaterial3D


@export var data: PieceData:
	set(new_data):
		if data:
			remove_from_group(data.name)
			new_data.index = data.index
		add_to_group(new_data.name)
		$Piece_Mesh.mesh = new_data.object_mesh

		piece_material = $Piece_Mesh.material_override
		mouseover_material = piece_material.next_pass
		outline_material = mouseover_material.next_pass
		outline_material.albedo_color = Color(0,0,0,0)

		piece_material.albedo_color = new_data.player.color
		data = new_data

static func new_piece(piece_type: PieceData, player_owner:Player, max_move_distance:int, index:int):
	var new_piece:PieceObject = PIECE_SCENE.instantiate()
	piece_type.resource_local_to_scene = true
	var new_piece_data: PieceData = piece_type.duplicate(true)

	new_piece_data.movement = new_piece_data.movement.get_duplicate()

	new_piece_data.player = player_owner
	new_piece_data.movement.set_max_distance(max_move_distance)
	new_piece_data.index = index

	new_piece.data = new_piece_data
	new_piece_data.player.add_piece(new_piece)
	return new_piece

func promote(piece_name: String):
	data.player.remove_piece(self)
	match piece_name:
		"Bishop":
			data = PieceBishop.new(data.player)
		"Knight":
			data = PieceKnight.new(data.player)
		"Rook":
			data = PieceRook.new(data.player)
		"Queen":
			data = PieceQueen.new(data.player)
	data.player.add_piece(self)
	promoted.emit()


func apply_state():
	if data.is_captured:
		_captured()
	elif data.is_castling:
		outline_material.albedo_color = PieceData.CASTLING_COLOR
	elif data.is_checking:
		outline_material.albedo_color = PieceData.CHECKING_COLOR
	elif data.is_threatened:
		outline_material.albedo_color = PieceData.THREATENED_COLOR
	elif data.is_selected:
		outline_material.albedo_color = PieceData.SELECT_COLOR
	elif data.is_checked:
		outline_material.albedo_color = PieceData.CHECKED_COLOR
	else:
		outline_material.albedo_color = Color(0,0,0,0)
	if data.has_moved:
		add_to_group("has_moved")
	else:
		remove_from_group("has_moved")


func _ready() -> void:
	data.changed.connect(Callable(self,"apply_state"))
	add_to_group(data.name)
	$Piece_Mesh.mesh = data.object_mesh

	piece_material = $Piece_Mesh.material_override
	mouseover_material = piece_material.next_pass
	outline_material = mouseover_material.next_pass
	outline_material.albedo_color = Color(0,0,0,0)

	piece_material.albedo_color = data.player.color
	add_to_group(data.player.name)
	match data.player.name:
		"Player_One":
			remove_from_group("Player_Two")
			rotate_y(PI)
		"Player_Two":
			remove_from_group("Player_One")


func _captured():
	visible = false
	$Collision.disabled = true
	translate(Vector3(0,-5,0))


func _moved(state:bool):
	data.has_moved = state
	if state:
		if data.has_meta("movement_after_first_move"):
			data.movement = data.get_meta("movement_after_first_move")
		add_to_group("has_moved")
	else:
		if data.has_meta("movement_of_first_move"):
			data.movement = data.get_meta("movement_of_first_move")
		remove_from_group("has_moved")


func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if (	event is InputEventMouseButton
			and event.is_pressed()
			and event.button_index == MOUSE_BUTTON_LEFT
			and is_mouse_on_piece
		):
		clicked.emit(self)


func _on_mouse_entered() -> void:
	is_mouse_on_piece = true
	mouseover_material.render_priority = 2
	mouseover_material.albedo_color = piece_material.albedo_color * 1.5


func _on_mouse_exited() -> void:
	mouseover_material.albedo_color = Color(0,0,0,0)
	mouseover_material.render_priority = 0
	is_mouse_on_piece = false
