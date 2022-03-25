extends KinematicBody2D
class_name Player

var speed = 800
var walk_speed = 800
var jump_speed = -1800
var gravity = 4000
var dash_speed = speed * 2
var flash = 0

var velocity = Vector2.ZERO
var is_dashing = false
var can_dash = true
var is_sad = false

var stopped = false setget set_stopped

var interaction = null
var can_interact = false setget set_interact

signal spawn_heart(where)

func _ready():
	$InteractHint.set_visible(false)
	pass
	
func _input(event):
	if Input.is_action_just_pressed("interact"):
		if can_interact and interaction:
			do_interaction()

func get_input():
	velocity.x = 0
	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
		$AnimatedSprite.flip_h = true
		if is_sad:
			$AnimatedSprite.play("sad")
		else:
			$AnimatedSprite.play("running")
	if Input.is_action_pressed("ui_left"):
		velocity.x -= speed
		$AnimatedSprite.flip_h = false
		if is_sad:
			$AnimatedSprite.play("sad")
		else:
			$AnimatedSprite.play("running")
	if velocity.x == 0:
		if is_sad:
			$AnimatedSprite.play("sad")
		else:
			$AnimatedSprite.play("idle")

func _physics_process(delta):
	flash = max(flash-1, 0)
	if flash > 0 and flash % 2:
		$AnimatedSprite.material.set_shader_param("solid_color", Color.white)
	else:
		$AnimatedSprite.material.set_shader_param("solid_color", Color(0,0,0,0))
		is_sad = false
	if not stopped:
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

func _on_Area2D_area_entered(area):
	if area is Door and Globals.current_task == area.task_id:
		self.can_interact = true
		interaction = area
		
func _on_Area2D_area_exited(area):
	if area is Door:
		self.can_interact = false
		interaction = null

func set_interact(val):
	can_interact = val
	$InteractHint.set_visible(val)

func set_stopped(val):
	stopped = val
	#self.can_interact = !val
	if val == true:
		$AnimatedSprite.play("idle")

func do_interaction():
	Globals.game_paused = true
	interaction.open()
	self.can_interact = false
	interaction = null

func lose_hearts(val):
	if not stopped:
		flash = 30
		$Camera2D.isShake = true
		$Camera2D.elapsedtime = 0
		if Globals.hearts > 0:
			Globals.hearts -= val
			for i in range(val):
				var pos = self.global_position + Vector2(Globals.randombit()*rand_range(25,75), rand_range(-75,-25))
				emit_signal("spawn_heart", pos)
