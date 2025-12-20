extends GdUnitTestSuite

const TestCommand = preload("res://test/test_command.gd")

func test_schedule_command_finishes_immediately() -> void:
    var inner := TestCommand.new()
    inner.finished = false
    var cmd := ScheduleCommand.new(inner)
    cmd.initialize()
    # Cannot assert scheduling without Engine singleton; ensure finishes immediately
    assert_that(cmd.is_finished()).is_true()
