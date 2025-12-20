class_name WaitCommand
extends Command


var _duration_seconds: float = 0.0
var _start_milliseconds: int = -1

func _init(duration_seconds: float, requirements: Array = [], interruptible: bool = true) -> void:
	_duration_seconds = max(0.0, duration_seconds)
	super._init(requirements, interruptible)

func initialize() -> void:
	_start_milliseconds = Time.get_ticks_msec()

func is_finished() -> bool:
	if _start_milliseconds < 0:
		return false
	var elapsed_seconds: float = float(Time.get_ticks_msec() - _start_milliseconds) / 1000.0
	return elapsed_seconds >= _duration_seconds
