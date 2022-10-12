extends StaticBody2D

var score = 0
var new_position = Vector2.ZERO
var dying = false

var powerup_prob = 0.1

func _ready():
	position.x = new_position.x
	position.y = -100
	$Tween.interpolate_property(self, "position", position, new_position, 0.5 + randf()* 2, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
	$Tween.start()
	if score >= 100:
		$ColorRect.color = Color8(255,240,246)
	elif score >= 90:
		$ColorRect.color = Color8(255,222,235)
	elif score >= 80:
		$ColorRect.color = Color8(252,194,215)
	elif score >= 70:
		$ColorRect.color = Color8(250,162,193)
	elif score >= 60:
		$ColorRect.color = Color8(247,131,172)
	elif score >= 50:
		$ColorRect.color = Color8(240,101,149)
	elif score >= 40:
		$ColorRect.color = Color8(230,73,128)
	else:
		$ColorRect.color = Color8(214,51,108)

func _physics_process(_delta):
	if dying and not $Spark.emitting:
		queue_free()

func hit(_ball):
	var brick_sound = get_node_or_null("/root/Game/Brick_Sound")
	if brick_sound != null:
		brick_sound.play()
	die()

func die():
	dying = true
	collision_layer = 0
	$ColorRect.hide()
	Global.update_score(score)
	if not Global.feverish:
		Global.update_fever(score)
	get_parent().check_level()
	$Spark.emitting = true
	if randf() < powerup_prob:
		var Powerup_Container = get_node_or_null("/root/Game/Powerup_Container")
		if Powerup_Container != null:
			var Powerup = load("res://Powerups/Powerup.tscn")
			var powerup = Powerup.instance()
			powerup.position = position
			Powerup_Container.call_deferred("add_child", powerup)
