@tool
extends EditorPlugin

func _initialize_plugin() -> void:
	add_autoload_singleton("CommandScheduler", "res://addons/gommand/core/command_scheduler.gd")
	add_custom_type("Subsystem", "Node", preload("res://addons/gommand/core/subsystem.gd"), preload("res://addons/gommand/assets/editor_icons/gear.svg"))
func _deinitialize_plugin() -> void:
	remove_autoload_singleton("CommandScheduler")
	remove_custom_type("Subsystem")

func _enable_plugin() -> void:
	_initialize_plugin()


func _disable_plugin() -> void:
	_deinitialize_plugin()


func _enter_tree() -> void:
	_initialize_plugin()


func _exit_tree() -> void:
	_deinitialize_plugin()
