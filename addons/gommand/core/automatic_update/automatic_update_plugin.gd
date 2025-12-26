@tool
extends EditorPlugin

## Editor plugin integration for the automatic update system
## Provides UI notifications and manual update controls

var _update_checker: UpdateChecker
var _config: AutomaticUpdateConfig
var _update_dialog: AcceptDialog
var _notification_shown: bool = false


func _enter_tree() -> void:
	_load_config()
	_update_checker = UpdateChecker.new(_config)
	add_child(_update_checker)

	_update_checker.update_available.connect(_on_update_available)
	_update_checker.update_started.connect(_on_update_started)
	_update_checker.update_progress.connect(_on_update_progress)
	_update_checker.update_completed.connect(_on_update_completed)
	_update_checker.update_failed.connect(_on_update_failed)
	
	add_tool_menu_item("Check for Updates", _on_manual_check_requested)


func _exit_tree() -> void:
	remove_tool_menu_item("Check for Updates")
	
	if _update_checker:
		_update_checker.queue_free()
		_update_checker = null
	
	if _update_dialog:
		_update_dialog.queue_free()
		_update_dialog = null


func _load_config() -> void:
	var config_path = "res://addons/gommand/core/automatic_update/update_config.tres"
	
	if FileAccess.file_exists(config_path):
		_config = load(config_path) as AutomaticUpdateConfig
	
	if not _config:
		_config = AutomaticUpdateConfig.new()
		_config.repo_owner = "COOKIE-POLICE"
		_config.repo_name = "gommand"
		_config.branch = "main"
		_config.addon_path = "addons/gommand"
		_config.check_on_startup = true
		_config.auto_check_enabled = true
		_config.show_notification = true

		var error = ResourceSaver.save(_config, config_path)
		if error != OK:
			push_warning("AutomaticUpdate: Failed to save default config: " + str(error))


func _on_update_available(current_sha: String, latest_sha: String, commit_message: String) -> void:
	if not _config.show_notification or _notification_shown:
		return
	
	_notification_shown = true
	_show_update_dialog(current_sha, latest_sha, commit_message)


func _show_update_dialog(current_sha: String, latest_sha: String, commit_message: String) -> void:
	if _update_dialog:
		_update_dialog.queue_free()
	
	_update_dialog = AcceptDialog.new()
	_update_dialog.title = "Gommand Update Available"
	_update_dialog.dialog_text = "A new update is available for Gommand!\n\n"
	_update_dialog.dialog_text += "Current version: " + current_sha.substr(0, 7) + "\n"
	_update_dialog.dialog_text += "Latest version: " + latest_sha.substr(0, 7) + "\n\n"
	
	if not commit_message.is_empty():
		var lines = commit_message.split("\n")
		_update_dialog.dialog_text += "Latest commit:\n" + lines[0] + "\n\n"
	
	_update_dialog.dialog_text += "Would you like to update now?"
	_update_dialog.ok_button_text = "Update Now"
	
	# Add Cancel button
	_update_dialog.add_cancel_button("Later")
	
	_update_dialog.confirmed.connect(_on_update_confirmed)
	_update_dialog.canceled.connect(_on_update_canceled)
	
	EditorInterface.get_base_control().add_child(_update_dialog)
	_update_dialog.popup_centered()


func _on_update_confirmed() -> void:
	print("AutomaticUpdate: User confirmed update")
	_update_checker.start_update()


func _on_update_canceled() -> void:
	print("AutomaticUpdate: User canceled update")
	_notification_shown = false


func _on_manual_check_requested() -> void:
	print("AutomaticUpdate: Manual update check requested")
	_notification_shown = false
	_update_checker.check_for_updates()

	var checking_dialog = AcceptDialog.new()
	checking_dialog.title = "Checking for Updates"
	checking_dialog.dialog_text = "Checking for updates..."
	checking_dialog.dialog_hide_on_ok = true
	
	EditorInterface.get_base_control().add_child(checking_dialog)
	checking_dialog.popup_centered()

	await _update_checker.update_check_completed
	checking_dialog.queue_free()


func _on_update_started() -> void:
	print("AutomaticUpdate: Update started")


func _on_update_progress(status: String) -> void:
	print("AutomaticUpdate: " + status)


func _on_update_completed() -> void:
	print("AutomaticUpdate: Update completed")

	var completion_dialog = AcceptDialog.new()
	completion_dialog.title = "Update Completed"
	completion_dialog.dialog_text = "Gommand has been updated successfully!\n\n"
	completion_dialog.dialog_text += "Please restart the Godot editor to apply the changes."
	completion_dialog.ok_button_text = "OK"
	
	EditorInterface.get_base_control().add_child(completion_dialog)
	completion_dialog.popup_centered()
	
	_notification_shown = false


func _on_update_failed(error: String) -> void:
	push_error("AutomaticUpdate: Update failed: " + error)

	var error_dialog = AcceptDialog.new()
	error_dialog.title = "Update Failed"
	error_dialog.dialog_text = "Failed to update Gommand:\n\n" + error
	error_dialog.ok_button_text = "OK"
	
	EditorInterface.get_base_control().add_child(error_dialog)
	error_dialog.popup_centered()
	
	_notification_shown = false
