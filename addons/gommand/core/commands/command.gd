class_name Command
extends RefCounted

var _requirements = null
var _interruptible: bool = true
var _initialized: bool = false
var _scheduled: bool = false

const Set = preload("../../scripts/set.gd")


func _init(requirements: Array = [], interruptible: bool = true) -> void:
	_requirements = Set.new()
	for subsystem in requirements:
		_requirements.add(subsystem)
	_interruptible = interruptible

func get_requirements() -> Array:
	return _requirements.elements()

func add_requirement(subsystem: Object) -> Command:
	_requirements.add(subsystem)
	return self

func set_interruptible(interruptible: bool) -> Command:
	_interruptible = interruptible
	return self

func is_interruptible() -> bool:
	return _interruptible

func initialize() -> void:
	pass

# Called periodically while scheduled. Delta is seconds since last run.
func execute(delta_time: float) -> void:
	pass

# Return true when the command should end.
func is_finished() -> bool:
	return true

# Called once when the command ends or is canceled.
# interrupted is true if the command was canceled by scheduler.
func end(interrupted: bool) -> void:
	pass

# Internal state helpers used by scheduler
func _on_scheduled() -> void:
	_initialized = false
	_scheduled = true

func _on_unscheduled() -> void:
	_scheduled = false

func _is_scheduled() -> bool:
	return _scheduled

func _has_initialized() -> bool:
	return _initialized

func _mark_initialized() -> void:
	_initialized = true
