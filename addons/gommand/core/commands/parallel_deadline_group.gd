class_name ParallelDeadlineGroup
extends Command

var _deadline_command: Command = null
var _commands: Array = []

func _init(deadline_command: Command, commands: Array = [], interruptible: bool = true) -> void:
	_deadline_command = deadline_command
	_commands = commands.duplicate()
	super._init([], interruptible)
	if _deadline_command != null:
		for subsystem in _deadline_command.get_requirements():
			add_requirement(subsystem)
	for child_command in _commands:
		if child_command == null:
			continue
		for subsystem in child_command.get_requirements():
			add_requirement(subsystem)

func initialize() -> void:
	if _deadline_command and not _deadline_command._has_initialized():
		_deadline_command.initialize()
		_deadline_command._mark_initialized()
	for command in _commands:
		if not command._has_initialized():
			command.initialize()
			command._mark_initialized()

func execute(delta_time: float) -> void:
	if _deadline_command and not _deadline_command.is_finished():
		_deadline_command.execute(delta_time)
	for command in _commands:
		if not command.is_finished():
			command.execute(delta_time)
	if _deadline_command and _deadline_command.is_finished():
		_deadline_command.end(false)

func is_finished() -> bool:
	if _deadline_command == null:
		return false
	return _deadline_command.is_finished()

func end(interrupted: bool) -> void:
	# end all running commands
	if _deadline_command and not _deadline_command.is_finished():
		_deadline_command.end(interrupted)
	for command in _commands:
		if not command.is_finished():
			command.end(interrupted)
