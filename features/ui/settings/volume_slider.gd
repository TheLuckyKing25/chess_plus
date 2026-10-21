extends Slider


enum BusIndex{MASTER=0, MUSIC=1, UI=2, GAME=3}


@export var percent_object: ProgressBar


@export var audio_bus: BusIndex = BusIndex.MASTER


@export var config_setting_name: StringName


func _ready():
	value_changed.connect(_on_value_changed)


func set_volume(volume_amount: float) -> void:
	value = volume_amount
	var decibels: float = linear_to_db(volume_amount)
	AudioServer.set_bus_volume_db(audio_bus, decibels)


func _on_value_changed(volume: float) -> void:
	set_volume(volume)
	percent_object.value = volume
