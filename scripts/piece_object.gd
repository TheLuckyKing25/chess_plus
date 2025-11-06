extends Node3D

signal state_changed(state: State)

func _on_ready() -> void:
	state_changed.connect(Callable(owner.get_parent(),"_on_state_change"))
	
enum State{
		NONE,
		SELECTED,
		THREATENED,
		CAPTURED,
		CHECKED,
		CHECKING,
		SPECIAL,
	}

var current_state: State = State.NONE

## Color of the mesh object
var mesh_color: Color:
	set(color):
		mesh_color = color
		$Mesh.get_surface_override_material(0).albedo_color = color

var state_order: Array[State] = []

func _set_outline_to(new_color:= Color(0,0,0)) -> void:
	if (new_color == Color(0,0,0)):
		$Outline.visible = false
		return
	$Outline.material_override.albedo_color = new_color
	$Outline.visible = true

func previous_state() -> void:
	if not state_order.is_empty():
		set_state(state_order.pop_back())
	else:
		set_state(State.NONE)

func set_state(new_state: State) -> void:
	match new_state:
		
		State.NONE: 
			_set_outline_to()
			state_changed.emit(State.NONE)
			state_order.clear()
		
		State.SELECTED:
			if current_state != State.NONE:
				state_order.append(current_state)
			_set_outline_to(Game.PALETTE.SELECT_PIECE)
			state_changed.emit(State.SELECTED)

			#for tile in valid_moveset:
				#if self is King and tile in Global.checked_king_moveset:
					#state_changed.emit(State.MOVE_CHECKING)
				#else:
					#state_changed.emit(State.VALID)
			#for tile in threatening_moveset:
				#if self is Pawn and not tile.occupant:
					#state_changed.emit(State.THREATENED)
					#tile.en_passant_occupant.set_state(State.THREATENED)
				#else:
					#tile.occupant.set_state(State.THREATENED)
		
		State.THREATENED:
			if current_state != State.NONE:
				state_order.append(current_state)
			_set_outline_to(Game.PALETTE.THREATENED_PIECE)
			state_changed.emit(State.THREATENED)
		
		State.CAPTURED:
			visible = false
			$Piece/Collision.disabled = true
			translate(Vector3(0,-5,0)) 
		
		State.CHECKED: 
			if current_state != State.NONE:
				state_order.append(current_state)
			_set_outline_to(Game.PALETTE.CHECKED_PIECE)
			state_changed.emit(State.CHECKED)
		
		State.CHECKING: 
			if current_state != State.NONE:
				state_order.append(current_state)
			_set_outline_to(Game.PALETTE.CHECKING_PIECE)
			state_changed.emit(State.CHECKING)
		
		State.SPECIAL:
			if current_state != State.NONE:
				state_order.append(current_state)
			_set_outline_to(Game.PALETTE.SPECIAL_PIECE)
	
	current_state = new_state
