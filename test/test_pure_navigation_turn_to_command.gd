extends GdUnitTestSuite

const TestNav = preload("res://test/test_pure_navigation_subsystem.gd")

func test_turn_to_initializes_and_finishes() -> void:
    var nav := TestNav.new()
    var target := Vector3(0, 0, -1)
    var cmd := TurnToCommand.new(nav, target, true)

    assert_that(CommandScheduler.schedule(cmd)).is_true()
    # First run triggers initialize
    CommandScheduler.run(0.01)

    # initialize should call turn_to_heading with normalized vector
    assert_that(nav.turn_to_called_count).is_equal(1)
    assert_that(nav.last_target_heading).is_equal(target.normalized())

    # While not finished, command stays scheduled
    nav.navigation_finished = false
    CommandScheduler.run(0.01)
    assert_that(CommandScheduler.is_scheduled(cmd)).is_true()

    # When subsystem signals finished, command ends and unschedules
    nav.navigation_finished = true
    CommandScheduler.run(0.01)
    assert_that(CommandScheduler.is_scheduled(cmd)).is_false()

func test_turn_to_cancel_calls_stop() -> void:
    var nav := TestNav.new()
    var cmd := TurnToCommand.new(nav, Vector3.RIGHT, true)

    CommandScheduler.schedule(cmd)
    CommandScheduler.run(0.01)
    assert_that(nav.stop_called_count).is_equal(0)

    CommandScheduler.cancel(cmd)
    assert_that(nav.stop_called_count).is_equal(1)
