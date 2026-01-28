# Player script - handles FPS movement basic gameplay
class_name Player
extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.3

var movementDirectionSmoothed: Vector3

@onready var head: MeshInstance3D = $Head

func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
    # Add the gravity.
    if not is_on_floor():
        velocity += get_gravity() * delta

    # Handle jump.
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # Get the input direction and handle the movement/deceleration.
    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    if is_on_floor():
        movementDirectionSmoothed = lerp(movementDirectionSmoothed, direction, 10.0 * delta)
    elif input_dir != Vector2.ZERO:
        movementDirectionSmoothed = lerp(movementDirectionSmoothed, direction, 3.0 * delta)
    
    if movementDirectionSmoothed:
        velocity.x = movementDirectionSmoothed.x * SPEED
        velocity.z = movementDirectionSmoothed.z * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)

    move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_released("pause"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    
    if event is InputEventMouseButton:
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    
    if event is InputEventMouseMotion:
        if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
            rotate_y(-deg_to_rad(event.relative.x * MOUSE_SENSITIVITY))
            head.rotate_x(-deg_to_rad(event.relative.y * MOUSE_SENSITIVITY))
            head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
