@tool
extends Control

@export_enum("Pieces:0", "Piece Modifiers:1", "Tile Modifiers:2") var tab_index = 0:
	set(new_tab_index):
		if $MarginContainer/BoxContainer/MarginContainer/TabBar:
			$MarginContainer/BoxContainer/MarginContainer/TabBar.current_tab = new_tab_index
			tab_index = new_tab_index


func _on_tab_bar_tab_changed(tab: int) -> void:
	$MarginContainer/BoxContainer/BackgroundPanel/LeftPageTabContainer.current_tab = tab
