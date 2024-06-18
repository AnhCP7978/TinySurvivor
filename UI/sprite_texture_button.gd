extends TextureButton

var normalSprite : Texture2D = preload("res://assets/Regular_02.png")
var pressedSprite : Texture2D = preload("res://assets/Pressed_02.png")

func ShowPressedTexture() -> void:
	$TextureRect.texture = pressedSprite

func ShowNormalTexture() -> void:
	$TextureRect.texture = normalSprite
