extends Joystick

func Throw() -> void:
	Global.player.Throw()
	differenceVector = Vector2.ZERO

func _on_pressed():
	Global.player.UseDummy()
