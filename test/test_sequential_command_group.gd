extends GdUnitTestSuite

const TestCommand = preload("res://test/test_command.gd")

func test_runs_children_in_order_and_ends_each() -> void:
    
    var c1 := TestCommand.new()
    c1.finish_after_executes = 1
    var c2 := TestCommand.new()
    c2.finish_after_executes = 1

    var group := SequentialCommandGroup.new([c1, c2])
    CommandScheduler.schedule(group)

    CommandScheduler.run(0.01)
    assert_that(c1.initialize_count).is_equal(1)
    assert_that(c1.end_count).is_equal(1)
    assert_that(c2.initialize_count).is_equal(1)
    assert_that(c2.end_count).is_equal(0)
    assert_that(CommandScheduler.is_scheduled(group)).is_true()

    CommandScheduler.run(0.01)
    assert_that(c2.end_count).is_equal(1)
    assert_that(CommandScheduler.is_scheduled(group)).is_false()

func test_interrupt_ends_current_child_with_interrupted_true() -> void:
    
    var c1 := TestCommand.new()
    c1.finish_after_executes = 999
    var c2 := TestCommand.new()
    c2.finish_after_executes = 1

    var group := SequentialCommandGroup.new([c1, c2])
    CommandScheduler.schedule(group)
    CommandScheduler.run(0.01)
    assert_that(c1.initialize_count).is_equal(1)
    
    CommandScheduler.cancel(group)
    assert_that(c1.end_count).is_equal(1)
    assert_that(c1.last_end_interrupted).is_true()
