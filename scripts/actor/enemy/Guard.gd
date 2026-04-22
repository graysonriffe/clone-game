class_name Guard
extends EnemyBase

func _ready() -> void:
    chase_speed = 4.0
    vision_interval = 0.15
    search_duration = 2.0
    vision_angle = 90.0
    vision_range = 15.0
    vision_mask = 0b11
    super._ready()
