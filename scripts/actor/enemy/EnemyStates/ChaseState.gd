class_name ChaseState
extends State

var line_of_sight_timer: float = 0.0
var path_timer: float = 0.0

func enter() -> void:
    line_of_sight_timer = 0.0
    path_timer = 0.0

func exit() -> void:
    path_timer = 0.0

func physics_update(_delta: float) -> void:
    enemy.rotate_toward_target(enemy.last_known_position, _delta)

    line_of_sight_timer += _delta
    if line_of_sight_timer >= enemy.vision_interval:
        line_of_sight_timer = 0.0
        if not enemy.player_in_line_of_sight():
            fsm.change_state(fsm.search_state)
            return

    path_timer += _delta
    if path_timer >= enemy.path_update_interval:
        path_timer = 0.0
        enemy.nav_agent.target_position = enemy.last_known_position
        #print("Nav finished: ", enemy.nav_agent.is_navigation_finished())
        #print("Next pos: ", enemy.nav_agent.get_next_path_position())
        #print("Guard pos: ", enemy.global_position)

    if not enemy.nav_agent.is_navigation_finished():
        var next_pos := enemy.nav_agent.get_next_path_position()
        enemy.velocity = (next_pos - enemy.global_position).normalized() * enemy.chase_speed
    else:
        enemy.velocity = Vector3.ZERO
