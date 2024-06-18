extends CharacterBody2D
class_name BaseGoblin

signal DropItem(pos : Vector2, itemType : int)

var speed : int = Global.goblinBaseSpeed
var hp : int = Global.goblinBaseHP
var atk : int = Global.goblinBaseDamage
var isNotAttacking : bool = true
var target : CollisionObject2D = Global.enemy_target_list[-1]

func _ready() -> void:
	Global.enemyCount += 1

func Hit(damageReceive : int = 1) -> void:
	hp -= damageReceive
