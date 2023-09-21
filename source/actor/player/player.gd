class_name Player
extends CharacterBody3D

@onready var camera_3d: Camera3D = $Camera3D
@onready var visuals: Node3D = $Visuals
@onready var animation_tree: AnimationTree = $Visuals/AnimationTree

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _process(delta: float) -> void:
	apply_animations(delta)

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_movement()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

func handle_movement() -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (camera_3d.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		var rotation_lerp_value := 0.25
		visuals.rotation.y = lerp_angle(visuals.rotation.y, atan2(direction.x, direction.z), rotation_lerp_value)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()

func apply_animations(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		animation_tree.set("parameters/Attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		animation_tree.set("parameters/AttackTransition/current_index", 0)
	else:
		if Input.is_action_just_pressed("dodge"):
			animation_tree.set("parameters/Dodge/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		else:
			if velocity == Vector3.ZERO:
				animation_tree.set("parameters/Movement/blend_amount", 0)
			else:
				animation_tree.set("parameters/Movement/blend_amount", 1)
