extends TouchScreenButton
class_name Joystick

var touchPosition : Vector2
var differenceVector : Vector2 = Vector2.ZERO
var vectorMultiplier : int = 1 # If -1, differenceVector will point from player's finger to the origin of joystick
var fingerIndex : int = -1

func _process(_delta) -> void:
	if is_pressed():
		differenceVector = (touchPosition - global_position) * vectorMultiplier
	else:
		fingerIndex = -1

func _input(event) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed() and fingerIndex == -1:
			fingerIndex = event.index

	elif event is InputEventScreenDrag and event.index == fingerIndex:
		touchPosition = event.position
