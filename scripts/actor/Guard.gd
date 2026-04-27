class_name Guard
extends EnemyBase

func _ready() -> void:
    chase_speed = 4.5
    vision_interval = 0.15
    search_duration = 2.0
    vision_angle = 360.0
    vision_range = 45.0
    vision_mask = 0b11
    super._ready()
