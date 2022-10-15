extends StaticBody2D

var score = 0
var new_position = Vector2.ZERO
var dying = false
export var time_appear = 0.5
export var time_fall = 0.8
export var time_rotate = 1.0
export var time_a = 0.8
export var time_s = 1.2
export var time_v = 1.5
var powerup_prob = 0.1

export var sway_amplitude = 3.0
var sway_initial_position = Vector2.ZERO
var sway_randomizer = Vector2.ZERO
var color_rotate = 0
var color_index = 0
var color_distance = 0
var color_rotate_amount = 10
var color_rotate_index = 0.01
var color_position = Vector2.ZERO

var sway_index = 0
var sway_period = 0.1
var color_completed = true

var colors = [
	Color8(240,101,149)
	,Color8(255,222,235)
	,Color8(252,194,215)
	,Color8(247,131,172)
	,Color8(240,101,149)
	,Color8(132,94,247)
	,Color8(190,75,219)
	,Color8(134,142,150)
]

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
	$ColorRect.color = colors[color_index]
	sway_initial_position = $ColorRect.rect_position
	sway_randomizer = Vector2(randf()*6-3.0, randf()*6-3.0)

func _physics_process(_delta):
	if dying and not $Spark.emitting:
		queue_free()
	color_distance = Global.color_position.distance_to(global_position) / 100
	if Global.color_rotate >= 0:
		$ColorRect.color = colors[(int(floor(color_distance + Global.color_rotate))) % len(colors)]
		color_completed = false
	elif not color_completed:
			$ColorRect.color = colors[color_index]
			color_completed = true
	var pos_x = (sin(Global.sway_index)*(sway_amplitude + sway_randomizer.x))
	var pos_y = (cos(Global.sway_index)*(sway_amplitude + sway_randomizer.y))
	$ColorRect.rect_position = Vector2(sway_initial_position.x + pos_x, sway_initial_position.y + pos_y)

func hit(_ball):
	var brick_sound = get_node_or_null("/root/Game/Brick_Sound")
	if brick_sound != null:
		brick_sound.play()
	Global.color_rotate = Global.color_rotate_amount
	Global.color_position = _ball.global_position
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
	$Tween.interpolate_property(self, "position", position, Vector2(position.x, 1000), time_fall, Tween.TRANS_EXPO, Tween.EASE_IN)
	$Tween.interpolate_property(self, "rotation", rotation, -PI + randf()*2*PI, time_rotate, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($ColorRect, "color:a", $ColorRect.color.a, 0, time_a, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($ColorRect, "color:s", $ColorRect.color.s, 0, time_s, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($ColorRect, "color:v", $ColorRect.color.v, 0, time_v, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	if randf() < powerup_prob:
		var Powerup_Container = get_node_or_null("/root/Game/Powerup_Container")
		if Powerup_Container != null:
			var Powerup = load("res://Powerups/Powerup.tscn")
			var powerup = Powerup.instance()
			powerup.position = position
			Powerup_Container.call_deferred("add_child", powerup)
