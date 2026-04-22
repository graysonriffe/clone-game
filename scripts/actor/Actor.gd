# Actor class - Abstract base class of Player and Clone
@abstract
class_name Actor
extends CharacterBody3D

const CLASS_NAME = "Actor"

enum ActorColor {
    White,
    Green,
    Yellow,
    Red
}

# Constants
const COLOR_COLLISION_LAYERS: Dictionary[ActorColor, int] = {
    ActorColor.Green:    5,
    ActorColor.Yellow:   6,
    ActorColor.Red:      7
}

const WALKING_SPEED = 6.0
const CROUCHING_SPEED = 3.0
const JUMP_VELOCITY = 7.0
const BOOST_VELOCITY = 11.5

# Variables
var movementDirectionSmoothed: Vector3

# Audio variables
var pause_tween: Tween
var music_bus_vol_base: float

# State variables
# Pauses and unpauses the actor
var paused: bool

# The active color of the Actor
var color: ActorColor:
    set(value):
        color = value
        
        var outlineColor: Color
        match color:
            ActorColor.White:
                outlineColor = Color.WHITE
            ActorColor.Green:
                outlineColor = Color.GREEN
            ActorColor.Yellow:
                outlineColor = Color.YELLOW
            ActorColor.Red:
                outlineColor = Color.RED
        
        bodyMesh.set_instance_shader_parameter("outline_color", outlineColor)
        headMesh.set_instance_shader_parameter("outline_color", outlineColor)
        
        set_collision_mask_value(COLOR_COLLISION_LAYERS[ActorColor.Green], false)
        set_collision_mask_value(COLOR_COLLISION_LAYERS[ActorColor.Yellow], false)
        set_collision_mask_value(COLOR_COLLISION_LAYERS[ActorColor.Red], false)
        
        if color != ActorColor.White:
            set_collision_mask_value(COLOR_COLLISION_LAYERS[color], true)

var isOnFloor: bool
var isOnFloorOverride: bool
var crouching: bool

var noSetter: bool

var animationTime: float:
    set(value):
        if noSetter:
            animationTime = value
            return
        
        animationPlayer.active = true
        animationPlayer.seek(value, true)
        animationPlayer.active = false
        animationTime = value

# onready variables
@onready var head: Node3D = $Head
@onready var crouchRayCast: RayCast3D = $CrouchRayCast
@onready var interactRayCast: RayCast3D = $Head/InteractRayCast
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var bodyMesh: MeshInstance3D = $BodyMesh
@onready var headMesh: MeshInstance3D = $Head/HeadMesh
@onready var crouchActorDetector: Area3D = $CrouchActorDectector
@onready var collisionDetector: Area3D = $CollisionDetector

func _ready() -> void:
    paused = true
    color = ActorColor.White
    isOnFloorOverride = false
    crouching = false
    
    noSetter = true
    animationTime = 0.0
    noSetter = false
    
    music_bus_vol_base = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))


func _physics_process(delta: float) -> void:
    if paused:
        return
    
    if animationPlayer.is_playing():
        noSetter = true
        animationTime = animationPlayer.current_animation_position
        noSetter = false
    
    # Add the gravity.
    if not is_on_floor() or isOnFloorOverride:
        velocity += get_gravity() * 1.5 * delta
    
    # Get direction vector from either the Player or Clone
    var inputDirection: Vector2 = getInputDirection()
    var direction: Vector3 = (transform.basis * Vector3(inputDirection.x, 0, inputDirection.y)).normalized()
    
    # Smooth the movement, and differently depending on if the actor is mid-air
    if is_on_floor() or isOnFloorOverride:
        movementDirectionSmoothed = lerp(movementDirectionSmoothed, direction, 10.0 * delta)
    elif inputDirection != Vector2.ZERO:
        movementDirectionSmoothed = lerp(movementDirectionSmoothed, direction, 3.0 * delta)
    
    # Apply the movement
    var speed: float = WALKING_SPEED if not crouching else CROUCHING_SPEED
    velocity.x = movementDirectionSmoothed.x * speed
    velocity.z = movementDirectionSmoothed.z * speed
    
    if not crouching and crouchRayCast.is_colliding() and \
    (crouchRayCast.get_collider() is CSGShape3D \
    or crouchRayCast.get_collider() is GridMap):
        _crouch()
    
    # Apply collision forces to physics objects
    for i in get_slide_collision_count():
        var collision = get_slide_collision(i)
        if collision.get_collider() is RigidBody3D and movementDirectionSmoothed.length() > 0.5:
            collision.get_collider().apply_central_impulse(-collision.get_normal())
    
    move_and_slide()
    
    isOnFloor = is_on_floor()
    isOnFloorOverride = false


func pause(shouldPause: bool = true):
    paused = shouldPause
    animationPlayer.active = not shouldPause
    
    var music_bus = AudioServer.get_bus_index("Music")

    var reverb = AudioServer.get_bus_effect(music_bus, 0) as AudioEffectReverb
    var lowpass_filter = AudioServer.get_bus_effect(music_bus, 1) as AudioEffectLowPassFilter

    # Kill any in-progress tween before starting a new one
    if pause_tween:
        pause_tween.kill()

    pause_tween = create_tween()
    # Perform tweens in parallel
    pause_tween.set_parallel(true)

    var current_volume := AudioServer.get_bus_volume_db(music_bus)

    if paused:
        pause_tween.tween_property(reverb, "wet", 1.0, 2.0)
        pause_tween.tween_property(reverb, "dry", 0.0, 2.0)
        pause_tween.tween_property(lowpass_filter, "cutoff_hz",  500.0, 2.0)
        pause_tween.tween_method(
            func(db): AudioServer.set_bus_volume_db(music_bus, db), current_volume, music_bus_vol_base - 8.0, 2.0
       )
    else:
        pause_tween.tween_property(reverb, "wet", 0.0, 2.0)
        pause_tween.tween_property(reverb, "dry", 1.0, 2.0)
        pause_tween.tween_property(lowpass_filter, "cutoff_hz",  20500.0, 2.0)
        pause_tween.tween_method(
            func(db): AudioServer.set_bus_volume_db(music_bus, db), current_volume, music_bus_vol_base, 2.0
        )



func getColor() -> ActorColor:
    return color


func getPauseState() -> bool:
    return paused


func boost():
    velocity.y = BOOST_VELOCITY


@abstract
func getInputDirection() -> Vector2


@abstract
func getLookVector() -> Vector2


func _jump():
    if is_on_floor() and not crouching:
        velocity.y = JUMP_VELOCITY


func _crouch():
    if is_on_floor():
        crouching = true
        animationPlayer.play("crouch")
        animationPlayer.queue("crouchHold")


func _uncrouch():
    var collidingWith: Node = crouchRayCast.get_collider()
    
    var detectedActor: Actor
    
    for body: Node in crouchActorDetector.get_overlapping_bodies():
        if body == self:
            continue
        
        if body is Actor:
            detectedActor = body
            break
    
    if not collidingWith or (collidingWith is Actor):
        crouching = false
        animationPlayer.play("uncrouch")
        
        if detectedActor: # Crouch boost
            detectedActor.boost()


func _interact():
    if interactRayCast.is_colliding():
        var collider: Node = interactRayCast.get_collider()
        if collider is Activator and collider.interactable:
            collider.toggleActivate()
