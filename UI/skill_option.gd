extends Button

signal ButtonUp(button : Button)

var skillType : int

func SetSkillType(skill : int) -> void:
	skillType = skill
	match skill:
		Global.LvUpAbility.attack:
			text = "\nIncrease attack power\n"

		Global.LvUpAbility.hitLimit:
			text = "\nIncrease attack radius/hit limit\n"

		Global.LvUpAbility.attackSpeed:
			text = "\nIncrease attack speed by 10%\n"

		Global.LvUpAbility.speed:
			text = "\nIncrease speed by 25\n"

		Global.LvUpAbility.expGain:
			text = "\nIncrease exp gained by 0.4\n"

		Global.LvUpAbility.pickupRadius:
			text = "\nIncrease pickup radius; Item moves toward you faster\n"

		Global.LvUpAbility.foodDropChance:
			text = "\nIncrease food drop chance by 2%\n"

		Global.LvUpAbility.reduceDummyCD:
			text = "\nReduce Dummy Cool Down by 5%\n"

func _on_button_up() -> void:
	ButtonUp.emit(self)
