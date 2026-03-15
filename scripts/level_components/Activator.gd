# Activator class - Anything that can "activate" something, like a button
@abstract
class_name Activator
extends StaticBody3D

# Variables
var activated: bool

func _ready() -> void:
    activated = false
