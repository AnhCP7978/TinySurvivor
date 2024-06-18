extends Control

func _ready() -> void:
	Global.ResetVariables()

	$TutorialButton.SetText("TUTORIAL")
	$QuitButton.SetText("QUIT")

func Play() -> void:
	get_tree().change_scene_to_file("res://root.tscn")

func PlayTutorial() -> void:
	Global.is_tutorial_screen = true
	Play()

func QuitGame() -> void:
	get_tree().quit()
