class_name ActionTrigger
extends RefCounted

# A trigger that binds a Godot InputMap action name to command scheduling behavior.
# This supports scheduling on press/release, running while pressed, and toggling on press.

var action_name: String = ""
var previously_pressed: bool = false

var commands_on_action_pressed: Array = []
var commands_on_action_released: Array = []
var commands_while_action_pressed: Array = []
var toggle_states: Dictionary = {}

func _init(action_name_value: String) -> void:
	action_name = action_name_value
	previously_pressed = false
	CommandScheduler.register_action_trigger(self)

func add_on_action_pressed(command: Command) -> ActionTrigger:
	if command != null:
		commands_on_action_pressed.append(command)
	return self

func add_on_action_released(command: Command) -> ActionTrigger:
	if command != null:
		commands_on_action_released.append(command)
	return self

func add_while_action_pressed(command: Command) -> ActionTrigger:
	if command != null:
		commands_while_action_pressed.append(command)
	return self

func add_toggle_on_action_pressed(command: Command) -> ActionTrigger:
	if command != null:
		toggle_states[command] = false
	return self

func clear_all_bindings() -> void:
	commands_on_action_pressed.clear()
	commands_on_action_released.clear()
	commands_while_action_pressed.clear()
	toggle_states.clear()

# Called each scheduler run to update trigger state and schedule/cancel commands
func _update() -> void:
	var currently_pressed := Input.is_action_pressed(action_name)
	var rising_edge := currently_pressed and not previously_pressed
	var falling_edge := (not currently_pressed) and previously_pressed

	if rising_edge:
		# Schedule on pressed
		for command in commands_on_action_pressed:
			CommandScheduler.schedule(command)
		# Start while-pressed commands
		for command in commands_while_action_pressed:
			if not CommandScheduler.is_scheduled(command):
				CommandScheduler.schedule(command)
		# Toggle commands
		for command in toggle_states.keys():
			var is_toggled_on: bool = toggle_states[command]
			if not is_toggled_on:
				if CommandScheduler.schedule(command):
					toggle_states[command] = true
			else:
				CommandScheduler.cancel(command)
				toggle_states[command] = false

	if falling_edge:
		# Schedule on released
		for command in commands_on_action_released:
			CommandScheduler.schedule(command)
		# Stop while-pressed commands
		for command in commands_while_action_pressed:
			if CommandScheduler.is_scheduled(command):
				CommandScheduler.cancel(command)

	previously_pressed = currently_pressed


