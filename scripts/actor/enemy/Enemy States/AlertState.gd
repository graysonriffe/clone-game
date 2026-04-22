class Alert extends State:
    var timer: float = 0.0

    func enter() -> void:
        timer = 0.0
        enemy.velocity = Vector3.ZERO

    func physics_update(_delta: float) -> void:
        timer += _delta
        if timer >= enemy.vision_interval:
            timer = 0.0
            if enemy.player_in_line_of_sight():
                fsm.change_state(fsm.chase_state)

    func on_hearing_entered(_body: Node3D) -> void:
        # Reset the scan timer so the guard re-checks immediately on new sounds.
        if _body.is_in_group("Player"):
            timer = 0.0
