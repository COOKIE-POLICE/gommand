extends GdUnitTestSuite

func test_waits_for_duration_then_finishes() -> void:
    var command := WaitCommand.new(0.02)
    command._on_scheduled()
    command.initialize()
    command._mark_initialized()

    assert_that(command.is_finished()).is_false()
    var timer := get_tree().create_timer(0.2)
    auto_free(timer)
    await timer.timeout
    assert_that(command.is_finished()).is_true()
