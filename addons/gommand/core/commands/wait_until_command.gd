class_name WaitUntilCommand
extends Command

var _predicate: Callable = Callable()

func _init(predicate: Callable) -> void:
	_predicate = predicate
	super._init([], true)

func is_finished() -> bool:
	if _predicate.is_valid():
		return bool(_predicate.call())
	return false
