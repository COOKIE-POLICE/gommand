extends GdUnitTestSuite

const TestCommand = preload("res://test/test_command.gd")
const TestSubsystem = preload("res://test/test_subsystem.gd")

func test_wrapper_forces_uninterruptible() -> void:
    var subsystem := TestSubsystem.new()
    var inner := TestCommand.new([subsystem], true)
    var wrapped := UninterruptibleCommand.new(inner)

    assert_that(wrapped.is_interruptible()).is_false()
    assert_that(wrapped.get_requirements()).contains([subsystem])

func test_uninterruptible_conflict_blocks_other_command() -> void:
    var subsystem := TestSubsystem.new()

    var wrapped := UninterruptibleCommand.new(TestCommand.new([subsystem], true))
    var other := TestCommand.new([subsystem], true)

    assert_that(CommandScheduler.schedule(wrapped)).is_true()
    assert_that(CommandScheduler.schedule(other)).is_false()
