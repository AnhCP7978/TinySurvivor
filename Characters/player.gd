extends CharacterBody2D
class_name Player

signal ExpChanged(current_exp : float)
signal ExpNeededForNextLevelChanged(expNeededForNextLv : int)
signal LvChanged(lv : int)
signal HpChanged(current_hp : int)
signal CanAttackVariableChanged(can_attack : bool)

var type : int

const INVULNERABLE_TIME : float = 0.5
var is_vulnerable : bool = true

var aim_angle : float = Global.PLAYER_DEFAULT_AIM_ANGLE

var normalized_move_direction : Vector2 = Vector2.ZERO
var speed : int = 200

var hp : int = 100 :
	set(value):
		hp = min(Global.playerMaxHP, value)
		HpChanged.emit(hp)

var can_attack : bool = false :
	set(value):
		can_attack = value
		CanAttackVariableChanged.emit(value)

var exp_gain_factor : float = 1
var player_exp : float = 0 :
	set(value):
		player_exp = value
		ExpChanged.emit(value)
		CheckLvUp()

var exp_needed_for_next_lv : int = 5 :
	set(value):
		exp_needed_for_next_lv = value
		ExpNeededForNextLevelChanged.emit(value)

var lv : int = 1 :
	set(value):
		lv = value
		LvChanged.emit(value)

func CheckLvUp() -> void:
	# Up to Lv. 2 needs 5 exp, Lv. 3 needs 15, Lv. 4 needs 30, ...
	if player_exp >= exp_needed_for_next_lv: # Lv. UP!
		lv += 1
		player_exp -= exp_needed_for_next_lv
		exp_needed_for_next_lv += 5

func Attack(_direction : Vector2) -> void:
	pass
