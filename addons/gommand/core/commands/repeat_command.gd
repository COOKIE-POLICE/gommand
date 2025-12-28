class_name RepeatCommand
extends Command

# Repeat an inner command a set number of times. If times <= 0, repeat forever.
var _inner_command: Command = null
var _times: int = 0
var _count: int = 0

func _init(inner_command: Command, times: int = 1) -> void:
	_inner_command = inner_command
	_times = times
	_count = 0
	# adopt requirements
	super._init([], inner_command.is_interruptible())
	if _inner_command != null:
		for subsystem in _inner_command.get_requirements():
			add_requirement(subsystem)

func initialize() -> void:
	_count = 0
	if _inner_command and not _inner_command._has_initialized():
		_inner_command.initialize()
		_inner_command._mark_initialized()

func execute(delta_time: float) -> void:
	if _inner_command == null:
		return
	_inner_command.execute(delta_time)
	if _inner_command.is_finished():
		_inner_command.end(false)
		_count += 1
		if _times > 0 and _count >= _times:
			return
		# restart inner command - reset state first
		_inner_command._on_scheduled()
		_inner_command.initialize()
		_inner_command._mark_initialized()

func is_finished() -> bool:
	if _times <= 0:
		return false
	return _count >= _times

func end(interrupted: bool) -> void:
	if _inner_command and not _inner_command.is_finished():
		_inner_command.end(interrupted)
