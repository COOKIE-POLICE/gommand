extends PureNavigationSubsystem

# Lightweight stub navigation subsystem for unit tests.
# Records calls and allows manual control over completion state.

var last_target_position: Vector3 = Vector3.ZERO
var last_target_heading: Vector3 = Vector3.ZERO
var last_delta_heading: float = 0.0

var go_to_called_count: int = 0
var turn_to_called_count: int = 0
var turn_by_called_count: int = 0
var stop_called_count: int = 0

var navigation_finished: bool = false

func go_to_position(target_position: Variant) -> void:
    go_to_called_count += 1
    last_target_position = target_position

func turn_to_heading(target_heading: Variant) -> void:
    turn_to_called_count += 1
    last_target_heading = target_heading

func turn_by_amount(delta_heading: Variant) -> void:
    turn_by_called_count += 1
    last_delta_heading = float(delta_heading)

func is_navigation_finished() -> bool:
    return navigation_finished

func get_current_velocity() -> Variant:
    return Vector3.ZERO

func stop() -> void:
    stop_called_count += 1
