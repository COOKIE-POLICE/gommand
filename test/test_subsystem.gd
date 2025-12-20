extends Subsystem

var periodic_count := 0
var total_delta: float = 0.0

func periodic(delta_time: float) -> void:
    periodic_count += 1
    total_delta += delta_time
