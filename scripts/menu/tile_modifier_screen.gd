extends Control

func _connect_to_back_button(function:Callable):
	var back_button: Button = $ReferenceRect/BoxContainer/ScreenNavigationMenu/BoxContainer/BackBackgroundPanel/Panel/MarginContainer/BackButton
	back_button.pressed.connect(function)

func _connect_to_continue_button(function:Callable):
	var continue_button: Button = $ReferenceRect/BoxContainer/ScreenNavigationMenu/BoxContainer/ContinueBackgroundPanel/Panel/MarginContainer/ContinueButton
	continue_button.pressed.connect(function)
