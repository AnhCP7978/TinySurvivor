extends Control

func _ready() -> void:
	$Label.text = "YOUR KILL COUNTS : " + str(Global.playerKills)
	$TextureButton.SetText("MAIN MENU")
	$TextureButton2.SetText("REPLAY")

func BackToMainMenu() -> void:
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")

func Replay() -> void:
	Global.ResetVariables()
	get_tree().change_scene_to_file("res://root.tscn")
