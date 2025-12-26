@tool
class_name UpdateChecker
extends Node

## Checks for updates and manages the update process
## This is the main controller for the automatic update system

signal update_available(current_sha: String, latest_sha: String, commit_message: String)
signal update_check_completed(has_update: bool)
signal update_failed(error: String)
signal update_started()
signal update_progress(status: String)
signal update_completed()

var _config: AutomaticUpdateConfig
var _github_api: GitHubAPI
var _check_timer: Timer
var _is_checking: bool = false
var _is_updating: bool = false


func _init(config: AutomaticUpdateConfig = null) -> void:
	if config:
		_config = config
	else:
		_config = AutomaticUpdateConfig.new()


func _ready() -> void:
	if not _config:
		push_error("AutomaticUpdate: UpdateChecker has no config")
		return
	
	_github_api = GitHubAPI.new(_config)
	_github_api.commit_info_retrieved.connect(_on_commit_info_retrieved)
	_github_api.request_failed.connect(_on_request_failed)
	_github_api.download_completed.connect(_on_download_completed)
	
	if _config.auto_check_enabled:
		_setup_timer()
		
		if _config.check_on_startup:
			# Delay initial check to allow everything to initialize
			await get_tree().create_timer(2.0).timeout
			check_for_updates()


func _setup_timer() -> void:
	if _check_timer:
		_check_timer.queue_free()
	
	_check_timer = Timer.new()
	_check_timer.wait_time = _config.check_interval
	_check_timer.one_shot = false
	_check_timer.timeout.connect(check_for_updates)
	add_child(_check_timer)
	_check_timer.start()


## Manually check for updates
func check_for_updates() -> void:
	if _is_checking or _is_updating:
		return
	
	_is_checking = true
	_github_api.get_latest_commit()


func _on_commit_info_retrieved(commit_data: Dictionary) -> void:
	_is_checking = false
	
	if not commit_data.has("sha"):
		push_error("AutomaticUpdate: Commit data missing SHA")
		update_check_completed.emit(false)
		return
	
	var latest_sha: String = commit_data["sha"]
	var commit_message: String = ""
	
	if commit_data.has("commit") and commit_data["commit"] is Dictionary:
		var commit_info = commit_data["commit"]
		if commit_info.has("message"):
			commit_message = commit_info["message"]
	
	# Check if we have a current SHA and if it differs
	var has_update = false
	if _config.current_commit_sha.is_empty():
		# First time checking, save current SHA without notification
		print("AutomaticUpdate: Recording initial commit SHA: " + latest_sha)
		_config.current_commit_sha = latest_sha
		_save_config()
		has_update = false
	elif _config.current_commit_sha != latest_sha:
		# Update available
		has_update = true
		print("AutomaticUpdate: Update available! Current: " + _config.current_commit_sha + ", Latest: " + latest_sha)
		update_available.emit(_config.current_commit_sha, latest_sha, commit_message)
	else:
		print("AutomaticUpdate: Already up to date (" + latest_sha + ")")
	
	update_check_completed.emit(has_update)


func _on_request_failed(error: String) -> void:
	_is_checking = false
	_is_updating = false
	push_error("AutomaticUpdate: Request failed: " + error)
	update_failed.emit(error)


## Start the update process
func start_update() -> void:
	if _is_updating:
		push_warning("AutomaticUpdate: Update already in progress")
		return
	
	if not DirAccess.dir_exists_absolute("user://"):
		DirAccess.make_dir_absolute("user://")
	
	_is_updating = true
	update_started.emit()
	update_progress.emit("Downloading update...")
	
	var temp_path = "user://temp_update.zip"
	_github_api.download_repository_zip(temp_path)


func _on_download_completed(success: bool, file_path: String) -> void:
	if not success:
		_is_updating = false
		update_failed.emit("Failed to download update")
		return
	
	update_progress.emit("Extracting update...")
	
	# Extract and install the update
	await get_tree().process_frame
	_extract_and_install(file_path)


