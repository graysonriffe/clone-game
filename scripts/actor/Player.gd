# Player script - An Actor that handles FPS movement and basic gameplay
class_name Player
extends Actor

# Constants
const MOUSE_SENSITIVITY = 0.3

# FPS controller variables
var headBobbingVector: Vector2
var headBobbingTheta: float

# Recording variables
var recordingCurrently: bool
@export var recordingCloneData: CloneData

@onready var eyes: Node3D = $Head/Eyes
@onready var remotePlaceholder: MeshInstance3D = $Head/Eyes/Camera3D/ViewModel/RemotePlaceholder

@onready var statusLabel: Label = get_tree().root.find_child("StatusLabel", true, false)

func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    
    recordingCurrently = false
    #recordingCloneData = CloneData.new()
    
    statusLabel.text = "Status: Time Stopped"


func _physics_process(delta: float) -> void:
    # Record input_dir if recording is enabled
    if recordingCurrently:
        recordingCloneData.pushBackMovementVector(_getInputDirection())
        var currentLookVector = Vector2(head.global_rotation.x, global_rotation.y)
        recordingCloneData.pushBackLookVector(currentLookVector)
        recordingCloneData.pushBackJump(Input.is_action_pressed("jump"))

    # Handle jump.
    if Input.is_action_just_pressed("jump") and is_on_floor():
        jump()
    
    # Do headbobbing when walking, and reset when not
    if velocity.length() > 0.1:
        headBobbingTheta += 14.0 * delta
        headBobbingVector = Vector2(sin(headBobbingTheta / 2) + 0.5, sin(headBobbingTheta))
        eyes.position.x = lerp(eyes.position.x, headBobbingVector.x * 0.1, 10.0 * delta)
        eyes.position.y = lerp(eyes.position.y, headBobbingVector.y * 0.05, 10.0 * delta)
        remotePlaceholder.position.x = lerp(remotePlaceholder.position.x, headBobbingVector.x * 0.01, 10.0 * delta)
        remotePlaceholder.position.y = lerp(remotePlaceholder.position.y, headBobbingVector.y * 0.005, 10.0 * delta)
    else:
        eyes.position.x = lerp(eyes.position.x, 0.0, 10.0 * delta)
        eyes.position.y = lerp(eyes.position.y, 0.0, 10.0 * delta)
        remotePlaceholder.position.x = lerp(remotePlaceholder.position.x, 0.0, 10.0 * delta)
        remotePlaceholder.position.y = lerp(remotePlaceholder.position.y, 0.0, 10.0 * delta)
        headBobbingTheta = 0.0
    
    super(delta)


# Handle all other inputs
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_released("pause"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    
    # Click -> capture mouse
    if event is InputEventMouseButton:
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    
    # When mouse is captured, mouse movement -> FPS head movement
    if event is InputEventMouseMotion:
        if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
            rotate_y(-deg_to_rad(event.relative.x * MOUSE_SENSITIVITY))
            head.rotate_x(-deg_to_rad(event.relative.y * MOUSE_SENSITIVITY))
            head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
    
    if event.is_action_released("record_clone"):
        if recordingCurrently == false:
            recordingCloneData.clear()
            recordingCloneData.initialPosition = position
        else:
            ResourceSaver.save(recordingCloneData)
        
        recordingCurrently = not recordingCurrently
        
        statusLabel.text = "Status: Recording" if recordingCurrently else "Status: Time Stopped"


func _getInputDirection() -> Vector2:
    return Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
