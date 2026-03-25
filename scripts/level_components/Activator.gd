# Activator class - Anything that can "activate" something, like a button
@abstract
class_name Activator
extends StaticBody3D

# Variables
var activated: bool

@export var interactable: bool

func _ready() -> void:
    activated = false


func isActivated():
    return activated


func toggleActivate():
    if not activated:
        _activate()
    else:
        _deactivate()


@abstract
func _activate()


@abstract
func _deactivate()