func _extract_and_install(zip_path: String) -> void:
	var zip_reader = ZIPReader.new()
	var err = zip_reader.open(zip_path)
	
	if err != OK:
		_is_updating = false
		update_failed.emit("Failed to open ZIP file")
		return
	
	update_progress.emit("Installing update...")
	
	# Get list of files in the zip
	var files = zip_reader.get_files()
	
	# Find the addon directory in the zip (usually in format: repo-name-branch/addons/...)
	var addon_prefix = ""
	for file in files:
		if "/addons/" in file:
			addon_prefix = file.split("/addons/")[0] + "/"
			break
	
	if addon_prefix.is_empty():
		zip_reader.close()
		_is_updating = false
		update_failed.emit("Could not find addon in repository")
		return
	
	# Delete the existing addon directory for a clean install
	var target_addon_path = "res://" + _config.addon_path
	if DirAccess.dir_exists_absolute(target_addon_path):
		update_progress.emit("Removing old version...")
		var delete_result = _delete_directory_recursive(target_addon_path)
		if not delete_result:
			zip_reader.close()
			_is_updating = false
			update_failed.emit("Failed to remove old addon directory")
			return
		print("AutomaticUpdate: Removed old addon directory: " + target_addon_path)
	
	# Extract relevant files
	var extracted_count = 0
	
	for file in files:
		if not file.begins_with(addon_prefix + "addons/"):
			continue
		
		# Skip if it's a directory
		if file.ends_with("/"):
			continue
		
		# Calculate target path
		var relative_path = file.substr(addon_prefix.length())
		var target_path = "res://" + relative_path
		
		# Create directory if needed
		var dir_path = target_path.get_base_dir()
		if not DirAccess.dir_exists_absolute(dir_path):
			DirAccess.make_dir_recursive_absolute(dir_path)
		
		# Read file from zip
		var file_data = zip_reader.read_file(file)
		
		# Write to disk
		var target_file = FileAccess.open(target_path, FileAccess.WRITE)
		if target_file:
			target_file.store_buffer(file_data)
			target_file.close()
			extracted_count += 1
		else:
			push_warning("AutomaticUpdate: Failed to write file: " + target_path)
	
	zip_reader.close()
	
	# Clean up temp file
	DirAccess.remove_absolute(zip_path)
	
	# Update the current commit SHA by checking again
	_config.current_commit_sha = ""  # Reset to force update
	_save_config()
	
	_is_updating = false
	update_progress.emit("Update completed! Extracted " + str(extracted_count) + " files.")
	update_completed.emit()
	
	print("AutomaticUpdate: Update completed successfully. Please restart the editor to apply changes.")


func _save_config() -> void:
	if not _config:
		return
	
	# Always save to core/automatic_update directory
	var config_path = "res://" + _config.addon_path.path_join("core/automatic_update/update_config.tres")
	var err = ResourceSaver.save(_config, config_path)
	if err != OK:
		push_warning("AutomaticUpdate: Failed to save config to " + config_path + ": " + str(err))
	else:
		print("AutomaticUpdate: Config saved to " + config_path)


func _delete_directory_recursive(path: String) -> bool:
	var dir = DirAccess.open(path)
	if not dir:
		push_warning("AutomaticUpdate: Failed to open directory: " + path)
		return false
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
		
		var file_path = path.path_join(file_name)
		
		if dir.current_is_dir():
			# Recursively delete subdirectory
			if not _delete_directory_recursive(file_path):
				dir.list_dir_end()
				return false
		else:
			# Delete file
			var delete_err = DirAccess.remove_absolute(file_path)
			if delete_err != OK:
				push_warning("AutomaticUpdate: Failed to delete file: " + file_path)
				dir.list_dir_end()
				return false
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	# Delete the directory itself
	var remove_err = DirAccess.remove_absolute(path)
	if remove_err != OK:
		push_warning("AutomaticUpdate: Failed to delete directory: " + path)
		return false
	
	return true


func set_config(config: AutomaticUpdateConfig) -> void:
	_config = config
	if is_inside_tree():
		_github_api = GitHubAPI.new(_config)
		_github_api.commit_info_retrieved.connect(_on_commit_info_retrieved)
		_github_api.request_failed.connect(_on_request_failed)
		_github_api.download_completed.connect(_on_download_completed)


func get_config() -> AutomaticUpdateConfig:
	return _config


func _exit_tree() -> void:
	if _check_timer:
		_check_timer.queue_free()
