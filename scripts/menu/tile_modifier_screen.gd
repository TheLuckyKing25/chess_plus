extends Control

func _connect_to_back_button(function:Callable):
	%BackButton.pressed.connect(function)

func _connect_to_continue_button(function:Callable):
	%ContinueButton.pressed.connect(function)
