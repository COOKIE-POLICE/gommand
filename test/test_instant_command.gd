extends GdUnitTestSuite

var _called := 0

func _inc() -> void:
    _called += 1

func test_runs_action_once_and_finishes_immediately() -> void:
    _called = 0
    var command := InstantCommand.new(Callable(self, "_inc"))

    assert_that(CommandScheduler.schedule(command)).is_true()
    CommandScheduler.run(0.01)

    assert_that(_called).is_equal(1)
    assert_that(CommandScheduler.is_scheduled(command)).is_false()
