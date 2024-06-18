extends Area2D
class_name Item

var itemType : int = Global.Item.g
var speed : int = Global.itemFollowSpeed
var Picker : Player = null

func _process(delta) -> void:
	if Picker != null:
		var distanceVector : Vector2 = Picker.position - position
		
		if distanceVector.length() < 20:
			Picker.GainItem(itemType)
			queue_free()
		else:
			position += distanceVector.normalized() * speed * delta
