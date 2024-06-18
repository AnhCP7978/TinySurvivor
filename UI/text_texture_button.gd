extends TextureButton

@onready var label : Label = $Label

func SetText(text : String) -> void:
	label.text = text

func _on_button_down() -> void:
	label.position.y += 4

func _on_button_up() -> void:
	label.position.y -= 4
