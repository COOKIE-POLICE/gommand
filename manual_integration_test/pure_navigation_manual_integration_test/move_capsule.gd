extends Node3D


func _ready():
    await get_tree().process_frame
    _start_demo()


func _start_demo():

    %PureNavigation3DSubsystem.movement_speed = 4.0
    %PureNavigation3DSubsystem.rotation_speed = 6.0
    %PureNavigation3DSubsystem.acceleration = 20.0

    # Schedule a sequence of moves.
    var points := [
        Vector3(4, 0, 4),
        Vector3(-4, 0, 4),
        Vector3(-4, 0, -4),
        Vector3(4, 0, -4),
        Vector3(0, 0, 0)
    ]

    # Chain moves via SequentialCommandGroup so the capsule walks around.
    var commands: Array = []
    for p in points:
        commands.append(GoToCommand.new(%PureNavigation3DSubsystem, p, true))

    var seq := SequentialCommandGroup.new(commands)
    CommandScheduler.schedule(seq)
