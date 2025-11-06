extends AnimatableBody3D

enum State{
		NONE,
		PREVIOUS,
		SELECTED,
		VALID,
		THREATENED,
		CHECKED,
		CHECKING,
		MOVE_CHECKING,
		SPECIAL,
	}
	
#@export_flags(
	#"has occupant:1",
	#"occupant selected:3",
	#"piece movement:4",
	#"tile threatened",
	#"checking movement",
	#"checked occupant",
	#"special",
	#) var state_flags

func set_state_previous() -> void:
	if not state_order.is_empty():
		set_state(state_order.pop_back())
	else:
		set_state(State.NONE)
		
var state_order: Array[State] = []
	
	
var state_color: Color: 
	set(new_color):
		state_color = new_color
		$Mesh.get_surface_override_material(0).albedo_color = new_color

## Color of the mesh object
var color: Color: 
	set(new_color):
		color = new_color
		$Mesh.get_surface_override_material(0).albedo_color = new_color

func _set_color_to(color_value:= Color(1,1,1)) -> void:
	state_color = color * color_value
				
func set_state(new_state: State) -> void:
	if new_state != State.SPECIAL:
		$Mesh.get_surface_override_material(0).emission_enabled = false
			
	match new_state:
		State.NONE: 
			_set_color_to()
			state_order.clear()
			
		State.SELECTED: 
			if current_state != State.NONE:
				state_order.append(current_state)
			if current_state != State.CHECKED:
				_set_color_to(Game.PALETTE.SELECT_TILE)
				
		State.VALID:
			if current_state != State.NONE:
				state_order.append(current_state)
			if current_state != State.MOVE_CHECKING:
				_set_color_to(Game.PALETTE.VALID_TILE)
				
		State.THREATENED:
			if current_state != State.NONE:
				state_order.append(current_state)
			_set_color_to(Game.PALETTE.THREATENED_TILE)
			
		State.CHECKED: 
			if current_state != State.NONE:
				state_order.append(current_state)
			_set_color_to(Game.PALETTE.CHECKED_TILE)
			
		State.CHECKING: 
			if current_state != State.NONE:
				state_order.append(current_state)
			if Game.Settings.options[Game.Settings.SHOW_CHECKING_PIECE_PATH]:
				_set_color_to(Game.PALETTE.CHECKING_TILE)
				
		State.MOVE_CHECKING: 
			if current_state != State.NONE:
				state_order.append(current_state)
			_set_color_to(Game.PALETTE.MOVE_CHECKING_TILE)
			
		State.SPECIAL:
			if current_state != State.NONE:
				state_order.append(current_state)
			state_color = Game.PALETTE.SPECIAL_TILE
			find_child("Mesh").get_surface_override_material(0).emission_enabled = true

	current_state = new_state

var current_state: State = State.NONE
