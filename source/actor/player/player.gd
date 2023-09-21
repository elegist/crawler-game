extends CharacterBody3D

@onready var camera_3d: Camera3D = $Camera3D
@onready var visuals: Node3D = $Visuals
@onready var animation_tree: AnimationTree = $Visuals/knight/AnimationTree

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _process(delta: float) -> void:
	handle_movement_animations()

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_movement()
	if Input.is_action_just_pressed("attack"):
		handle_attack_animations()

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

func handle_movement_animations() -> void:
	var playback = animation_tree.get("parameters/MovementStateMachine/playback") as AnimationNodeStateMachinePlayback
	if Input.is_action_just_pressed("dodge"):
		playback.travel("DodgeForward")
	else:
		if velocity == Vector3.ZERO:
			playback.travel("Idle")
		else:
			playback.travel("Running")

func handle_attack_animations() -> void:
	var playback = animation_tree.get("parameters/AttackStateMachine/playback") as AnimationNodeStateMachinePlayback
	playback.travel("Attack_1")
