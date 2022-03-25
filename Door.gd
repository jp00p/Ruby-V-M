extends Area2D

class_name Door

var person_emerged = false
export var task_id = "test"
export (Texture) var closed_graphic = preload("res://assets/doors/orange-door.png")
export (Texture) var open_graphic = preload("res://assets/doors/GL-55.png")
export (Texture) var person_graphic = preload("res://assets/business-people/GL-65.png")

func _ready():
	Globals.connect("task_changed", self, "task_updated")
	$Closed.hide()
	$Open.texture = open_graphic
	$Person.texture = person_graphic

func open():
	#$Closed.hide()
	$Phone.hide()
	$Open.show()
	$CPUParticles2D.emitting = false
	$AudioStreamPlayer.play()
	$AnimationPlayer.play("person_emerge")
	yield($AnimationPlayer, "animation_finished")
	Globals.start_task_questions()
	
func close():
	$AnimationPlayer.play_backwards("person_emerge")
	yield($AnimationPlayer, "animation_finished")
	#$Closed.show()
	$Open.hide()

func task_updated(current_task):
	print("Door received task")
	if current_task == task_id:
		$PhoneAnimator.play("phone_shake")
		$CPUParticles2D.emitting = true
		$Phone.show()
	else:
		$PhoneAnimator.stop()
		$CPUParticles2D.emitting = false
		$Phone.hide()
