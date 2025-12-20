class_name SelectCommand
extends Command

# Choose a command based on a selector callable returning a key, and a dictionary mapping keys to commands.
var _selector_callable: Callable = Callable()
var _command_map: Dictionary = {}
var _active_command: Command = null

func _init(selector_callable: Callable, command_map: Dictionary) -> void:
	_selector_callable = selector_callable
	_command_map = command_map.duplicate()
	# Aggregate requirements conservatively (union of all map commands)
	super._init([], true)
	for mapped_key in _command_map.keys():
		var mapped_command: Command = _command_map[mapped_key]
		if mapped_command == null:
			continue
		for subsystem in mapped_command.get_requirements():
			add_requirement(subsystem)

func initialize() -> void:
	var selected_key = null
	if _selector_callable.is_valid():
		selected_key = _selector_callable.call()
	_active_command = _command_map.get(selected_key, null)
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
