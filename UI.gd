extends CanvasLayer

onready var clock = $Control/MarginContainer/VBoxContainer/HBoxContainer/Clock/CenterContainer/Label
onready var progress = $Control/MarginContainer/VBoxContainer/HBoxContainer/Progress/MarginContainer/TaskProgress

func _ready():
	pass
	#$Control/MessagePopup.set_visible(true)

func _process(delta):
	# countdown game timer
	clock.text = "%d:%02d" % [floor($GameTimer.time_left / 60), int($GameTimer.time_left) % 60]


func _on_MessageTimer_timeout():
	$AnimationPlayer.play("fade_message")
	$GameTimer.start()
