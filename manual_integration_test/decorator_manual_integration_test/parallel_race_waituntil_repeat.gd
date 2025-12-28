extends Node3D

var _start_ms: int = 0

func _ready():
	await get_tree().process_frame
	# Expectation: ParallelRace of WaitUntil(1.5s) and Repeat(infinite) -> race ends after ~1.5s
	CommandScheduler.schedule(PrintCommand.new("EXPECT: ParallelRace_waituntil_repeat -> Repeat should be interrupted when WaitUntil becomes true (~1.5s)"))
	_start_ms = Time.get_ticks_msec()
	var predicate = Callable(self, "_wait_predicate")
	var waiter = WaitUntilCommand.new(predicate)
	var inner = ParallelCommandGroup.new([
		PrintCommand.new("RepeatRace: tick"),
		WaitCommand.new(0.3)
	])
	var repeater = RepeatCommand.new(inner, 0) # infinite until race ends
	var race = ParallelRaceGroup.new([waiter, repeater])
	CommandScheduler.schedule(race)

func _wait_predicate() -> bool:
	return Time.get_ticks_msec() - _start_ms >= 1500
