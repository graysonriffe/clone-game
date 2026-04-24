# NoBranchZone class - No branching while you are within the zone. Class used for identification
class_name NoBranchZone
extends Area3D

const CLASS_NAME = "NoBranchZone"

@onready var particles: GPUParticles3D = $GPUParticles3D

func _ready() -> void:
    var volume: float = scale.x * scale.y * scale.z
    particles.amount = (volume * 0.5) as int
