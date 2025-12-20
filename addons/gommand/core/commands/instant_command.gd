class_name InstantCommand
extends Command


var _action_to_run: Callable = Callable()

func _init(action_to_run: Callable = Callable(), requirements: Array = [], interruptible: bool = true) -> void:
	_action_to_run = action_to_run
	super._init(requirements, interruptible)

func initialize() -> void:
	if _action_to_run.is_valid():
		_action_to_run.call()

func is_finished() -> bool:
	return true
