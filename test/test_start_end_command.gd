extends GdUnitTestSuite

var _started := 0
var _ended := 0

func _on_start() -> void:
    _started += 1

func _on_end() -> void:
    _ended += 1

func test_start_end_callables_trigger_and_cancel_calls_end() -> void:
    _started = 0
    _ended = 0
    var cmd := StartEndCommand.new(Callable(self, "_on_start"), Callable(self, "_on_end"))

    assert_that(CommandScheduler.schedule(cmd)).is_true()
    CommandScheduler.run(0.01)
    assert_that(_started).is_equal(1)
    assert_that(_ended).is_equal(0)

    CommandScheduler.cancel(cmd)
    assert_that(_ended).is_equal(1)
