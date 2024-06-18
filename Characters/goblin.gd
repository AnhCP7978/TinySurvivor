extends BaseGoblin

@onready var animatedSprite : AnimatedSprite2D = $AnimatedSprite2D

func _process(_delta) -> void:
	if hp > 0:
		var distanceVector : Vector2 = target.position - position
		if distanceVector.x < 0:
			animatedSprite.flip_h = true
		else:
			animatedSprite.flip_h = false

		if isNotAttacking:
			if distanceVector.length() <= Global.GOBLIN_ATTACK_RANGE:
				Attack()
			else:
				velocity = distanceVector.normalized() * speed

				animatedSprite.play("Run")
				move_and_slide()

func Attack() -> void:
	isNotAttacking = false

	if target != null:
		var angleDividedByPI : float = (target.position - position).angle() / PI
		if angleDividedByPI >= 0.25 and angleDividedByPI <= 0.75:
			animatedSprite.play("AttackDownward")
		elif angleDividedByPI >= -0.75 and angleDividedByPI <= -0.25:
			animatedSprite.play("AttackUpward")
		else:
			animatedSprite.play("Attack")

		create_tween().tween_callback(Dash).set_delay(0.2)

		await animatedSprite.animation_finished
		if hp > 0 and target != null:
			var distance : float = (target.position - position).length()

			if distance <= Global.GOBLIN_DAMAGE_RANGE:
				target.Hit(atk)
				if distance <= Global.GOBLIN_ATTACK_RANGE:
					Attack()
				else:
					isNotAttacking = true
			else:
				isNotAttacking = true

func Dash() -> void:
	if hp > 0 and target != null:
		var distanceVector : Vector2 = target.position - position

		if distanceVector.length() > Global.GOBLIN_ATTACK_RANGE:
			position += distanceVector.normalized() * Global.GOBLIN_DASH_LENGTH

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
