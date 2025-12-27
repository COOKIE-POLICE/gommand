extends GdUnitTestSuite

const TestNav = preload("res://test/test_pure_navigation_subsystem.gd")

func test_go_to_initializes_and_finishes() -> void:
    var nav := TestNav.new()
    var target := Vector3(1, 2, 3)
    var cmd := GoToCommand.new(nav, target, true)

    assert_that(CommandScheduler.schedule(cmd)).is_true()
    # First run triggers initialize
    CommandScheduler.run(0.01)

    # initialize should call go_to_position
    assert_that(nav.go_to_called_count).is_equal(1)
    assert_that(nav.last_target_position).is_equal(target)

    nav.navigation_finished = false
    CommandScheduler.run(0.01)
    assert_that(CommandScheduler.is_scheduled(cmd)).is_true()

    nav.navigation_finished = true
    CommandScheduler.run(0.01)
    assert_that(CommandScheduler.is_scheduled(cmd)).is_false()

func test_go_to_cancel_calls_stop() -> void:
    var nav := TestNav.new()
    var cmd := GoToCommand.new(nav, Vector3(5, 0, -2), true)

    CommandScheduler.schedule(cmd)
    CommandScheduler.run(0.01)
    assert_that(nav.stop_called_count).is_equal(0)

    CommandScheduler.cancel(cmd)
    assert_that(nav.stop_called_count).is_equal(1)
