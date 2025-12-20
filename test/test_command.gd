extends Command

# Simple controllable Command for unit tests.

var initialize_count := 0
var execute_count := 0
var end_count := 0
var last_end_interrupted: bool = false

var finished: bool = false
var finish_after_executes: int = -1
var total_delta: float = 0.0

func _init(requirements: Array = [], interruptible: bool = true) -> void:
    super._init(requirements, interruptible)

func initialize() -> void:
    initialize_count += 1

func execute(delta_time: float) -> void:
    execute_count += 1
    total_delta += delta_time
    if finish_after_executes >= 0 and execute_count >= finish_after_executes:
        finished = true

func is_finished() -> bool:
    return finished

func end(interrupted: bool) -> void:
    end_count += 1
    last_end_interrupted = interrupted
