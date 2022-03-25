extends Node2D

var current_task = null
var bouncing = false setget set_bounce

func _ready():
	hide()
	Globals.connect("task_changed", self, "task_changed")
	Globals.connect("stage_complete", self, "stage_over")

func task_changed(task):
	current_task = task
	if current_task:
		show()
	else:
		hide()

func _process(delta):
	if current_task != null:
		var task_pos = Globals.get_task_pos()
		var player_pos = Globals.get_player_pos()
		var distance  = task_pos.x - player_pos.x
		
		var rot = 0
		if abs(distance) < 160:
			rot = deg2rad(90)
			if not bouncing:
				self.bouncing = true
		elif task_pos.x > player_pos.x:
			rot = deg2rad(0)
			self.bouncing = false
		else:
			rot = deg2rad(180)
			self.bouncing = false
			
			
		rotation = lerp(rotation, rot, 0.15)

func set_bounce(val):
	bouncing = val
	if bouncing:
		$AnimationPlayer.play("bounce")
	else:
		$AnimationPlayer.play("RESET")

func stage_over():
	queue_free()
