extends BaseGoblin

@onready var animatedSprite : AnimatedSprite2D = $AnimatedSprite2D

signal ThrowTNT(origin : Vector2, targetPos : Vector2, tntDamage : int)

func _process(_delta) -> void:
	if target == null:
		target = Global.player

	if hp > 0:
		var distanceVector : Vector2 = target.position - position
		if distanceVector.x < 0:
			animatedSprite.flip_h = true
		else:
			animatedSprite.flip_h = false

		if isNotAttacking:
			if distanceVector.length() <= Global.TNT_GOBLIN_ATTACK_RANGE:
				Attack()
			else:
				velocity = distanceVector.normalized() * speed

				animatedSprite.play("Run")
				move_and_slide()

func Attack() -> void:
	if target != null:
		isNotAttacking = false
		animatedSprite.play("Throw")
		create_tween().tween_callback(Throw).set_delay(0.2)

		await animatedSprite.animation_finished
		isNotAttacking = true

func Throw() -> void:
	if target != null:
		var distanceNoise : float = randf_range(0, float(Global.dynamiteExplodeRadius) / 2)
		ThrowTNT.emit(position, target.position + (Vector2.RIGHT * distanceNoise).rotated(randf_range(0, TAU)), atk)

func Hit(damageReceive : int = 1) -> void:
	super.Hit(damageReceive)
	if hp > 0:
		var tween : Tween = create_tween()
		tween.tween_property(animatedSprite, "self_modulate", Color(1, 0, 0), .2)
		tween.tween_property(animatedSprite, "self_modulate", Color(1, 1, 1), .2)
	else:
		$CollisionShape2D.set_deferred("disabled", true)
		animatedSprite.play("Dead")

		await animatedSprite.animation_finished
		Global.playerKills += 1
		Global.enemyCount -= 1
		DropItem.emit(position, Global.Item.g)
		if randf() < Global.goblinBaseFoodDropChance:
			DropItem.emit(position, Global.Item.m)
		queue_free()
