extends SpotLight3D

@onready var enemy: EnemyBase = get_parent()

func _ready() -> void:
    spot_angle = enemy.vision_angle * 0.5
    spot_range = enemy.vision_range
    shadow_enabled = false
    light_energy = 1.5

func _process(_delta: float) -> void:
    var state := enemy.fsm.current_state
    if state is ChaseState:
        light_color = Color.RED
        light_energy = 2.5
    elif state is AlertState:
        light_color = Color.YELLOW
        light_energy = 2.0
    elif state is SearchState:
        light_color = Color.ORANGE
        light_energy = 1.5
    else:
        light_color = Color.WHITE
        light_energy = 1.0
