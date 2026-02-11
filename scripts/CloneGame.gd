# CloneGame class - Main game manager. Handles level changing, level time, and clones
class_name CloneGame
extends Node

# Constants
const NUM_LEVELS: int = 1
const LEVEL_PATH: String = "res://scenes/levels/"

const CLONE_SCENE: PackedScene = preload("res://scenes/actor/clone.tscn")

# Level variables
var currentLevel: int

# Time variables
var timePassing: bool

# onready variables
@onready var player: Player = $Player
@onready var levelContainer: Node = $Level
@onready var cloneContainer: Node = $Clones

@onready var tempStatusLabel: Label = find_child("StatusLabel", true, false)

func _ready() -> void:
    # Load main menu level
    _changeLevel(1)
    
    # Show main menu UI
    
    tempStatusLabel.text = "Status: Time Stopped"


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey:
        if event.keycode == KEY_P and not event.pressed:
            _changeLevel(2)
    
    if event.is_action_released("time_play_and_stop"):
        _attemptToggleTime()
    
    if event.is_action_released("record_clone"):
        _attemptToggleRecord()
        
    if event.is_action_released("delete_all_clones"):
        _attemptDeleteAllClones()


# Unloads current level and loads new level
func _changeLevel(newLevelNumber: int):
    # TODO: Move clone deletion somewhere else later
    _deleteAllClones()
    
    var levelScene: PackedScene = load(LEVEL_PATH + "level_" + str(newLevelNumber) + ".tscn")
    
    # Unload current level
    for child in levelContainer.get_children():
        child.queue_free()
        await child.tree_exited
    
    # Instantiate new level scene and add it to the level container node
    var levelSceneInstance: Level = levelScene.instantiate()
    levelContainer.add_child(levelSceneInstance)
    
    # Teleport player to PlayerStart marker
    # TODO: Probably move this later to another function
    var playerStart: Node3D = levelSceneInstance.find_child("PlayerStart")
    player.teleport(playerStart.global_transform)


func _attemptToggleTime():
    if not player.recordingCurrently:
        _toggleTime()


func _toggleTime():
    timePassing = not timePassing

    if timePassing == false:
        # Reset dynamic objects (maybe just reload the level? Seems hacky)
        _resetClones()
    
    tempStatusLabel.text = "Status: Time Passing" if timePassing else "Status: Time Stopped"


func _resetClones():
    var clones = cloneContainer.get_children()
    for clone in clones:
        clone.reset()


func _attemptToggleRecord():
    if ((not timePassing and player.is_on_floor()) or player.recordingCurrently):
        _toggleRecording()


func _toggleRecording():
    player.recordingCurrently = not player.recordingCurrently
    
    if player.recordingCurrently == true:
        player.recordingCloneData.clear()
        player.recordingCloneData.initialPosition = player.position
        _toggleTime()
    else:
        _toggleTime()
        var newClone: Clone = CLONE_SCENE.instantiate()
        newClone.cloneData = player.recordingCloneData
        player.recordingCloneData = CloneData.new()
        cloneContainer.add_child(newClone)
    
    tempStatusLabel.text = "Status: Recording" if player.recordingCurrently else "Status: Time Stopped"


func _attemptDeleteAllClones():
    if not timePassing:
        _deleteAllClones()


func _deleteAllClones():
    var clones = cloneContainer.get_children()
    for clone in clones:
        clone.queue_free()
