extends GdUnitTestSuite

var _ready := false

func _predicate() -> bool:
    return _ready

func test_finishes_when_predicate_becomes_true() -> void:
    _ready = false
    var command := WaitUntilCommand.new(Callable(self, "_predicate"))

    CommandScheduler.schedule(command)
    CommandScheduler.run(0.01)
    assert_that(CommandScheduler.is_scheduled(command)).is_true()

    _ready = true
    CommandScheduler.run(0.01)
    assert_that(CommandScheduler.is_scheduled(command)).is_false()
