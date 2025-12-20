class_name ParallelCommandGroup
extends Command

# Runs commands in parallel; finishes when all are done.

var _commands: Array = []

func _init(commands: Array = [], interruptible: bool = true) -> void:
	_commands = commands.duplicate()
	super._init([], interruptible)
	for child_command in _commands:
		if child_command == null:
			continue
		for subsystem in child_command.get_requirements():
			add_requirement(subsystem)

func initialize() -> void:
	# Initialize all children
	for command in _commands:
		if not command._has_initialized():
			command.initialize()
			command._mark_initialized()

func execute(delta_time: float) -> void:
	for command in _commands:
		# Skip commands that already finished and ended
		if command.is_finished():
			continue
		command.execute(delta_time)
		if command.is_finished():
			command.end(false)

func is_finished() -> bool:
	for command in _commands:
		if not command.is_finished():
			return false
	return true

func end(interrupted: bool) -> void:
	if interrupted:
		for command in _commands:
			if not command.is_finished():
				command.end(true)
