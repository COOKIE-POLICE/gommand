extends GdUnitTestSuite

const TestCommand = preload("res://test/test_command.gd")

func test_schedules_on_rising_edge_only() -> void:
	var cmd := TestCommand.new()
	cmd.finished = false

	var trigger := ActionTrigger.new("gommand_test_pressed")
	trigger.add_on_action_pressed(cmd)

	Input.action_press("gommand_test_pressed")
	CommandScheduler.run(0.01)
	assert_that(CommandScheduler.is_scheduled(cmd)).is_true()
	CommandScheduler.run(0.01)
	assert_that(CommandScheduler.is_scheduled(cmd)).is_true()

	Input.action_release("gommand_test_pressed")
	CommandScheduler.run(0.01)
	assert_that(CommandScheduler.is_scheduled(cmd)).is_true()

	

func test_schedules_on_falling_edge() -> void:
	var cmd := TestCommand.new()
	cmd.finished = false

	var trigger := ActionTrigger.new("gommand_test_released")
	trigger.add_on_action_released(cmd)

	Input.action_press("gommand_test_released")
	CommandScheduler.run(0.01)
	assert_that(CommandScheduler.is_scheduled(cmd)).is_false()

	Input.action_release("gommand_test_released")
	CommandScheduler.run(0.01)
	assert_that(CommandScheduler.is_scheduled(cmd)).is_true()

	

func test_toggles_command_on_each_press() -> void:
	var cmd := TestCommand.new()
	cmd.finished = false

	var trigger := ActionTrigger.new("gommand_test_toggle")
	trigger.add_toggle_on_action_pressed(cmd)

	# First press toggles on
	Input.action_press("gommand_test_toggle")
	CommandScheduler.run(0.01)
	assert_that(CommandScheduler.is_scheduled(cmd)).is_true()

	Input.action_release("gommand_test_toggle")
	CommandScheduler.run(0.01)
	assert_that(CommandScheduler.is_scheduled(cmd)).is_true()

	# Second press toggles off
	Input.action_press("gommand_test_toggle")
	CommandScheduler.run(0.01)
	assert_that(CommandScheduler.is_scheduled(cmd)).is_false()
	assert_that(cmd.end_count).is_equal(1)
	assert_that(cmd.last_end_interrupted).is_true()

	Input.action_release("gommand_test_toggle")
	CommandScheduler.run(0.01)

	

func test_schedules_while_pressed_and_cancels_on_release() -> void:
	var cmd := TestCommand.new()
	cmd.finished = false

	var trigger := ActionTrigger.new("gommand_test_while")
	trigger.add_while_action_pressed(cmd)

	Input.action_press("gommand_test_while")
	CommandScheduler.run(0.01)
	assert_that(CommandScheduler.is_scheduled(cmd)).is_true()

	Input.action_release("gommand_test_while")
	CommandScheduler.run(0.01)
	assert_that(CommandScheduler.is_scheduled(cmd)).is_false()
	assert_that(cmd.end_count).is_equal(1)
	assert_that(cmd.last_end_interrupted).is_true()

	
