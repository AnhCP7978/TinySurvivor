extends Area2D

@onready var sprite : Sprite2D = $Sprite2D
@onready var explodeArea : Area2D = $ExplodeArea

const INVULNERABLE_TIME : float = 0.5
var isVulnerable : bool = true
var hp : int = 25
var enemy_affected_list : Array[BaseGoblin] = []

func _ready() -> void:
	#create_tween().tween_property(sprite, "position:y", position.y, 0.2).from(position.y - 648)
	
	explodeArea.explodeDMG = Global.arrowDamage
	explodeArea.explodeDelayTime = 1
	explodeArea.explodeRadius = 2 * Global.explosiveArrowExplodeRadius

func Hit(damageReceived : int = 1) -> void:
	if isVulnerable:
		isVulnerable = false
		hp -= damageReceived
		if hp > 0:
			var tween : Tween = create_tween()
			tween.tween_property(sprite, "modulate", Color(1, 0, 0), INVULNERABLE_TIME / 2)
			tween.tween_property(sprite, "modulate", Color(1, 1, 1), INVULNERABLE_TIME / 2)

			await tween.finished
			isVulnerable = true
		else:
			Explode()

func Explode() -> void:
	$Timer.stop()
	$CollisionShape2D.disabled = true
	explodeArea.Activate()

	create_tween().tween_property(sprite, "visible", false, explodeArea.explodeDelayTime)

	await explodeArea.QueueFree
	for enemy in enemy_affected_list:
		if enemy != null:
			enemy.target = Global.enemy_target_list[-1]

	queue_free()

func _on_body_entered(body : BaseGoblin) -> void:
	enemy_affected_list.append(body)
	body.target = self

func _on_timer_timeout():
	Explode()
