# Player script - handles FPS movement and basic gameplay
class_name Player
extends CharacterBody3D

# Constants
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.3

# FPS controller variables
var movementDirectionSmoothed: Vector3
var headBobbingVector: Vector2
var headBobbingTheta: float

# Time variables
var timePassing: bool
var timeIndex: int

# Recording variables
var recordingCurrently: bool
var recordingCloneData: CloneData

@onready var head: Node3D = $Head
@onready var eyes: Node3D = $Head/Eyes

@onready var statusLabel: Label = get_tree().root.find_child("StatusLabel", true, false)

# All we need to do here for now is capture the mouse
func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    
    timePassing = false
    timeIndex = 0
    recordingCurrently = false
    recordingCloneData = CloneData.new()
    
    statusLabel.text = "Status: Time Stopped"


func _physics_process(delta: float) -> void:
    # Get the input direction and handle the movement/deceleration.
    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
    
    # Record input_dir if recording is enabled
    if recordingCurrently:
        recordingCloneData.pushBackMovementVector(input_dir)
        var currentLookVector = Vector2(head.global_rotation.x, global_rotation.y)
        recordingCloneData.pushBackLookVector(currentLookVector)
        recordingCloneData.pushBackJump(Input.is_action_pressed("jump"))
    
    var direction: Vector3
    
    if timePassing:
        if timeIndex == 0:
            position = Vector3.ZERO
            rotation = Vector3.ZERO
        
        # Set the movement
        var nextMovement: Vector2 = recordingCloneData.getMovementVector(timeIndex)
        timeIndex = recordingCloneData.getNextTimeIndex(timeIndex)
        direction = (transform.basis * Vector3(nextMovement.x, 0, nextMovement.y)).normalized()
        
        # Set the look vector
        var nextLookVector: Vector2 = recordingCloneData.getLookVector(timeIndex)
        global_rotation.y = nextLookVector.y
        head.global_rotation.x = nextLookVector.x
    else:
        direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    # Add the gravity.
    if not is_on_floor():
        velocity += get_gravity() * delta

    # Handle jump.
    if (Input.is_action_just_pressed("jump") and is_on_floor() and not timePassing)\
        or (timePassing and recordingCloneData.getJumpButton(timeIndex)):
        velocity.y = JUMP_VELOCITY
    
    # Smooth the movement, and differently depending on if the player is mid-air
    if is_on_floor():
        movementDirectionSmoothed = lerp(movementDirectionSmoothed, direction, 10.0 * delta)
    elif input_dir != Vector2.ZERO:
        movementDirectionSmoothed = lerp(movementDirectionSmoothed, direction, 3.0 * delta)
    
    # Do headbobbing when walking, and reset when not
    if direction != Vector3.ZERO:
        headBobbingTheta += 14.0 * delta
        headBobbingVector = Vector2(sin(headBobbingTheta / 2) + 0.5, sin(headBobbingTheta))
        eyes.position.x = lerp(eyes.position.x, headBobbingVector.x * 0.1, 10.0 * delta)
        eyes.position.y = lerp(eyes.position.y, headBobbingVector.y * 0.05, 10.0 * delta)
    else:
        eyes.position.x = lerp(eyes.position.x, 0.0, 10.0 * delta)
        eyes.position.y = lerp(eyes.position.y, 0.0, 10.0 * delta)
        headBobbingTheta = 0.0
    
    # Apply the movement
    velocity.x = movementDirectionSmoothed.x * SPEED
    velocity.z = movementDirectionSmoothed.z * SPEED

    move_and_slide()


# Handle all other inputs
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_released("pause"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    
    # Click -> capture mouse
    if event is InputEventMouseButton:
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    
    # When mouse is captured, mouse movement -> FPS head movement
    if event is InputEventMouseMotion and not timePassing:
        if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
            rotate_y(-deg_to_rad(event.relative.x * MOUSE_SENSITIVITY))
            head.rotate_x(-deg_to_rad(event.relative.y * MOUSE_SENSITIVITY))
            head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
    
    if event.is_action_released("record_clone") and not timePassing:
        if recordingCurrently == false:
            recordingCloneData.clear()
        
        recordingCurrently = not recordingCurrently
        
        statusLabel.text = "Status: Recording" if recordingCurrently else "Status: Time Stopped"
    
    if event.is_action_released("time_play_and_stop") and not recordingCurrently:
        if timePassing == false:
            timeIndex = 0
        
        timePassing = not timePassing
        
        statusLabel.text = "Status: Time Passing" if timePassing else "Status: Time Stopped"
