class_name StartEndCommand
extends Command

var _on_start_callable: Callable = Callable()
var _on_end_callable: Callable = Callable()

func _init(on_start_callable: Callable, on_end_callable: Callable, requirements: Array = [], interruptible: bool = true) -> void:
	# Set the callables and adopt any declared subsystem requirements
	_on_start_callable = on_start_callable
	_on_end_callable = on_end_callable
	for subsystem in requirements:
		add_requirement(subsystem)
	super._init(requirements, interruptible)

func initialize() -> void:
	if _on_start_callable.is_valid():
		_on_start_callable.call()

func execute(delta_time: float) -> void:
	# No default action each frame; runs until canceled/interrupted unless decorated
	pass

func is_finished() -> bool:
	# This command has no intrinsic end condition
	return false

func end(interrupted: bool) -> void:
	if _on_end_callable.is_valid():
		_on_end_callable.call()
