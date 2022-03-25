extends KinematicBody2D

var base_speed = 50
var walk_speed = 50
var run_speed = 150
var direction = -1
var detected = false
var gravity = 9999

func _ready():
	if direction == -1:
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false
	walk_speed += rand_range(0,70)

func _on_DetectPlayer_body_entered(body):
	if body is Player:
		detected = true
		walk_speed += run_speed
		$AnimatedSprite.play("run")

func _on_Hurtbox_body_entered(body):
	if body is Player:
		if not body.is_dashing:
			body.lose_hearts(5)
		
		var e = Globals.explosion.instance()
		e.global_position = self.global_position
		get_parent().add_child(e)
		queue_free()

func _process(delta):
	var velocity = Vector2.ZERO
	velocity.y += gravity * delta
	velocity.x = direction * walk_speed
	velocity = move_and_slide(velocity)


func _on_DetectPlayer_body_exited(body):
	if body is Player:
		detected = false
		walk_speed = base_speed
		$AnimatedSprite.play("walk")
