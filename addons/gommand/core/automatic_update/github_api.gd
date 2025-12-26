@tool
class_name GitHubAPI
extends RefCounted

## GitHub API integration for checking repository updates
## Handles communication with GitHub REST API

const GITHUB_API_BASE = "https://api.github.com"

## Signal emitted when latest commit info is retrieved
signal commit_info_retrieved(commit_data: Dictionary)
## Signal emitted when request fails
signal request_failed(error: String)

var _http_request: HTTPRequest
var _config: AutomaticUpdateConfig


func _init(config: AutomaticUpdateConfig) -> void:
	_config = config


## Get the latest commit from a branch
func get_latest_commit() -> void:
	if not _config:
		push_error("AutomaticUpdate: No config provided")
		request_failed.emit("No configuration")
		return
	
	if _http_request:
		_http_request.queue_free()
	
	_http_request = HTTPRequest.new()
	_http_request.request_completed.connect(_on_commit_request_completed)
	
	# Add to scene tree temporarily (required for HTTPRequest to work)
	if Engine.get_main_loop():
		Engine.get_main_loop().root.add_child(_http_request)
	
	var url = "%s/repos/%s/%s/commits/%s" % [
		GITHUB_API_BASE,
		_config.repo_owner,
		_config.repo_name,
		_config.branch
	]
	
	var headers = [
		"User-Agent: Godot-AutoUpdate",
		"Accept: application/vnd.github.v3+json"
	]
	
	var error = _http_request.request(url, headers)
	if error != OK:
		push_error("AutomaticUpdate: Failed to send request: " + str(error))
		request_failed.emit("Request failed: " + str(error))
		_cleanup()


func _on_commit_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("AutomaticUpdate: Request failed with result: " + str(result))
		request_failed.emit("Request failed with result: " + str(result))
		_cleanup()
		return
	
	if response_code != 200:
		push_error("AutomaticUpdate: GitHub API returned status code: " + str(response_code))
		request_failed.emit("GitHub API error: " + str(response_code))
		_cleanup()
		return
	
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	
	if parse_result != OK:
		push_error("AutomaticUpdate: Failed to parse JSON response")
		request_failed.emit("Failed to parse response")
		_cleanup()
		return
	
	var data = json.data
	if not data is Dictionary:
		push_error("AutomaticUpdate: Invalid response format")
		request_failed.emit("Invalid response format")
		_cleanup()
		return
	
	commit_info_retrieved.emit(data)
	_cleanup()


func _cleanup() -> void:
	if _http_request:
		_http_request.queue_free()
		_http_request = null


## Download repository as ZIP archive
func download_repository_zip(output_path: String) -> void:
	if not _config:
		push_error("AutomaticUpdate: No config provided")
		request_failed.emit("No configuration")
		return
	
	if _http_request:
		_http_request.queue_free()
	
	_http_request = HTTPRequest.new()
	_http_request.request_completed.connect(_on_download_completed.bind(output_path))
	_http_request.set_download_file(output_path)
	
	if Engine.get_main_loop():
		Engine.get_main_loop().root.add_child(_http_request)
	
	var url = "https://github.com/%s/%s/archive/refs/heads/%s.zip" % [
		_config.repo_owner,
		_config.repo_name,
		_config.branch
	]
	
	var headers = ["User-Agent: Godot-AutoUpdate"]
	
	var error = _http_request.request(url, headers)
	if error != OK:
		push_error("AutomaticUpdate: Failed to send download request: " + str(error))
		request_failed.emit("Download request failed: " + str(error))
		_cleanup()


signal download_completed(success: bool, file_path: String)


func _on_download_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, output_path: String) -> void:
	var success = result == HTTPRequest.RESULT_SUCCESS and response_code == 200
	
	if not success:
		push_error("AutomaticUpdate: Download failed. Result: %d, Status: %d" % [result, response_code])
		request_failed.emit("Download failed")
	
	download_completed.emit(success, output_path)
	_cleanup()
