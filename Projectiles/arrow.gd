extends Arrow

var hitLimit : int = Global.arrowHitLimit
var hitCount : int = 0

func _ready():
	atk = Global.arrowDamage
	super._ready()

func HitEnemy(body : PhysicsBody2D) -> void:
	if "Hit" in body:
		hitCount += 1
		if hitCount <= hitLimit:
			body.Hit(atk)
			if hitCount == hitLimit:
				queue_free()
	else:
		queue_free()
