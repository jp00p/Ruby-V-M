extends KinematicBody2D

var direction = -1
var gravity = 9999
var walk_speed = 100

func _ready():
	var speed_boost = randf()
	var frames = Globals.extras[randi()%Globals.extras.size()]
	$AnimatedSprite.frames = frames
	var extras = get_tree().get_nodes_in_group("extras")
	for e in extras:
		if e.name != self.name and e.get_node("AnimatedSprite").frames == frames:
			queue_free()
			break
			
	$AnimatedSprite.speed_scale += speed_boost
	if direction == -1:
		$AnimatedSprite.flip_h = false
	else:
		$AnimatedSprite.flip_h = true
	walk_speed += speed_boost * 20
	
func _process(delta):
	var velocity = Vector2.ZERO
	velocity.y += gravity * delta
	velocity.x = direction * walk_speed
	velocity = move_and_slide(velocity)
