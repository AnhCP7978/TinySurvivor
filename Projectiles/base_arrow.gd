extends Area2D
class_name Arrow # Any class inherit from this should have arrow head to the right by default

var speed : int = 2000
var atk : int

func _ready():
	# Disappear after 1 sec
	create_tween().tween_callback(queue_free).set_delay(1)

func _process(delta) -> void:
	position += Vector2.RIGHT.rotated(rotation) * speed * delta
