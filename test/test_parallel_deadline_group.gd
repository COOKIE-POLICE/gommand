extends GdUnitTestSuite

const TestCommand = preload("res://test/test_command.gd")

func test_finishes_when_deadline_finishes_and_ends_running_commands() -> void:
    
    var deadline := TestCommand.new()
    deadline.finish_after_executes = 1
    var follower := TestCommand.new()
    follower.finish_after_executes = 999

    var group := ParallelDeadlineGroup.new(deadline, [follower])
    CommandScheduler.schedule(group)
    CommandScheduler.run(0.01)

    # deadline ended inside execute
    assert_that(deadline.end_count).is_equal(1)
    # follower ended by group end
    assert_that(follower.end_count).is_equal(1)
    assert_that(CommandScheduler.is_scheduled(group)).is_false()
