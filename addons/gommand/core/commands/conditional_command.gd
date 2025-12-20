class_name ConditionalCommand
extends Command


var _condition_callable: Callable = Callable()
var _on_true_command: Command = null
var _on_false_command: Command = null
var _active_command: Command = null

func _init(condition_callable: Callable, on_true_command: Command, on_false_command: Command = null) -> void:
	_condition_callable = condition_callable
	_on_true_command = on_true_command
	_on_false_command = on_false_command
	super._init([], true)
	if _on_true_command != null:
		for subsystem in _on_true_command.get_requirements():
			add_requirement(subsystem)
	if _on_false_command != null:
		for subsystem in _on_false_command.get_requirements():
			add_requirement(subsystem)

func initialize() -> void:
	var condition_result := false
	if _condition_callable.is_valid():
		condition_result = bool(_condition_callable.call())
	if condition_result:
		_active_command = _on_true_command
	else:
		_active_command = _on_false_command
	if _active_command != null and not _active_command._has_initialized():
		_active_command.initialize()
		_active_command._mark_initialized()

func execute(delta_time: float) -> void:
	if _active_command != null:
		_active_command.execute(delta_time)

func is_finished() -> bool:
	if _active_command == null:
		return true
	return _active_command.is_finished()

func end(interrupted: bool) -> void:
	if _active_command != null:
		_active_command.end(interrupted)
