extends GdUnitTestSuite

const TestCommand = preload("res://test/test_command.gd")

func test_finishes_when_any_child_finishes_and_ends_others() -> void:
    
    var winner := TestCommand.new()
    winner.finish_after_executes = 1
    var loser := TestCommand.new()
    loser.finish_after_executes = 999

    var group := ParallelRaceGroup.new([winner, loser])
    CommandScheduler.schedule(group)
    CommandScheduler.run(0.01)

    assert_that(winner.end_count).is_equal(1)
    assert_that(loser.end_count).is_equal(1)
    assert_that(loser.last_end_interrupted).is_false()
    assert_that(CommandScheduler.is_scheduled(group)).is_false()
