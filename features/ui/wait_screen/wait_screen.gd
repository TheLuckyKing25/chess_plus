extends Control

func set_ip_label(ip:String = "0.0.0.0"):
	%IPHere.text = ip

func set_invite_code_label(invite_code:String = "Placeholder"):
	%CodeHere.text = invite_code

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	%LoadingDots.visible_ratio += delta
	if %LoadingDots.visible_ratio == 1:
		%LoadingDots.visible_ratio = 0
