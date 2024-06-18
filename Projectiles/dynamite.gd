extends Node2D

var atk : int = Global.goblinBaseDamage
var targetPos : Vector2 = Vector2.ZERO

func _ready():
	var animatedSprite : AnimatedSprite2D = $AnimatedSprite2D
	var explodeArea : Area2D = $ExplodeArea

	explodeArea.position = targetPos - position # THIS IS IMPLEMENTED TO ENSURE THE global_position OF explodeArea IS CORRECT
	explodeArea.explodeDMG = atk
	explodeArea.explodeDelayTime = Global.dynamiteTravelTime
	explodeArea.explodeRadius = Global.dynamiteExplodeRadius
	explodeArea.Activate()

	var tween : Tween = create_tween().set_parallel()
	tween.tween_property(animatedSprite, "position", targetPos - position, Global.dynamiteTravelTime)
	tween.tween_property(animatedSprite, "rotation", TAU, Global.dynamiteTravelTime)

	await tween.finished
	animatedSprite.hide()

	await explodeArea.QueueFree
	queue_free()
