extends GdUnitTestSuite

func test_default_state() -> void:
    var command := Command.new()
    assert_that(command._is_scheduled()).is_false()
    assert_that(command._has_initialized()).is_false()
    assert_that(command.is_interruptible()).is_true()
    assert_that(command.get_requirements().size()).is_equal(0)

func test_internal_schedule_state_transitions() -> void:
    var command := Command.new()
    command._on_scheduled()
    assert_that(command._is_scheduled()).is_true()
    assert_that(command._has_initialized()).is_false()

    command._mark_initialized()
    assert_that(command._has_initialized()).is_true()

    command._on_unscheduled()
    assert_that(command._is_scheduled()).is_false()

const TestSubsystem = preload("res://test/test_subsystem.gd")

func test_requirements_and_interruptible_mutators() -> void:
    var s1 := TestSubsystem.new()
    var s2 := TestSubsystem.new()

    var command := Command.new([s1], true)
    assert_that(command.get_requirements()).contains([s1])
    assert_that(command.is_interruptible()).is_true()

    command.add_requirement(s2)
    assert_that(command.get_requirements()).contains([s1, s2])

    command.set_interruptible(false)
    assert_that(command.is_interruptible()).is_false()
