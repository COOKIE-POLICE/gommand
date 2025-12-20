class_name RunCommand
extends Command

# Runs a callable each execute; never finishes unless canceled.
var _runnable: Callable = Callable()

func _init(runnable_callable: Callable, requirements: Array = [], interruptible: bool = true) -> void:
	_runnable = runnable_callable
	super._init(requirements, interruptible)

func execute(delta_time: float) -> void:
	if _runnable.is_valid():
		_runnable.call(delta_time)

func is_finished() -> bool:
	return false
