class_name FunctionalCommand
extends Command


var _initialize_callable: Callable = Callable()
var _execute_callable: Callable = Callable()
var _end_callable: Callable = Callable()
var _is_finished_callable: Callable = Callable()

func _init(initialize_callable: Callable, execute_callable: Callable, end_callable: Callable, is_finished_callable: Callable, requirements: Array = [], interruptible: bool = true) -> void:
	_initialize_callable = initialize_callable
	_execute_callable = execute_callable
	_end_callable = end_callable
	_is_finished_callable = is_finished_callable
	super._init(requirements, interruptible)

func initialize() -> void:
	if _initialize_callable.is_valid():
		_initialize_callable.call()

func execute(delta_time: float) -> void:
	if _execute_callable.is_valid():
		_execute_callable.call(delta_time)

func is_finished() -> bool:
	if _is_finished_callable.is_valid():
		return bool(_is_finished_callable.call())
	return true

func end(interrupted: bool) -> void:
	if _end_callable.is_valid():
		_end_callable.call(interrupted)
