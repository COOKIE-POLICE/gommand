extends GdUnitTestSuite

var _exec_calls := 0
var _total_delta := 0.0

func _run(delta: float) -> void:
    _exec_calls += 1
    _total_delta += delta

func test_never_finishes_and_executes_each_run() -> void:
    _exec_calls = 0
    _total_delta = 0.0
    var command := RunCommand.new(Callable(self, "_run"))

    CommandScheduler.schedule(command)
    CommandScheduler.run(0.1)
    CommandScheduler.run(0.2)
    CommandScheduler.run(0.3)

    assert_that(_exec_calls).is_equal(3)
    assert_that(_total_delta).is_equal_approx(0.6, 0.0001)
    assert_that(CommandScheduler.is_scheduled(command)).is_true()
