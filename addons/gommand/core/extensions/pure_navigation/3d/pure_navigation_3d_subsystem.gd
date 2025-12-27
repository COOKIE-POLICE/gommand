@icon("res://addons/gommand/assets/editor_icons/gear.svg")
class_name PureNavigation3DSubsystem
extends PureNavigationSubsystem


## Optional NavigationAgent3D reference. If not set, a default agent will be created automatically.
@export var navigation_agent: NavigationAgent3D = null

@export var movement_speed: float = 5.0
@export var rotation_speed: float = 5.0
@export var acceleration: float = 10.0

var _target_position: Vector3 = Vector3.ZERO
var _target_heading: Vector3 = Vector3.FORWARD
var _is_navigating: bool = false
var _is_turning: bool = false
var _turn_by_radians: float = 0.0

func _ready() -> void:
	_setup_navigation_agent()

func _setup_navigation_agent() -> void:
	# If no navigation agent was provided, create a default one
	if navigation_agent == null:
		navigation_agent = NavigationAgent3D.new()
		get_parent().add_child(navigation_agent)
	
	# Connect velocity signal if using avoidance
	if not navigation_agent.velocity_computed.is_connected(_on_velocity_computed):
		navigation_agent.velocity_computed.connect(_on_velocity_computed)

func periodic(delta_time: float) -> void:
	super.periodic(delta_time)
	
	if _is_navigating:
		_update_navigation(delta_time)
	elif _is_turning:
		_update_turning(delta_time)

func _update_navigation(delta_time: float) -> void:
	if navigation_agent == null or get_parent() == null:
		return
	
	if navigation_agent.is_navigation_finished():
		_is_navigating = false
		stop()
		return
	
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var parent_node = get_parent()
	
	# Calculate direction to next waypoint
	var direction = (next_path_position - parent_node.global_position).normalized()
	
	# Handle different parent node types
	if parent_node is CharacterBody3D:
		_move_character_body(parent_node, direction, delta_time)
	elif parent_node is RigidBody3D:
		_move_rigid_body(parent_node, direction, delta_time)
	elif parent_node is Node3D:
		_move_node3d(parent_node, direction, delta_time)

func _move_character_body(character_body: CharacterBody3D, direction: Vector3, delta_time: float) -> void:
	if navigation_agent.avoidance_enabled:
		navigation_agent.velocity = direction * movement_speed
	else:
		var target_velocity = direction * movement_speed
		character_body.velocity = character_body.velocity.move_toward(target_velocity, acceleration * delta_time)
		
		if direction.length() > 0.01:
			var target_transform = character_body.global_transform.looking_at(character_body.global_position + direction, Vector3.UP)
			character_body.global_transform = character_body.global_transform.interpolate_with(target_transform, rotation_speed * delta_time)
		
		character_body.move_and_slide()

func _move_rigid_body(rigid_body: RigidBody3D, direction: Vector3, delta_time: float) -> void:
	var desired_velocity = direction * movement_speed
	var velocity_change = desired_velocity - rigid_body.linear_velocity
	var force = velocity_change * rigid_body.mass * acceleration
	rigid_body.apply_central_force(force)
	if direction.length() > 0.01:
		var target_basis = Basis.looking_at(direction, Vector3.UP)
		var current_basis = rigid_body.global_transform.basis
		rigid_body.global_transform.basis = current_basis.slerp(target_basis, rotation_speed * delta_time)

func _move_node3d(node: Node3D, direction: Vector3, delta_time: float) -> void:
	node.global_position += direction * movement_speed * delta_time
	
	if direction.length() > 0.01:
		var target_transform = node.global_transform.looking_at(node.global_position + direction, Vector3.UP)
		node.global_transform = node.global_transform.interpolate_with(target_transform, rotation_speed * delta_time)

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

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	var parent_node = get_parent()
	if parent_node is CharacterBody3D:
		parent_node.velocity = safe_velocity
		parent_node.move_and_slide()

func go_to_position(target_position) -> void:
	if navigation_agent == null:
		push_error("NavigationAgent3D not initialized")
		return
	
	_target_position = target_position
	navigation_agent.target_position = target_position
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
		return navigation_agent != null and navigation_agent.is_navigation_finished()
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
	elif parent_node is RigidBody3D:
		return parent_node.linear_velocity
	return Vector3.ZERO

func stop() -> void:
	_is_navigating = false
	_is_turning = false
	
	var parent_node = get_parent()
	if parent_node is CharacterBody3D:
		parent_node.velocity = Vector3.ZERO
	elif parent_node is RigidBody3D:
		parent_node.linear_velocity = Vector3.ZERO
		parent_node.angular_velocity = Vector3.ZERO

func set_navigation_target(target_position: Vector3) -> void:
	if navigation_agent != null:
		navigation_agent.target_position = target_position

func get_navigation_target() -> Vector3:
	if navigation_agent != null:
		return navigation_agent.target_position
	return Vector3.ZERO

func get_next_path_position() -> Vector3:
	if navigation_agent != null:
		return navigation_agent.get_next_path_position()
	return Vector3.ZERO

func is_target_reachable() -> bool:
	if navigation_agent != null:
		return navigation_agent.is_target_reachable()
	return false

func is_target_reached() -> bool:
	if navigation_agent != null:
		return navigation_agent.is_target_reached()
	return false

func distance_to_target() -> float:
	if navigation_agent != null:
		return navigation_agent.distance_to_target()
	return 0.0

func get_final_position() -> Vector3:
	if navigation_agent != null:
		return navigation_agent.get_final_position()
	return Vector3.ZERO

func get_current_navigation_path() -> PackedVector3Array:
	if navigation_agent != null:
		return navigation_agent.get_current_navigation_path()
	return PackedVector3Array()
