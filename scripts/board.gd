extends Node

@export var selected_piece: Node3D
@export var selected_tile: Node3D


func _on_ready() -> void:
	get_tree().call_group("Tile","find_neighbors")
	#get_tree().call_group("Piece","calculate_moveset")


## Node tree function that reparents the piece object to the tile object
#func _reparent_piece_to_new_tile(tile:Node3D) -> void:
		#reparent(tile)
		#set_owner(tile)
		#global_position = (
				#tile.global_position 
				#* Vector3(1,0,1)
				#+ global_position 
				#* Vector3(0,1,0)
		#)
#var color: Color:
	#set(new_color):
		#color = new_color
		#base.get_surface_override_material(0).albedo_color = new_color
#
### Sets up the next turn
#func new_turn() -> void:
	#
	#Piece.selected = null
	#Tile.selected = null
	#king_rook_relation.clear()
	#checked_king_moveset.clear()
	#
	## increments the turn number and switches the board color
	#Player.turn_num = (Player.turn_num + 1) % 2
	#Player.current = players[Player.turn_num]
	#
	#for pawn in Player.current.pawns:
		#if pawn.threatened_by_en_passant == true:
			#print("TRUE")
			#pawn.threatened_by_en_passant = false
	#
	#color = Game.Colour.PALETTE[Game.Colour.PLAYER][Player.turn_num]
#
	#get_tree().call_group("Tile", "set_state","Tile.State.NONE")
	#get_tree().call_group("Piece", "set_state","Piece.State.NONE")
	#
  	## Recalculate piece movements and if check has occured
#
	#get_tree().call_group("Piece", "calculate_complete_moveset")
#
	#for player in Board.players:
		#checking_tiles.clear()
		#checking_pieces.clear()
#
		#for piece in player.pieces:
			#piece.generate_valid_moveset()
			#
		#player.compile_threatened_tiles()
		#
		#if checking_tiles and checking_pieces:
			#_set_check_states(player)
#
#func create_new_piece(player: Player, tile: Tile, piece: Node3D):
	#match piece.name.get_slice("_", 0).to_lower():
		#"pawn": 
			#tile.occupant = Pawn.new(player, tile, piece)
			#player.pawns.append(tile.occupant)
		#"rook": 
			#tile.occupant = Rook.new(player, tile, piece)
			#player.rooks.append(tile.occupant)
		#"bishop": 
			#tile.occupant = Bishop.new(player, tile, piece)
			#player.bishops.append(tile.occupant)
		#"knight": 
			#tile.occupant = Knight.new(player, tile, piece)
			#player.knights.append(tile.occupant)
		#"queen": 
			#tile.occupant = Queen.new(player, tile, piece)
			#player.queens.append(tile.occupant)
		#"king": 
			#tile.occupant = King.new(player, tile, piece)
			#player.king = tile.occupant
	#tile.occupant.outline_object.visible = false
	#tile.occupant.outline_object.material_override.grow_amount = (
			#Game.Settings.options[Game.Settings.PIECE_OUTLINE_THICKNESS]
	#)
