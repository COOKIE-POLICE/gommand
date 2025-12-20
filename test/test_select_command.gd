extends GdUnitTestSuite

const TestCommand = preload("res://test/test_command.gd")

var _key := "a"

func _select() -> String:
    return _key

func test_selects_command_by_key() -> void:
    _key = "b"
    var a := TestCommand.new()
    a.finish_after_executes = 1
    var b := TestCommand.new()
    b.finish_after_executes = 1

    var command := SelectCommand.new(Callable(self, "_select"), {"a": a, "b": b})
    CommandScheduler.schedule(command)
    CommandScheduler.run(0.01)

    assert_that(a.initialize_count).is_equal(0)
    assert_that(b.initialize_count).is_equal(1)
    assert_that(CommandScheduler.is_scheduled(command)).is_false()

func test_missing_key_finishes_immediately() -> void:
    _key = "missing"
    
    var a := TestCommand.new()
    var command := SelectCommand.new(Callable(self, "_select"), {"a": a})
    CommandScheduler.schedule(command)
    CommandScheduler.run(0.01)
    assert_that(CommandScheduler.is_scheduled(command)).is_false()
    assert_that(a.initialize_count).is_equal(0)
