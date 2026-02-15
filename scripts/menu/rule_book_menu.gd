@tool
extends Control

#@export_enum("Pieces:0", "Piece Modifiers:1", "Tile Modifiers:2", "Chess Terminology:3") var tab_index = 0:
	#set(new_tab_index):
		#if $MarginContainer/TabContainer and $MarginContainer/TabContainer.get_tab_count() >= new_tab_index:
			#$MarginContainer/TabContainer.current_tab = new_tab_index
			#tab_index = new_tab_index
