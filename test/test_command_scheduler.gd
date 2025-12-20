extends GdUnitTestSuite

const TestCommand = preload("res://test/test_command.gd")
const TestSubsystem = preload("res://test/test_subsystem.gd")

func test_schedule_null_returns_false() -> void:
	assert_that(CommandScheduler.schedule(null)).is_false()

func test_schedules_initializes_executes_and_finishes() -> void:
	
	var command := TestCommand.new()
	command.finish_after_executes = 2

	assert_that(CommandScheduler.schedule(command)).is_true()
	assert_that(CommandScheduler.is_scheduled(command)).is_true()
	assert_that(command.initialize_count).is_equal(0)

	CommandScheduler.run(0.1)
	assert_that(command.initialize_count).is_equal(1)
	assert_that(command.execute_count).is_equal(1)
	assert_that(command.end_count).is_equal(0)
	assert_that(CommandScheduler.is_scheduled(command)).is_true()

	CommandScheduler.run(0.2)
	assert_that(command.execute_count).is_equal(2)
	assert_that(command.end_count).is_equal(1)
	assert_that(command.last_end_interrupted).is_false()
	assert_that(CommandScheduler.is_scheduled(command)).is_false()

func test_cancel_calls_end_interrupted_and_unschedules() -> void:
	
	var command := TestCommand.new()

	CommandScheduler.schedule(command)
	CommandScheduler.run(0.01)
	assert_that(CommandScheduler.is_scheduled(command)).is_true()

	CommandScheduler.cancel(command)
	assert_that(command.end_count).is_equal(1)
	assert_that(command.last_end_interrupted).is_true()
	assert_that(CommandScheduler.is_scheduled(command)).is_false()

func test_runs_subsystem_periodic_and_schedules_default_when_idle() -> void:
	var subsystem := TestSubsystem.new()

	var default_command := TestCommand.new([subsystem], true)
	default_command.finished = false
	subsystem.set_default_command(default_command)
	CommandScheduler.register_subsystem(subsystem)

	assert_that(CommandScheduler.is_scheduled(default_command)).is_false()
	assert_that(subsystem.periodic_count).is_equal(0)

	CommandScheduler.run(0.05)
	# periodic runs immediately
	assert_that(subsystem.periodic_count).is_equal(1)
	# default command is scheduled at the end of run
	assert_that(CommandScheduler.is_scheduled(default_command)).is_true()
