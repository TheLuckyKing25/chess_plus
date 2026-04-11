class_name TimeControl
extends Timer

static var max_time_sec: float = 0

static var increment_sec: float = 0

var time_string: String = ""

var label: Label = null:
	set(new_label):
		label = new_label
		if new_label != null:
			new_label.text = time_string



func set_timer(time_sec: float) -> void:
	_set_time_string(time_sec)
	paused = true
	start(time_sec)


func _set_time_string(time_sec:float) -> void:
	var time = _get_time_units(time_sec)

	if time.hours > 0:
		time_string = (str(time.hours)
				+ ":" + str(time.minutes).pad_zeros(2)
				+ ":" + str(time.seconds).pad_zeros(2)
				+ "." + str(time.milliseconds).pad_zeros(3))

	elif time.minutes > 0:
		time_string = (str(time.minutes)
				+ ":" + str(time.seconds).pad_zeros(2)
				+ "." + str(time.milliseconds).pad_zeros(3))

	elif time.seconds > 0:
		time_string = (str(time.seconds)
				+ "."+ str(time.milliseconds).pad_zeros(3))

	elif time.seconds < 1:
		time_string = "0." + str(time.milliseconds).pad_zeros(3)


func _get_time_units(time_sec:float) -> Dictionary[String,int]:
	var remaining_seconds: float

	var hours: int = int(time_sec/3600)
	remaining_seconds = time_sec - (hours * 3600)
	var minutes: int = int(remaining_seconds/60)
	remaining_seconds = remaining_seconds - (minutes * 60)
	var seconds: int = int(remaining_seconds)
	remaining_seconds = remaining_seconds - seconds
	var milliseconds: int = int(remaining_seconds * 1000)
	return {
		"hours":hours,
		"minutes":minutes,
		"seconds":seconds,
		"milliseconds":milliseconds
		}

func _update_timer_ui():
	_set_time_string(time_left)
	if label != null:
		label.text = time_string

func increase_by_increment():
	if time_left + increment_sec > max_time_sec:
		start(max_time_sec)
	else:
		start(time_left + increment_sec)

	_update_timer_ui()

func reduce_by(seconds: float) -> void:
	var new_time: float = max(time_left - seconds, 0.0)
	start(new_time)
	if paused:
		paused = true

	_update_timer_ui()

func stop_timer():
	paused = true
	_update_timer_ui()

func start_timer():
	paused = false
	_update_timer_ui()
