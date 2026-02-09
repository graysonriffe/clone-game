# CloneGame class - Main game manager. Handles level changing, level time, and clones
class_name CloneGame
extends Node

# Constants
const NUM_LEVELS: int = 1
const LEVEL_PATH: String = "res://scenes/levels/"

# Level variables
var currentLevel: int

# onready variables
@onready var player: Player = $Player
@onready var levelContainer: Node = $Level

func _ready() -> void:
    # Load main menu level
    _changeLevel(1)
    
    # Show main menu UI


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey:
        if event.keycode == KEY_P and not event.pressed:
            _changeLevel(2)


# Unloads current level and loads new level
func _changeLevel(newLevelNumber: int):
    var levelScene: PackedScene = load(LEVEL_PATH + "level_" + str(newLevelNumber) + ".tscn")
    
    # Unload current level
    for child in levelContainer.get_children():
        child.queue_free()
        await child.tree_exited
    
    # Instantiate new level scene and add it to the level container node
    var levelSceneInstance: Level = levelScene.instantiate()
    levelContainer.add_child(levelSceneInstance)
    
    # Teleport player to PlayerStart marker
    # Probably move this later to another function
    var playerStart: Node3D = levelSceneInstance.find_child("PlayerStart")
    player.teleport(playerStart)
