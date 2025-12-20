extends GdUnitTestSuite

const TestCommand = preload("res://test/test_command.gd")

func test_repeats_inner_command_given_times() -> void:
    
    var inner := TestCommand.new()
    inner.finish_after_executes = 1
    var repeat := RepeatCommand.new(inner, 2)
    
    CommandScheduler.schedule(repeat)
    CommandScheduler.run(0.01)
    CommandScheduler.run(0.01)

    assert_that(repeat.is_finished()).is_true()
    assert_that(inner.end_count).is_equal(2)
