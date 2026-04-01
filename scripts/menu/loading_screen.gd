extends Control

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/game_environment.tscn")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	%LoadingDots.visible_ratio += delta
	if %LoadingDots.visible_ratio == 1:
		%LoadingDots.visible_ratio = 0
