extends Joystick

@onready var subJoystick : Sprite2D = $Sprite2D/Sub

func _ready():
	touchPosition = subJoystick.global_position

func _process(_delta) -> void:
	if is_pressed():
		differenceVector = (touchPosition - global_position) * vectorMultiplier
		subJoystick.position = differenceVector.limit_length(shape.radius)
	else:
		fingerIndex = -1

func _on_released():
	subJoystick.position = Vector2.ZERO
	touchPosition = subJoystick.global_position
