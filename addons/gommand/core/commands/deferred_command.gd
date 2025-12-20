class_name DeferredCommand
extends Command

var _factory_callable: Callable = Callable()
var _created_command: Command = null

func _init(factory_callable: Callable) -> void:
	_factory_callable = factory_callable
	super._init([], true)

func initialize() -> void:
	if _factory_callable.is_valid():
		var created_result = _factory_callable.call()
		if typeof(created_result) == TYPE_OBJECT and created_result is Command:
			_created_command = created_result
			for subsystem in _created_command.get_requirements():
				add_requirement(subsystem)
			_created_command.initialize()
			_created_command._mark_initialized()

func execute(delta_time: float) -> void:
	if _created_command != null:
		_created_command.execute(delta_time)

func is_finished() -> bool:
	if _created_command == null:
		return true
	return _created_command.is_finished()

func end(interrupted: bool) -> void:
	if _created_command != null:
		_created_command.end(interrupted)
