extends Area2D

signal QueueFree

@onready var sprite : Sprite2D = $ExplodeSprite/Sprite
@onready var animatedSprite : AnimatedSprite2D = $ExplodeSprite
@onready var explodeShape : CollisionShape2D = $CollisionShape2D

var explodeDMG : int = 1
var explodeDelayTime : float = 1
var explodeRadius : float = 30 :
	set(value):
		explodeRadius = value
		explodeShape.shape.radius = value
		animatedSprite.scale = Vector2.ONE * value / Global.BASE_EXPLODE_AREA_RADIUS

func _ready() -> void:
	sprite.hide()
	animatedSprite.self_modulate.a = 0
	explodeShape.disabled = true

func Activate() -> void:
	sprite.show()
	var tween : Tween = create_tween()
	tween.tween_property($ExplodeSprite/Sprite/Sub, "scale", Vector2.ONE, explodeDelayTime).from(Vector2.ZERO)
	
	await tween.finished
	Explode()

func Explode() -> void:
	sprite.hide()
	animatedSprite.self_modulate.a = 1
	animatedSprite.play("Explode")
	var tween : Tween = create_tween()
	tween.tween_property(explodeShape, "disabled", true, 0.3).from(false)

	await animatedSprite.animation_finished
	QueueFree.emit()
	queue_free()

func _on_body_entered(body : CharacterBody2D) -> void:
	body.Hit(explodeDMG)
