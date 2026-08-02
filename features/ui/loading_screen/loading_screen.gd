extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	%LoadingDots.visible_ratio += delta
	if %LoadingDots.visible_ratio == 1:
		%LoadingDots.visible_ratio = 0
