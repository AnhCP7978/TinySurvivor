extends ColorRect

@onready var sprite : AnimatedSprite2D = $Player
@onready var skillOption : PackedScene = preload("res://UI/skill_option.tscn")
@onready var vBoxContainer : VBoxContainer = $VBoxContainer
@onready var rerollButton : Button = $RerollButton
@onready var confirmButton : Button = $ConfirmButton

var chosenButton : Button = null

func ShowPauseScreen() -> void:
	rerollButton.disabled = true
	confirmButton.disabled = false

	UpdateLabelInfo()

	get_tree().paused = true
	show()

func ShowLvUPScreen() -> void:
	rerollButton.disabled = false
	confirmButton.disabled = true

	UpdateLabelInfo()
	CreateRandomSkillOptions()

	get_tree().paused = true
	show()

func ClearVBoxContainer() -> void:
	for node in vBoxContainer.get_children():
		node.queue_free()

func UpdateLabelInfo(dmg : bool = false, atk_area : bool = false, atk_speed : bool = false,
					speed : bool = false, exp_gain : bool = false, pickup_power : bool = false,
					food_drop_chance : bool = false, dummy_cd : bool = false) -> void:

	var dmg_label : Label = $Stats/Dmg
	var atk_area_label : Label = $Stats/AtkArea
	var atk_speed_label : Label = $Stats/AtkSpeed
	var speed_label : Label = $Stats/Speed
	var exp_gain_label : Label = $Stats/ExpGained
	var pickup_power_label : Label = $Stats/PickupPower
	var food_drop_chance_label : Label = $Stats/FoodDropChance
	var dummy_cd_label : Label = $Stats/DummyCD

	for label in $Stats.get_children():
		label.self_modulate = Color(1, 1, 1)
	
	if dmg:
		dmg_label.self_modulate = Color(0, 1, 0)
		dmg_label.text = "- DMG Power: " + str(Global.explosiveArrowDamage + 1)
	else:
		dmg_label.text = "- DMG Power: " + str(Global.explosiveArrowDamage)
	
	if atk_area:
		atk_area_label.self_modulate = Color(0, 1, 0)
		atk_area_label.text = "- Attack Area: " + str(Global.arrowHitLimit + 1)
	else:
		atk_area_label.text = "- Attack Area: " + str(Global.arrowHitLimit)

	if atk_speed:
		atk_speed_label.self_modulate = Color(0, 1, 0)
		atk_speed_label.text = "- Attack Speed: " + str(1.1 * Global.PLAYER_BASE_AIM_TIME / Global.player.aimTime).pad_decimals(1)
	else:
		atk_speed_label.text = "- Attack Speed: " + str(Global.PLAYER_BASE_AIM_TIME / Global.player.aimTime).pad_decimals(1)

	if speed:
		speed_label.self_modulate = Color(0, 1, 0)
		speed_label.text = "- Speed: " + str(Global.player.speed + 25)
	else:
		speed_label.text = "- Speed: " + str(Global.player.speed)

	if exp_gain:
		exp_gain_label.self_modulate = Color(0, 1, 0)
		exp_gain_label.text = "- x%s Exp Gained" % str(Global.player.exp_gain_factor + .4).pad_decimals(1)
	else:
		exp_gain_label.text = "- x%s Exp Gained" % str(Global.player.exp_gain_factor).pad_decimals(1)

	if pickup_power:
		pickup_power_label.self_modulate = Color(0, 1, 0)
		pickup_power_label.text = "- Pickup Power: " + str(Global.player.pickupRadius + 30)
	else:
		pickup_power_label.text = "- Pickup Power: " + str(Global.player.pickupRadius)

	if food_drop_chance:
		food_drop_chance_label.self_modulate = Color(0, 1, 0)
		food_drop_chance_label.text = "- Food Drop Chance: " + str(Global.goblinBaseFoodDropChance * 100 + 2) + "%"
	else:
		food_drop_chance_label.text = "- Food Drop Chance: " + str(Global.goblinBaseFoodDropChance * 100) + "%"

	if dummy_cd:
		dummy_cd_label.self_modulate = Color(0, 1, 0)
		dummy_cd_label.text = "- Dummy CD: " + str(Global.playerDummyCD * .95).pad_decimals(1)
	else:
		dummy_cd_label.text = "- Dummy CD: " + str(Global.playerDummyCD).pad_decimals(1)

func CreateRandomSkillOptions() -> void:
	var randomList : Array = range(Global.LvUpAbility.size())
	randomList.shuffle()

	for i in randomList.slice(0, 3):
		var option : Button = skillOption.instantiate()
		option.SetSkillType(i)

		vBoxContainer.add_child(option)
		option.ButtonUp.connect(ChooseButton)

func ChooseButton(button : Button) -> void:
	if chosenButton != null:
		chosenButton.self_modulate.r = 1

	chosenButton = button
	match button.skillType:
		Global.LvUpAbility.attack:
			UpdateLabelInfo(true)

		Global.LvUpAbility.hitLimit:
			UpdateLabelInfo(false, true)

		Global.LvUpAbility.attackSpeed:
			UpdateLabelInfo(false, false, true)

		Global.LvUpAbility.speed:
			UpdateLabelInfo(false, false, false, true)
		
		Global.LvUpAbility.expGain:
			UpdateLabelInfo(false, false, false, false, true)

		Global.LvUpAbility.pickupRadius:
			UpdateLabelInfo(false, false, false, false, false, true)

		Global.LvUpAbility.foodDropChance:
			UpdateLabelInfo(false, false, false, false, false, false, true)

		Global.LvUpAbility.reduceDummyCD:
			UpdateLabelInfo(false, false, false, false, false, false, false, true)

	chosenButton.self_modulate.r = 0
	
	confirmButton.disabled = false

func _on_menu_button_button_up() -> void:
	$ConfirmScreen.show()

func _on_reroll_button_button_up() -> void:
	confirmButton.disabled = true
	chosenButton = null
	ClearVBoxContainer()
	CreateRandomSkillOptions()
	rerollButton.disabled = true

func _on_confirm_button_button_up() -> void:
	if chosenButton != null:
		ClearVBoxContainer()
		Global.ApplyPlayerLvUPAbility(chosenButton.skillType)
		chosenButton = null

	get_tree().paused = false
	hide()

# Used only for confirmation when go back to main menu
func _on_yes_button_up():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")

func _on_no_button_up():
	$ConfirmScreen.hide()
