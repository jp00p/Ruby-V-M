extends Area2D

var person_emerged = false

func _on_Door_body_entered(body):
	if body is Player and person_emerged != true:
		person_emerged = true
		$Closed.hide()
		$Open.show()
		$AnimationPlayer.play("person_emerge")


func _on_Door_body_exited(body):
	if body is Player and person_emerged:
		$AnimationPlayer.play_backwards("person_emerge")
		yield($AnimationPlayer, "animation_finished")
		$Closed.show()
		$Open.hide()
		person_emerged = false
