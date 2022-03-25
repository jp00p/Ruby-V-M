extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "scroll":
		$AnimationPlayer.play("scroll_back")
	else:
		$AnimationPlayer.play("scroll")


func _on_Start_pressed():
	$CenterContainer/VBoxContainer/Start.release_focus()
	SceneChanger.goto_scene("res://Level.tscn", self)
