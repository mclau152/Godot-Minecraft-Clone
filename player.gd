extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002
const FOV_CHANGE_SPEED = 5  # Degrees to change per scroll
const MIN_FOV = 20.0        # Minimum FOV allowed
const MAX_FOV = 120.0       # Maximum FOV allowed

@onready var camera_mount = $CameraMount
@onready var camera = $CameraMount/Camera3D
@onready var ray_cast = $CameraMount/RayCast3D
var camera_rotation_x = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		# Rotate the camera mount left/right
		camera_mount.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		
		# Handle pitch rotation
		camera_rotation_x -= event.relative.y * MOUSE_SENSITIVITY
		camera_rotation_x = clamp(camera_rotation_x, -PI/4, PI/4)
		
		# Reset camera's rotation and apply the new rotation around the X axis
		camera_mount.rotation.x = 0
		camera_mount.rotate_object_local(Vector3.RIGHT, camera_rotation_x)
	
	# Handle digging with left mouse button
	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if ray_cast.is_colliding():
				var collider = ray_cast.get_collider()
				if collider is StaticBody3D:
					collider.queue_free()
		# Handle FOV with mouse wheel
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.fov = clamp(camera.fov - FOV_CHANGE_SPEED, MIN_FOV, MAX_FOV)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.fov = clamp(camera.fov + FOV_CHANGE_SPEED, MIN_FOV, MAX_FOV)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := Vector3.ZERO
	direction = camera_mount.transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	direction = direction.normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
