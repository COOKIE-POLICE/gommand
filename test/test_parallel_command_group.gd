extends GdUnitTestSuite

const TestCommand = preload("res://test/test_command.gd")

func test_initializes_all_children_and_finishes_when_all_done() -> void:
    
    var fast := TestCommand.new()
    fast.finish_after_executes = 1
    var slow := TestCommand.new()
    slow.finish_after_executes = 2

    var group := ParallelCommandGroup.new([fast, slow])
    CommandScheduler.schedule(group)

    CommandScheduler.run(0.01)
    assert_that(fast.initialize_count).is_equal(1)
    assert_that(slow.initialize_count).is_equal(1)
    assert_that(fast.end_count).is_equal(1)
    assert_that(slow.end_count).is_equal(0)
    assert_that(CommandScheduler.is_scheduled(group)).is_true()

    CommandScheduler.run(0.01)
    assert_that(slow.end_count).is_equal(1)
    assert_that(CommandScheduler.is_scheduled(group)).is_false()

func test_interrupt_ends_only_running_children() -> void:
    
    var finished := TestCommand.new()
    finished.finish_after_executes = 1
    var running := TestCommand.new()
    running.finish_after_executes = 999

    var group := ParallelCommandGroup.new([finished, running])
    CommandScheduler.schedule(group)
    CommandScheduler.run(0.01)
    assert_that(finished.end_count).is_equal(1)
    assert_that(running.end_count).is_equal(0)

    CommandScheduler.cancel(group)
    assert_that(running.end_count).is_equal(1)
    assert_that(running.last_end_interrupted).is_true()
