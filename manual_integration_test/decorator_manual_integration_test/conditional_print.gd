extends Node3D

func _ready():
	await get_tree().process_frame
	# Expectation: conditional should evaluate predicate and run TRUE branch
	CommandScheduler.schedule(PrintCommand.new("EXPECT: Conditional_print -> should run TRUE branch"))
	var condition = Callable(self, "_condition_true")
	var cmd = ConditionalCommand.new(condition, PrintCommand.new("Conditional: TRUE"), PrintCommand.new("Conditional: FALSE"))
	CommandScheduler.schedule(cmd)

func _condition_true() -> bool:
	return true
