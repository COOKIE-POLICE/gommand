class_name SequentialCommandGroup
extends Command

var _commands: Array = []
var _current_index: int = 0

func _init(commands: Array = [], interruptible: bool = true) -> void:
	_commands = commands.duplicate()
	super._init([], interruptible)
	for child_command in _commands:
		if child_command == null:
			continue
		for subsystem in child_command.get_requirements():
			add_requirement(subsystem)

func initialize() -> void:
	_current_index = 0
	if _commands.size() > 0:
		var current_command = _commands[_current_index]
		if not current_command._has_initialized():
			current_command.initialize()
			current_command._mark_initialized()

func execute(delta_time: float) -> void:
	if _current_index >= _commands.size():
		return
	var current_command = _commands[_current_index]
	current_command.execute(delta_time)
	if current_command.is_finished():
		current_command.end(false)
		_current_index += 1
		if _current_index < _commands.size():
			var next_command = _commands[_current_index]
			if not next_command._has_initialized():
				next_command.initialize()
				next_command._mark_initialized()

func is_finished() -> bool:
	return _current_index >= _commands.size()

func end(interrupted: bool) -> void:
	# If interrupted mid-sequence, end current command.
	if interrupted and _current_index < _commands.size():
		var current_command = _commands[_current_index]
		current_command.end(true)

func _on_scheduled() -> void:
	super._on_scheduled()
	for command in _commands:
		if command != null:
			command._on_scheduled()
