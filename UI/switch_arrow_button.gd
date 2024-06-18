extends TouchScreenButton

@onready var sprites : Array[Sprite2D] = [$Sprite2D/PenetratingArrow, $Sprite2D/ExplosiveArrow]

func _ready():
	sprites[0].show()
	sprites[1].hide()

func SwitchState():
	if sprites[0].visible == true:
		sprites[0].hide()
		sprites[1].show()
		Global.player.ChangeArrowType(Global.Arrow.explosive)
	else:
		sprites[0].show()
		sprites[1].hide()
		Global.player.ChangeArrowType(Global.Arrow.normal)
