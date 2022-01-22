extends KinematicBody2D
class_name Player

var speed = 800
var walk_speed = 800
var jump_speed = -1800
var gravity = 4000
var dash_speed = speed * 2

var velocity = Vector2.ZERO
var is_dashing = false
var can_dash = true

func _ready():
	pass

func get_input():
	velocity.x = 0
	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.play("running")
	if Input.is_action_pressed("ui_left"):
		velocity.x -= speed
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.play("running")
	if velocity.x == 0:
		$AnimatedSprite.play("idle")

func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	if Input.is_action_just_pressed("ui_accept") and can_dash and velocity.x != 0:
		dash()
	velocity = move_and_slide(velocity, Vector2.UP)
	if is_dashing:
		var frametexture = $AnimatedSprite.get_sprite_frames().get_frame($AnimatedSprite.animation,$AnimatedSprite.get_frame())
		Globals.emit_signal("create_dash_ghost", frametexture, global_position, $AnimatedSprite.flip_h)
		
# start dash
func dash():
	can_dash = false
	is_dashing = true
	speed = dash_speed
	$DashTimer.start()

# end dash
func _on_DashTimer_timeout():
	is_dashing = false
	speed = walk_speed
	$DashPeriodTimer.start()

# let player dash again
func _on_DashPeriodTimer_timeout():
	can_dash = true
