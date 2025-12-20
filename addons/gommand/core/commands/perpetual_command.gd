class_name PerpetualCommand
extends Command


var _inner_command: Command = null

func _init(inner_command: Command) -> void:
	_inner_command = inner_command
	super._init([], inner_command.is_interruptible())
	if _inner_command != null:
		for subsystem in _inner_command.get_requirements():
			add_requirement(subsystem)

func initialize() -> void:
	if _inner_command and not _inner_command._has_initialized():
		_inner_command.initialize()
		_inner_command._mark_initialized()

func execute(delta_time: float) -> void:
	if _inner_command:
		_inner_command.execute(delta_time)

func is_finished() -> bool:
	return false

func end(interrupted: bool) -> void:
	if _inner_command and not _inner_command.is_finished():
		_inner_command.end(interrupted)
