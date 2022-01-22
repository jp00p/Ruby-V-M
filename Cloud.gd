extends Node2D

onready var cloud_graphics = [
	preload("res://assets/GL-24.png"),
	preload("res://assets/GL-25.png"),
	preload("res://assets/GL-26.png"),
	preload("res://assets/GL-27.png")
]

var speed = 0

func _ready():
	randomize()
	self.modulate.a = rand_range(24,255)
	print(self.modulate)
	self.scale.x = rand_range(1,1.2)
	self.scale.y = rand_range(1,1.3)
	var cloud = cloud_graphics[randi() % cloud_graphics.size()]
	$Sprite.texture = cloud
	speed = rand_range(50, 100)
	if rand_range(1,100) > 50:
		speed = -speed

func _process(delta):
	global_position.x += speed * delta

func _on_DisappearTimer_timeout():
	$AnimationPlayer.play_backwards("appear")
	yield($AnimationPlayer,"animation_finished")
	queue_free()
