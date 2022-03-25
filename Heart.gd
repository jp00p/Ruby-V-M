extends RigidBody2D

class_name Heart


func _ready():
	$Sprite.texture = Globals.heart_textures[randi()%Globals.heart_textures.size()]
	var ix = Globals.randombit() * 65
	var iy = -100
	apply_central_impulse(Vector2(ix,iy))
	
func collect():
	Globals.set_deferred("hearts", Globals.hearts + 1)
	self.call_deferred("queue_free")

func _on_Area2D_area_entered(area):
	collect()

func _on_AnimationPlayer_animation_finished(anim_name):
	self.call_deferred("queue_free")

func _on_FadeTimer_timeout():
	$AnimationPlayer.play("fade")
