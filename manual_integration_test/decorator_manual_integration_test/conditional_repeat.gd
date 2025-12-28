extends Node3D

func _ready():
	await get_tree().process_frame
	# Expectation: Conditional true branch runs a Repeat of Print x2
	CommandScheduler.schedule(PrintCommand.new("EXPECT: Conditional_repeat -> TRUE branch runs Repeat x2"))
	var condition = Callable(self, "_condition_true")
	var inner = ParallelCommandGroup.new([
		PrintCommand.new("ConditionalRepeat: hello"),
		WaitCommand.new(0.2)
	])
	var repeat = RepeatCommand.new(inner, 2)
	var cond = ConditionalCommand.new(condition, repeat, PrintCommand.new("CondRepeat: FALSE"))
	CommandScheduler.schedule(cond)

func _condition_true() -> bool:
	return true
