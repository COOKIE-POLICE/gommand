extends GdUnitTestSuite

const TestCommand = preload("res://test/test_command.gd")

var _condition := true

func _condition_fn() -> bool:
    return _condition

func test_selects_true_command_and_runs_it() -> void:
    _condition = true
    
    var on_true := TestCommand.new()
    on_true.finish_after_executes = 1
    var on_false := TestCommand.new()
    on_false.finish_after_executes = 1

    var command := ConditionalCommand.new(Callable(self, "_condition_fn"), on_true, on_false)
    CommandScheduler.schedule(command)
    CommandScheduler.run(0.01)

    assert_that(on_true.initialize_count).is_equal(1)
    assert_that(on_false.initialize_count).is_equal(0)
    assert_that(CommandScheduler.is_scheduled(command)).is_false()

func test_when_selected_command_is_null_finishes_immediately() -> void:
    _condition = false
    var on_true := TestCommand.new()
    var command := ConditionalCommand.new(Callable(self, "_condition_fn"), on_true, null)
    CommandScheduler.schedule(command)
    CommandScheduler.run(0.01)
    assert_that(CommandScheduler.is_scheduled(command)).is_false()
    assert_that(on_true.initialize_count).is_equal(0)
