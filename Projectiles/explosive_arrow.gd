extends Arrow

var hasExploded : bool = false

func _ready() -> void:
	var explodeArea : Area2D = $ExplodeArea
	explodeArea.position = Vector2(30, 3)
	explodeArea.explodeDMG = Global.explosiveArrowDamage
	explodeArea.explodeDelayTime = 0
	explodeArea.explodeRadius = Global.explosiveArrowExplodeRadius

	$Sprite2D.show()

func HitEnemy(_body : PhysicsBody2D) -> void:
	if hasExploded: # If remove this, the arrow will explode multiple times
		return

	hasExploded = true
	$Timer.stop()
	speed = 0 # The arrow will stop moving
	$Sprite2D.hide()
	
	$ExplodeArea.Activate()

func QueueFree() -> void:
	queue_free()
