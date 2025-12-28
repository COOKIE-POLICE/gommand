extends Node3D

func _ready():
	await get_tree().process_frame
	# Expectation: sequence prints "Seq A", waits 2.5s, prints "Seq B" — repeated twice
	CommandScheduler.schedule(PrintCommand.new("EXPECT: Sequential_repeat -> Seq A, wait, Seq B (x2)"))
	var seq = SequentialCommandGroup.new([
		PrintCommand.new("Seq A"),
		WaitCommand.new(2.5),
		PrintCommand.new("Seq B")
	])
	CommandScheduler.schedule(RepeatCommand.new(seq, 2))
