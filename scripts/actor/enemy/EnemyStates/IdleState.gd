class_name IdleState
extends State

func enter() -> void:
    enemy.velocity = Vector3.ZERO

func on_hearing_entered(_body: Node3D) -> void:
    if _body.is_in_group("Player"):
        fsm.change_state(fsm.alert_state)
