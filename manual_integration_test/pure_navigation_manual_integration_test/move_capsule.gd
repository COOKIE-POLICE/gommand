extends Node3D


func _ready():
	await get_tree().process_frame
	_start_demo()


func _start_demo():
	var points := [
		Vector3(4, 0, 4),
		Vector3(-4, 0, 4),
		Vector3(-4, 0, -4),
		Vector3(4, 0, -4),
		Vector3(0, 0, 0)
	]
	var commands: Array = []
	for p in points:
		commands.append(
			ParallelCommandGroup.new(
				[
					GoToCommand.new(%PureNavigation3DSubsystem, p, true),
					PrintCommand.new("GoToCommand")
				]
			)
		)

	var seq := SequentialCommandGroup.new(commands)
	CommandScheduler.schedule(RepeatCommand.new(seq, 0))
