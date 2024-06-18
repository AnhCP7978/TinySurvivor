extends Node

@onready var joystick : Joystick = $CanvasLayer/VJoystick
@onready var attack_button : TouchScreenButton = $CanvasLayer/AttackButton
@onready var dummy_button : Joystick = $CanvasLayer/DummyButton
@onready var pauseScreen : ColorRect = $CanvasLayer/PauseScreen
@onready var expBar : ProgressBar = $CanvasLayer/ExpBar

var goblin : PackedScene = preload("res://Characters/goblin.tscn")
var tntGoblin : PackedScene = preload("res://Characters/tnt_goblin.tscn")
var arrow : PackedScene = preload("res://Projectiles/arrow.tscn")
var explosiveArrow : PackedScene = preload("res://Projectiles/explosive_arrow.tscn")
var dynamite : PackedScene = preload("res://Projectiles/dynamite.tscn")
var dummy : PackedScene = preload("res://Projectiles/dummy.tscn")
var g : PackedScene = preload("res://Items/g.tscn")
var m : PackedScene = preload("res://Items/m.tscn")

var spawn_time : float = 10 : # Time between each enemy wave
	set(value):
		spawn_time = max(5, value)

func ElementWiseMultiply(vec1 : Vector2, vec2 : Vector2) -> Vector2:
	return Vector2(vec1.x * vec2.x, vec1.y * vec2.y)

func _ready() -> void:
	Global.enemy_target_list.append($Player)
	Global.player = $Player
	
	#if Global.player.type == Global.PlayerType.archer:
	attack_button.vectorMultiplier = -1
	Global.player.CanUseDummyVariableChanged.connect(_on_player_can_use_dummy_variable_changed)
	Global.player.ShootArrow.connect(ShootArrow)
	Global.player.ThrowDummy.connect(ThrowDummy)
	#else:
		#dummy_button.queue_free()

	attack_button.modulate = Color("ff000080") # Half transparent pure red
	expBar.max_value = Global.player.exp_needed_for_next_lv

	pauseScreen.hide()

	if Global.is_tutorial_screen:
		attack_button.hide()
		$CanvasLayer/SwitchArrowButton.hide()
		dummy_button.hide()
		ShowTutorial()
	else:
		$AudioStreamPlayer.playing = true
		$Tutorial.queue_free()
		SpawnEnemy(0)

func _process(_delta) -> void:
	#var direction : Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
#
	#if direction != Vector2.ZERO:
		#Global.player.normalized_move_direction = direction.normalized()
	#else:
		#Global.player.normalized_move_direction = Vector2.ZERO

	if joystick.is_pressed():
		Global.player.normalized_move_direction = joystick.differenceVector.normalized()
	else:
		Global.player.normalized_move_direction = Vector2.ZERO

	if attack_button.is_pressed():
		Global.player.aim_angle = attack_button.differenceVector.angle()

	if dummy_button.is_pressed(): # and Global.player.type == Global.PlayerType.archer
		Global.player.dummyPos = 2 * dummy_button.differenceVector.limit_length(121.5)

func SpawnEnemy(waitTimeReduceAmount : float = 0.5) -> void:
	if Global.enemyCount < 100:
		# E(# enemies spawn on 1 wave) = 10
		var goblinSpawnAmount : int = randi_range(7, 11)
		var tntGoblinSpawnAmount : int = randi_range(0, 2)

		var distanceVector : Vector2 = Vector2(Global.ENEMY_SPAWN_DISTANCE, 0)
		for i in range(goblinSpawnAmount):
			var newGoblin = goblin.instantiate()
			newGoblin.DropItem.connect(SpawnItem)
			newGoblin.position = Global.enemy_target_list[-1].position + distanceVector.rotated(randf_range(0, TAU))

			$Enemy.add_child(newGoblin)

		for i in range(tntGoblinSpawnAmount):
			var newGoblin = tntGoblin.instantiate()
			newGoblin.DropItem.connect(SpawnItem)
			newGoblin.ThrowTNT.connect(ThrowTNT)
			newGoblin.position = Global.enemy_target_list[-1].position + distanceVector.rotated(randf_range(0, TAU))

			$Enemy.add_child(newGoblin)

		spawn_time -= waitTimeReduceAmount
		if spawn_time == 5:
			spawn_time = 10
			Global.goblinBaseHP += 2
			Global.goblinBaseDamage += 1
			Global.goblinBaseSpeed += 25
			Global.dynamiteTravelTime *= 0.9
			Global.dynamiteExplodeRadius += 5
	else:
		for enemy in $Enemy.get_children():
			enemy.speed += 10

	create_tween().tween_callback(SpawnEnemy).set_delay(spawn_time)

