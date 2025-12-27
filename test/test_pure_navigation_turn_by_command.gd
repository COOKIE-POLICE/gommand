extends GdUnitTestSuite

const TestNav = preload("res://test/test_pure_navigation_subsystem.gd")

func test_turn_by_initializes_and_finishes() -> void:
    var nav := TestNav.new()
    var delta := PI / 4.0
    var cmd := TurnByCommand.new(nav, delta, true)

    assert_that(CommandScheduler.schedule(cmd)).is_true()
    # First run triggers initialize
    CommandScheduler.run(0.01)

    # initialize should call turn_by_amount
    assert_that(nav.turn_by_called_count).is_equal(1)
    assert_that(nav.last_delta_heading).is_equal(delta)

    nav.navigation_finished = false
    CommandScheduler.run(0.01)
    assert_that(CommandScheduler.is_scheduled(cmd)).is_true()

    nav.navigation_finished = true
    CommandScheduler.run(0.01)
    assert_that(CommandScheduler.is_scheduled(cmd)).is_false()

func test_turn_by_cancel_calls_stop() -> void:
    var nav := TestNav.new()
    var cmd := TurnByCommand.new(nav, -PI / 2.0, true)

    CommandScheduler.schedule(cmd)
    CommandScheduler.run(0.01)
    assert_that(nav.stop_called_count).is_equal(0)

    CommandScheduler.cancel(cmd)
    assert_that(nav.stop_called_count).is_equal(1)
