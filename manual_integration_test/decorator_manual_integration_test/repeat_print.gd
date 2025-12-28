extends Node3D

func _ready():
	await get_tree().process_frame
	# Expectation: inner (Print + Wait) should run 3 times then stop
	CommandScheduler.schedule(PrintCommand.new("EXPECT: Repeat_print -> inner will print 3 times"))
	var inner = ParallelCommandGroup.new([
		PrintCommand.new("Repeat: Hello"),
		WaitCommand.new(0.5)
	])
	var repeat = RepeatCommand.new(inner, 3)
	CommandScheduler.schedule(repeat)
