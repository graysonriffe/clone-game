class Search extends State:
    var timer: float = 0.0

    func enter() -> void:
        timer = enemy.search_duration
        enemy.nav_agent.target_position = enemy.last_known_position

    func physics_update(_delta: float) -> void:
        timer -= _delta
        if timer <= 0.0:
            fsm.change_state(fsm.idle_state)
            return

        if not enemy.nav_agent.is_navigation_finished():
            var next_pos := enemy.nav_agent.get_next_path_position()
            enemy.velocity = (next_pos - enemy.global_position).normalized() * enemy.chase_speed * 0.5
        else:
            enemy.velocity = Vector3.ZERO

    func on_hearing_entered(_body: Node3D) -> void:
        # Hearing something during a search bumps back to Alert to re-confirm visually.
        if _body.is_in_group("Player"):
            fsm.change_state(fsm.alert_state)
