extends Joystick

func Attack() -> void:
	Global.player.Attack(differenceVector)
	differenceVector = Vector2.ZERO
