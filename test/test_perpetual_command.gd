extends GdUnitTestSuite

const TestCommand = preload("res://test/test_command.gd")

func test_never_finishes_and_forwards_execute() -> void:
    var inner := TestCommand.new()
    inner.finished = false
    var command := PerpetualCommand.new(inner)
    
    CommandScheduler.schedule(command)
    CommandScheduler.run(0.1)
    CommandScheduler.run(0.2)

    assert_that(CommandScheduler.is_scheduled(command)).is_true()
    assert_that(inner.execute_count).is_equal(2)

func test_cancel_ends_inner_if_still_running() -> void:
    var inner := TestCommand.new()
    inner.finished = false
    var command := PerpetualCommand.new(inner)
    
    CommandScheduler.schedule(command)
    CommandScheduler.run(0.01)
    CommandScheduler.cancel(command)

    assert_that(inner.end_count).is_equal(1)
    assert_that(inner.last_end_interrupted).is_true()
