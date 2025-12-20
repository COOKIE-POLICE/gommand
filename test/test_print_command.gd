extends GdUnitTestSuite

func test_print_command_finishes_immediately() -> void:
    var cmd := PrintCommand.new("hello")
    cmd.initialize()
    assert_that(cmd.is_finished()).is_true()