func SpawnItem(pos : Vector2, item : int) -> void:
	var newItem : Area2D
	if item == Global.Item.g:
		newItem = g.instantiate()
	elif item == Global.Item.m:
		newItem = m.instantiate()

	newItem.position = pos
	$Item.add_child(newItem)

func ThrowTNT(originPos : Vector2, targetPos : Vector2, tntDamage : int) -> void:
	var newDynamite : Node2D = dynamite.instantiate()
	newDynamite.position = originPos
	newDynamite.atk = tntDamage
	newDynamite.targetPos = targetPos

	$Projectiles.add_child(newDynamite)

func _on_player_hp_changed(playerHP : int) -> void:
	if playerHP > 0:
		$CanvasLayer/HPBar.value = playerHP
	else:
		get_tree().call_deferred("change_scene_to_file", "res://UI/end_game_screen.tscn")

func _on_player_can_attack_variable_changed(canAttack : bool) -> void:
	if canAttack:
		attack_button.modulate = Color("00ff0080") # Half transparent pure green
	else:
		attack_button.modulate = Color("ff000080")

func _on_player_exp_changed(current_exp : float) -> void:
	expBar.value = current_exp

func _on_player_exp_needed_for_next_level_changed(expNeededForNextLv : int) -> void:
	expBar.max_value = expNeededForNextLv

func _on_player_lv_changed(lv : int) -> void:
	$CanvasLayer/LvLabel.text = "Lv. " + str(lv)
	pauseScreen.ShowLvUPScreen()

func _on_pause_button_pressed() -> void:
	pauseScreen.ShowPauseScreen()

# ONLY CONNECT IF PLAYER IS ARCHER
func _on_player_can_use_dummy_variable_changed(canUseDummy : bool) -> void:
	dummy_button.visible = canUseDummy

func ShootArrow(pos : Vector2, direction : Vector2, arrowType : int) -> void:
	var newArrow : Arrow
	if arrowType == Global.Arrow.normal:
		newArrow = arrow.instantiate()
	else:
		newArrow = explosiveArrow.instantiate()

	newArrow.position = pos
	newArrow.rotation = direction.angle()

	$Projectiles.add_child(newArrow)

func ThrowDummy(targetPos : Vector2) -> void:
	var newDummy : Area2D = dummy.instantiate()
	newDummy.position = targetPos
	$Projectiles.add_child(newDummy)

# ONLY USE FOR TUTORIAL SCREEN
func ShowTutorial() -> void:
	$Enemy.queue_free()
	$Item.queue_free()
	$AudioStreamPlayer.queue_free()
	Global.player.ThrowDummy.connect(TutorialFinished) # This function will only be called if you play in tutorial mode

func Tutorial1Finished(_body : Player) -> void:
	$Tutorial/CanvasLayer/Movement.queue_free()
	$Tutorial/MovementObjective.queue_free()
	$Tutorial/CanvasLayer/Shoot.show()
	$Tutorial/ShootingObjective.show()
	attack_button.show()

func Tutorial2Finished(area : Area2D) -> void:
	if "HitEnemy" in area: # Other area like player's pickup and explosive area don't have "HitEnemy"
		area.HitEnemy($EndOfMap)
		$CanvasLayer/SwitchArrowButton.show()
		$Tutorial/CanvasLayer/Shoot.queue_free()
		$Tutorial/CanvasLayer/Shoot2.show()
		$Tutorial/ShootingObjective.area_entered.disconnect(Tutorial2Finished)
		$Tutorial/ShootingObjective.area_entered.connect(Tutorial3Finished)
		$Tutorial/ShootingObjective2.show()
		$Tutorial/ShootingObjective2.area_entered.connect(Tutorial3Finished)
		$Tutorial/ShootingObjective3.show()
		$Tutorial/ShootingObjective3.area_entered.connect(Tutorial3Finished)

func Tutorial3Finished(area : Area2D) -> void:
	if "HitEnemy" in area:
		area.HitEnemy($EndOfMap)
	elif "Explode" in area:
		dummy_button.show()
		$Tutorial/ShootingObjective.queue_free()
		$Tutorial/ShootingObjective2.queue_free()
		$Tutorial/ShootingObjective3.queue_free()
		$Tutorial/CanvasLayer/Shoot2.queue_free()
		$Tutorial/CanvasLayer/Throw.show()

func TutorialFinished(_targetPos : Vector2) -> void:
	$Tutorial/CanvasLayer/Throw.queue_free()
	$Tutorial/CanvasLayer/Finish.show()
