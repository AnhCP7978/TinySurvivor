extends Player
class_name Archer

@onready var body : AnimatedSprite2D = $Body
@onready var hand : AnimatedSprite2D = $Body/Hands
@onready var dummy : Sprite2D = $Sprite2D
@onready var readyTimer : Timer = $ReadyTimer # MUST be > 0.5 secs (for the animation to finished)

signal CanUseDummyVariableChanged(canUseDummy : bool)
signal ShootArrow(pos : Vector2, direction : Vector2, arrowType : int)
signal ThrowDummy(targetPos : Vector2)

var arrowType : int = Global.Arrow.normal
var aimTime : float:
	set(value):
		aimTime = max(0.1, value)
		readyTimer.wait_time = aimTime

var use_dummy : bool = false
var dummyPos : Vector2 = Vector2.ZERO
var canUseDummy : bool = true :
	set(value):
		canUseDummy = value
		CanUseDummyVariableChanged.emit(value)

var pickupRadius : float:
	set(value):
		pickupRadius = value
		$PickupRadius/CollisionShape2D.shape.radius = value

func _ready() -> void:
	type = Global.PlayerType.archer
	aimTime = 0.75
	pickupRadius = 150
	body.flip_h = false
	hand.flip_h = false
	hand.rotation = 0
	dummy.hide()

func _process(_delta) -> void:
	if aim_angle != Global.PLAYER_DEFAULT_AIM_ANGLE: # Player is aiming
		velocity = normalized_move_direction * speed / 4

		if 2 * abs(aim_angle) > PI: # 90 < Aim_angle < 270 degrees
			hand.flip_h = true
			hand.rotation = aim_angle - PI
		else:
			hand.flip_h = false
			hand.rotation = aim_angle
	else:
		velocity = normalized_move_direction * speed
		hand.play("Idle")

	if normalized_move_direction != Vector2.ZERO: # Player is moving
		body.play("Run")

		if normalized_move_direction.x < 0:
			body.flip_h = true
		else:
			body.flip_h = false

		move_and_slide()
	else:
		body.play("Idle")

	if dummyPos != Vector2.ZERO:
		var true_pos : Vector2 = position + dummyPos
		dummy.global_position = Vector2(clampf(true_pos.x, Global.LEFT_BORDER, Global.RIGHT_BORDER), clampf(true_pos.y, Global.TOP_BORDER, Global.BOTTOM_BORDER))

func Aim() -> void: # Be called by both shootButton and dummy_button (in Root)
	if not use_dummy: # Using arrow
		readyTimer.start()
		hand.speed_scale = Global.PLAYER_BASE_AIM_TIME / aimTime
		hand.play("Aim")
	elif canUseDummy: # Using throwable
		dummy.show()

func Ready() -> void:
	can_attack = true

func Attack(direction : Vector2) -> void: # Shoot arrow
	hand.speed_scale = 1
	if can_attack: # ReadyTimer has finished/or player is using a throwable
		can_attack = false
		ShootArrow.emit(global_position, direction, arrowType)
		hand.play("Shoot")

		await hand.animation_finished
	else:
		readyTimer.stop()

	aim_angle = Global.PLAYER_DEFAULT_AIM_ANGLE
	hand.rotation = 0

func Throw() -> void: # Used for throwing dummy only!
	dummy.hide()
	ThrowDummy.emit(dummy.global_position + Vector2(0, 50))
	dummyPos = Vector2.ZERO
	canUseDummy = false
	create_tween().tween_callback(DummyCDFinishes).set_delay(Global.playerDummyCD)
	use_dummy = false

func Hit(damageReceived : int = 1) -> void:
	if is_vulnerable:
		is_vulnerable = false
		hp -= damageReceived
		if hp > 0:
			var tween : Tween = create_tween()
			tween.tween_property(body, "modulate", Color(1, 0, 0), INVULNERABLE_TIME / 2)
			tween.tween_property(body, "modulate", Color(1, 1, 1), INVULNERABLE_TIME / 2)

			await tween.finished
			is_vulnerable = true

func _on_pickup_radius_area_entered(item : Item) -> void:
	item.Picker = self

func _on_pickup_radius_area_exited(item : Item) -> void:
	item.Picker = null

func GainItem(item : int) -> void:
	if item == Global.Item.g:
		player_exp += exp_gain_factor
	elif item == Global.Item.m:
		hp += 10

func ChangeArrowType(newArrowType : int) -> void:
	arrowType = newArrowType
	use_dummy = false

func UseDummy() -> void:
	use_dummy = true

func DummyCDFinishes() -> void:
	canUseDummy = true
