# CloneData - A resource that contains everything a clone needs to replicate player actions
class_name CloneData
extends Resource

# The initial position of the clone when time starts
@export var initialPosition: Vector3

# A vector of Input.getVector Vector2s from player inputs on physics frames
@export var recordedMovement: Array[Vector2]

# A vector of pitch and yaw pairs of the player's camera view on physics frames
@export var recordedLookVectors: Array[Vector2]

# A vector of the state of the jump button on physics frames
@export var recordedJumpButton: Array[bool]

func getRecordSize() -> int:
    return recordedMovement.size()


func getNextTimeIndex(prevIndex: int) -> int:
    return 0 if prevIndex + 1 >= getRecordSize() else prevIndex + 1


func clear():
    initialPosition = Vector3.ZERO
    recordedMovement.clear()
    recordedLookVectors.clear()
    recordedJumpButton.clear()


func pushBackMovementVector(vec: Vector2):
    recordedMovement.push_back(vec)


func getMovementVector(index: int) -> Vector2:
    return recordedMovement[index]


func pushBackLookVector(vec: Vector2):
    recordedLookVectors.push_back(vec)


func getLookVector(index: int) -> Vector2:
    return recordedLookVectors[index]


func pushBackJump(jump: bool):
    recordedJumpButton.push_back(jump)


func getJumpButton(index: int) -> bool:
    return recordedJumpButton[index]
