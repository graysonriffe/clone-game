# Lever class - A switch that can activate and deactivate something
class_name Lever
extends Activator

const CLASS_NAME = "Lever"

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

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    super()
    noSetter = true
    animationTime = 0.0
    noSetter = false


func _physics_process(_delta: float) -> void:
    if not animationPlayer.active:
        return
    
    if animationPlayer.is_playing():
        noSetter = true
        animationTime = animationPlayer.current_animation_position
        noSetter = false


func _activate():
    activated = true
    animationPlayer.speed_scale = 1.0
    animationPlayer.play("flip")


func _deactivate():
    activated = false
    animationPlayer.speed_scale = -1.0
    animationPlayer.play("flip", -1.0, 1.0, true)
