@icon("res://addons/gommand/assets/editor_icons/gear.svg")
class_name PureNavigation3DSubsystem
extends PureNavigationSubsystem


@export var movement_speed: float = 5.0
@export var rotation_speed: float = 5.0
@export var arrival_radius: float = 0.05

var _target_position: Vector3 = Vector3.ZERO
var _target_heading: Vector3 = Vector3.FORWARD
var _is_navigating: bool = false
var _is_turning: bool = false


func periodic(delta_time: float) -> void:
	super.periodic(delta_time)
	
	if _is_navigating:
		_update_navigation(delta_time)
	elif _is_turning:
		_update_turning(delta_time)

func physics_periodic(delta_time: float) -> void:
	super.physics_periodic(delta_time)
	
	# Call move_and_slide during physics process
	var parent_node = get_parent()
	if parent_node is CharacterBody3D and (_is_navigating or _is_turning):
		parent_node.move_and_slide()

func _update_navigation(delta_time: float) -> void:
	var parent_node = get_parent()
	if not is_instance_valid(parent_node) or not parent_node is CharacterBody3D:
		_is_navigating = false
		return
	
	var position: Vector3 = parent_node.global_transform.origin
	var direction: Vector3 = _target_position - position
	direction.y = 0
	var distance: float = direction.length()

	if distance <= arrival_radius:
		parent_node.velocity.x = 0
		parent_node.velocity.z = 0
		_is_navigating = false
		return

	var horizontal_velocity: Vector3 = direction.normalized() * movement_speed
	parent_node.velocity.x = horizontal_velocity.x
	parent_node.velocity.z = horizontal_velocity.z
	
	# Rotate towards movement direction
	if direction.length() > 0.01:
		var target_transform = parent_node.global_transform.looking_at(parent_node.global_position + direction, Vector3.UP)
		parent_node.global_transform = parent_node.global_transform.interpolate_with(target_transform, rotation_speed * delta_time)

func _update_turning(delta_time: float) -> void:
	var parent_node = get_parent()
	if parent_node == null or not parent_node is Node3D:
		_is_turning = false
		return
	
	var current_forward = -parent_node.global_transform.basis.z
	var angle_to_target = current_forward.signed_angle_to(_target_heading, Vector3.UP)
	
	if abs(angle_to_target) < 0.01:
		_is_turning = false
		return
	
	var rotation_amount = sign(angle_to_target) * min(abs(angle_to_target), rotation_speed * delta_time)
	parent_node.rotate_y(rotation_amount)

func go_to_position(target_position) -> void:
	_target_position = target_position
	_is_navigating = true
	_is_turning = false

func turn_to_heading(target_heading) -> void:
	if get_parent() == null or not get_parent() is Node3D:
		push_error("Parent must be a Node3D or derived type")
		return
	
	_target_heading = target_heading.normalized()
	_is_turning = true
	_is_navigating = false

func turn_by_amount(delta_heading) -> void:
	var parent_node = get_parent()
	if parent_node == null or not parent_node is Node3D:
		push_error("Parent must be a Node3D or derived type")
		return
	
	# Calculate new target heading based on current rotation
	var current_forward = -parent_node.global_transform.basis.z
	var rotation_transform = Transform3D().rotated(Vector3.UP, delta_heading)
	_target_heading = (rotation_transform * current_forward).normalized()
	_is_turning = true
	_is_navigating = false

func is_navigation_finished() -> bool:
	if _is_navigating:
		return false
	elif _is_turning:
		var parent_node = get_parent()
		if parent_node == null or not parent_node is Node3D:
			return true
		var current_forward = -parent_node.global_transform.basis.z
		var angle_to_target = current_forward.signed_angle_to(_target_heading, Vector3.UP)
		return abs(angle_to_target) < 0.01
	return true

func get_current_velocity() -> Vector3:
	var parent_node = get_parent()
	if parent_node is CharacterBody3D:
		return parent_node.velocity
	return Vector3.ZERO

func stop() -> void:
	_is_navigating = false
	_is_turning = false
	
	var parent_node = get_parent()
	if parent_node is CharacterBody3D:
		parent_node.velocity = Vector3.ZERO

func get_target_position() -> Vector3:
	return _target_position

func distance_to_target() -> float:
	var parent_node = get_parent()
	if parent_node is Node3D:
		return parent_node.global_position.distance_to(_target_position)
	return 0.0
