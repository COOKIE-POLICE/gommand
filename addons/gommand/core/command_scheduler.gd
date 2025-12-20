extends Node

var _active_commands: Array = []
var _subsystem_usage: Dictionary = {}
var _subsystems: Array = []
var _action_triggers: Array = []

func _ready() -> void:
	set_process(true)

func _process(delta_time: float) -> void:
	run(delta_time)

func run(delta_time: float) -> void:
	_update_action_triggers()

	for subsystem in _subsystems:
		if is_instance_valid(subsystem):
			subsystem.periodic(delta_time)

	var commands_to_remove: Array = []
	for command in _active_commands:
		if not is_instance_valid(command):
			commands_to_remove.append(command)
			continue
		if not command._has_initialized():
			command.initialize()
			command._mark_initialized()
		command.execute(delta_time)
		if command.is_finished():
			command.end(false)
			commands_to_remove.append(command)
	for command in commands_to_remove:
		_unschedule(command)
	for subsystem in _subsystems:
		if not is_instance_valid(subsystem):
			continue
		if _is_subsystem_idle(subsystem) and subsystem.default_command != null:
			if not _is_scheduled(subsystem.default_command):
				schedule(subsystem.default_command)

func schedule(command: Command) -> bool:
	if command == null:
		return false
	var requirements := command.get_requirements()
	var conflicting_commands: Array = []
	for subsystem in requirements:
		if _subsystem_usage.has(subsystem):
			var occupying_command: Command = _subsystem_usage[subsystem]
			if occupying_command == command:
				continue
			conflicting_commands.append(occupying_command)
	for conflicting_command in conflicting_commands:
		if not conflicting_command.is_interruptible():
			return false
		cancel(conflicting_command)
	_command_mark_scheduled(command)
	_active_commands.append(command)
	for subsystem in requirements:
		_subsystem_usage[subsystem] = command
	return true

func cancel(command: Command) -> void:
	if command == null:
		return
	if _active_commands.has(command):
		command.end(true)
		_unschedule(command)

func cancel_all() -> void:
	for command in _active_commands.duplicate():
		cancel(command)

func is_scheduled(command: Command) -> bool:
	return _is_scheduled(command)

func register_subsystem(subsystem: Subsystem) -> void:
	if not _subsystems.has(subsystem):
		_subsystems.append(subsystem)

func unregister_subsystem(subsystem: Subsystem) -> void:
	_subsystems.erase(subsystem)
	if _subsystem_usage.has(subsystem):
		var command_in_use: Command = _subsystem_usage[subsystem]
		_subsystem_usage.erase(subsystem)
		if is_instance_valid(command_in_use) and _active_commands.has(command_in_use):
			pass

func register_action_trigger(action_trigger) -> void:
	if not _action_triggers.has(action_trigger):
		_action_triggers.append(action_trigger)

func unregister_action_trigger(action_trigger) -> void:
	_action_triggers.erase(action_trigger)

func _unschedule(command: Command) -> void:
	_active_commands.erase(command)
	for subsystem in command.get_requirements():
		if _subsystem_usage.get(subsystem) == command:
			_subsystem_usage.erase(subsystem)
	command._on_unscheduled()

func _is_subsystem_idle(subsystem: Subsystem) -> bool:
	return not _subsystem_usage.has(subsystem)

func _is_scheduled(command: Command) -> bool:
	return _active_commands.has(command)

func _command_mark_scheduled(command: Command) -> void:
	if not command._is_scheduled():
		command._on_scheduled()

func _update_action_triggers() -> void:
	for action_trigger in _action_triggers:
		if action_trigger != null:
			action_trigger._update()
