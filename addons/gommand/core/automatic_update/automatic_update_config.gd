@tool
class_name AutomaticUpdateConfig
extends Resource

## GitHub repository owner
@export var repo_owner: String = ""

## GitHub repository name
@export var repo_name: String = ""

## Branch to track (usually "main" or "master")
@export var branch: String = "main"

## Local addon path (relative to res://)
@export var addon_path: String = ""

## Check for updates on startup
@export var check_on_startup: bool = true

## Check interval in seconds (default: 1 hour)
@export var check_interval: float = 3600.0

## Enable automatic checks
@export var auto_check_enabled: bool = true

## Current installed commit SHA (empty if not set)
@export var current_commit_sha: String = ""

## Show notification when update is available
@export var show_notification: bool = true


func _init(p_repo_owner: String = "", p_repo_name: String = "", p_addon_path: String = "") -> void:
	repo_owner = p_repo_owner
	repo_name = p_repo_name
	addon_path = p_addon_path
