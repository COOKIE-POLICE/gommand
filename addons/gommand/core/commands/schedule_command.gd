class_name ScheduleCommand
extends Command

# When executed, schedules the provided command via the scheduler and then finishes.
var _command_to_schedule: Command = null

func _init(command_to_schedule: Command) -> void:
	_command_to_schedule = command_to_schedule
	super._init([], true)

func initialize() -> void:
	if _command_to_schedule != null and Engine.has_singleton("CommandScheduler"):
		CommandScheduler.schedule(_command_to_schedule)

func is_finished() -> bool:
	return true


