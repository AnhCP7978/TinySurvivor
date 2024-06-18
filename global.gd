extends Node
# ALL DISTANCE ARE CALCULATED IN PIXELS

enum LvUpAbility {
	attack,
	hitLimit,
	attackSpeed,
	speed,
	expGain,
	pickupRadius,
	foodDropChance,
	reduceDummyCD
}

enum Item {
	g,
	m
}

enum Arrow {
	normal,
	explosive
}

enum PlayerType {
	archer
	#knight,
	#engineer
}

# Determine the border "EndOfMap" node in root
const RIGHT_BORDER : int = 1915
const BOTTOM_BORDER : int = 2100
const LEFT_BORDER : int = -1915
const TOP_BORDER : int = -2115

# Default value when player isn't aiming, could be any number x as long as abs(x) > PI
const PLAYER_DEFAULT_AIM_ANGLE : float = 4
const DUMMY : int = 142857
# How much time needed to shoot an arrow
const PLAYER_BASE_AIM_TIME : float = 0.75
# How far will goblin start its attack
const GOBLIN_ATTACK_RANGE : int = 80
const TNT_GOBLIN_ATTACK_RANGE : int = 320
# How far can goblin's attack actually hurt player
const GOBLIN_DAMAGE_RANGE : int = 110
# How far will goblin move forward when using its attack
const GOBLIN_DASH_LENGTH : int = 60

const BASE_EXPLODE_AREA_RADIUS : int = 30
# The distance between player and enemy right after they are spawned
const ENEMY_SPAWN_DISTANCE : int = 666

var is_tutorial_screen : bool = false
var enemy_target_list : Array = []

var player : Player = null
var playerKills : int = 0
var playerMaxHP : int = 100
var playerDummyCD : float = 30

var goblinBaseHP : int = 2
var goblinBaseDamage : int = 5
var goblinBaseSpeed : int = 100
var goblinBaseFoodDropChance : float = 0.05

var itemFollowSpeed : int = 120

var arrowDamage : int = 2
var arrowHitLimit : int = 1

var explosiveArrowDamage : int = 1
var explosiveArrowExplodeRadius : int = 30

var dynamiteTravelTime : float = 1.7
var dynamiteExplodeRadius : int = 45

var enemyCount : int = 0

func ResetVariables() -> void:
	is_tutorial_screen = false
	player = null
	playerKills = 0
	playerMaxHP = 100
	playerDummyCD = 30
	goblinBaseHP = 2
	goblinBaseDamage = 5
	goblinBaseSpeed = 100
	goblinBaseFoodDropChance = 0.05
	itemFollowSpeed = 120
	arrowDamage = 2
	arrowHitLimit = 1
	explosiveArrowDamage = 1
	explosiveArrowExplodeRadius = 30
	dynamiteTravelTime = 1.7
	dynamiteExplodeRadius = 45
	enemyCount = 0

func ApplyPlayerLvUPAbility(ability : int) -> void:
	match ability:
		LvUpAbility.attack:
			arrowDamage += 2
			explosiveArrowDamage += 1

		LvUpAbility.hitLimit:
			explosiveArrowExplodeRadius += 7
			arrowHitLimit += 1

		LvUpAbility.attackSpeed:
			player.aimTime /= 1.1 # Increase current attack speed by 10%

		LvUpAbility.speed:
			player.speed += 25 # Increase speed by 12.5% (both when moving and aiming) of the default value

		LvUpAbility.expGain:
			player.exp_gain_factor += 0.4 # Increase Exp gained by 40% of the default value

		LvUpAbility.pickupRadius:
			player.pickupRadius += 30
			itemFollowSpeed += 24

		LvUpAbility.foodDropChance:
			goblinBaseFoodDropChance += 0.02

		LvUpAbility.reduceDummyCD:
			playerDummyCD *= .95
