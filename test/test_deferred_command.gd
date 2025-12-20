extends GdUnitTestSuite

const TestCommand = preload("res://test/test_command.gd")

var _factory_calls := 0

func _factory() -> Command:
    _factory_calls += 1
    var inner := TestCommand.new()
    inner.finish_after_executes = 1
    return inner

func test_creates_inner_command_on_initialize_and_forwards_calls() -> void:
    _factory_calls = 0
    var deferred := DeferredCommand.new(Callable(self, "_factory"))

    CommandScheduler.schedule(deferred)
    CommandScheduler.run(0.1)

    assert_that(_factory_calls).is_equal(1)
    # Deferred finishes after first execute (inner finishes)
    assert_that(CommandScheduler.is_scheduled(deferred)).is_false()
