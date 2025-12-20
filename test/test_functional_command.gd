extends GdUnitTestSuite

var _init_calls := 0
var _exec_calls := 0
var _end_calls := 0
var _last_end_interrupted := false
var _finish_after := 2

func _init_fn() -> void:
    _init_calls += 1

func _exec_fn(_delta: float) -> void:
    _exec_calls += 1

func _end_fn(interrupted: bool) -> void:
    _end_calls += 1
    _last_end_interrupted = interrupted

func _is_finished_fn() -> bool:
    return _exec_calls >= _finish_after

func test_calls_lifecycle_callables_and_finishes() -> void:
    _init_calls = 0
    _exec_calls = 0
    _end_calls = 0
    _last_end_interrupted = false
    _finish_after = 2

    var command := FunctionalCommand.new(
        Callable(self, "_init_fn"),
        Callable(self, "_exec_fn"),
        Callable(self, "_end_fn"),
        Callable(self, "_is_finished_fn")
    )
    CommandScheduler.schedule(command)
    CommandScheduler.run(0.1)
    assert_that(_init_calls).is_equal(1)
    assert_that(_exec_calls).is_equal(1)
    assert_that(_end_calls).is_equal(0)

    CommandScheduler.run(0.1)
    assert_that(_exec_calls).is_equal(2)
    assert_that(_end_calls).is_equal(1)
    assert_that(_last_end_interrupted).is_false()
    assert_that(CommandScheduler.is_scheduled(command)).is_false()

func test_end_callable_receives_interrupted_on_cancel() -> void:
    _init_calls = 0
    _exec_calls = 0
    _end_calls = 0
    _last_end_interrupted = false
    _finish_after = 999

    var command := FunctionalCommand.new(
        Callable(self, "_init_fn"),
        Callable(self, "_exec_fn"),
        Callable(self, "_end_fn"),
        Callable(self, "_is_finished_fn")
    )

    CommandScheduler.schedule(command)
    CommandScheduler.run(0.01)
    CommandScheduler.cancel(command)

    assert_that(_end_calls).is_equal(1)
    assert_that(_last_end_interrupted).is_true()
