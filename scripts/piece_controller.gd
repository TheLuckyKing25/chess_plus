class_name PieceController
extends GameNode3D

signal clicked(piece: PieceController)

static var selected: PieceController = null
static var en_passant: PieceController = null

const THREATENED_COLOR = Color(0.9, 0, 0, 1)
const CHECKING_COLOR = Color(0.9, 0.9, 0, 1)
const SELECT_COLOR = Color(0, 0.9, 0.9, 1)
const CHECKED_COLOR = Color(0.9, 0, 0, 1)
const SPECIAL_COLOR = Color(1,1,1,1)

@export var stats: PieceStats

var is_mouse_on_piece: bool = false

var piece_material: StandardMaterial3D
var outline_material: StandardMaterial3D
var mouseover_material: StandardMaterial3D


func _ready() -> void:
	stats.changed.connect(Callable(self,"_on_stats_changed"))
	stats.moved.connect(Callable(self,"_on_moved"))
	add_to_group(stats.name)
	$Piece_Mesh.mesh = stats.object_mesh
	
	piece_material = $Piece_Mesh.material_override
	mouseover_material = piece_material.next_pass
	outline_material = mouseover_material.next_pass
	outline_material.albedo_color = Color(0,0,0,0)
	
	piece_material.albedo_color = stats.player.color
	add_to_group(stats.player.name)
	match stats.player.name:
		"Player_One": 
			remove_from_group("Player_Two")
			rotate_y(PI)
		"Player_Two": 
			remove_from_group("Player_One")

func _on_stats_changed():
	apply_state()

func _on_moved(state:bool):
	if state:
		if stats.name == "Pawn":
			stats.movement = load("res://resources/pieces/pawn/movement_pawn.tres")
		add_to_group("has_moved")
	else:
		if stats.name == "Pawn":
			stats.movement = load("res://resources/pieces/pawn/movement_pawn_initial.tres")
		remove_from_group("has_moved")
	
	
func _captured():
	visible = false
	$Collision.disabled = true
	stats.is_captured = true


func promote():
	remove_from_group("Pawn")

	
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

func apply_state():
	if stats.is_captured:
		return
	elif stats.is_special:
		outline_material.albedo_color = SPECIAL_COLOR
	elif stats.is_checking:
		outline_material.albedo_color = CHECKING_COLOR
	elif stats.is_threatened:
		outline_material.albedo_color = THREATENED_COLOR
	elif stats.is_selected:
		outline_material.albedo_color = SELECT_COLOR
	elif stats.is_checked:
		outline_material.albedo_color = CHECKED_COLOR
	else:
		outline_material.albedo_color = Color(0,0,0,0)
