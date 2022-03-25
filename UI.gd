extends CanvasLayer

signal out_of_time
signal end_game

enum STATE { STAGE_START, STAGE_END, GAME_OVER }

onready var progress = $Main/M/V/H/V2/Progress/MarginContainer/TaskProgress
var dismissed = false
var state = STATE.STAGE_START

func _ready():
	$GameTimer.start()
	progress.max_value = $GameTimer.wait_time
	progress.value = $GameTimer.wait_time
	$Main/M/V/H/Score/C/V/HeartsValue.text = str(Globals.hearts)
	Globals.game_paused = true
	Globals.stage = 1
	Globals.connect("hearts_changed", self, "hearts_changed")
	Globals.connect("stage_changed", self, "update_stage")
	Globals.connect("stage_complete", self, "finish_stage")
	Globals.connect("game_over", self, "end_game")
	Globals.connect("task_changed", self, "task_changed")
	Globals.connect("task_popup_started", self, "task_popup_start")
	Globals.connect("task_popup_ended", self, "task_popup_end")
	$Main/M/V/MessagePopup/TextureRect/M/QuestText.text = Globals.intro_texts[Globals.stage]
	#Globals.connect("task_changed", self, "task_changed")
	$Main/StageComplete.hide()
	$Main/TheMessage.hide()
	$Main/GameOver.hide()
	$Main/M/V/MessagePopup.show()
	$Main/M/V/StageName.show()

func _process(delta):
	progress.value = $GameTimer.time_left	
	# countdown game timer
	# clock.text = "%d:%02d" % [floor($GameTimer.time_left / 60), int($GameTimer.time_left) % 60]

func _input(event):
	if state == STATE.STAGE_START and not dismissed and Input.is_action_just_pressed("interact"):
		# press enter to fade stage start popup
		dismissed = true
		$Main/M/V/MessagePopup.hide()
		$Main/M/V/StageName.hide()
		Globals.game_paused = false
		Globals.give_task()
	if state == STATE.STAGE_END and Input.is_action_just_pressed("interact"):
		# press enter to finish ending stage
		$Main/TheMessage.hide()
		Globals.stage += 1
	if state == STATE.GAME_OVER and Input.is_action_just_pressed("interact"):
		$Main/Ringing.hide()
		emit_signal("end_game")
		

func hearts_changed(val):
	$Main/M/V/H/Score/C/V/HeartsValue.text = str(val)

func update_stage(stage):
	print("Stage updated")
	$Main/TheMessage/TextureRect/MarginContainer/Label.text = Globals.outro_texts[Globals.stage]
	$Main/M/V/MessagePopup/TextureRect/ClientName.text = Globals.client_names[Globals.stage]
	if stage == 2:
		$Main/M/V/MessagePopup/TextureRect.texture = load("res://assets/business owners bubble-71.png")
	$Main/M/V/StageName.text = "Stage %s" % Globals.stage
	$Main/M/V/MessagePopup/TextureRect/M/QuestText.text = Globals.intro_texts[Globals.stage]
	$Main/M/V/StageName.show()
	$Main/M/V/MessagePopup.show()
	dismissed = false
	state = STATE.STAGE_START

func _on_TaskProgress_value_changed(value):
	if value <= 0.0:
		end_game()

func finish_stage():
	yield(get_tree().create_timer(0.5), "timeout")
	$Main/StageComplete.show()
	yield(get_tree().create_timer(3), "timeout")
	$Main/StageComplete.hide()
	$Main/TheMessage.show()
	state = STATE.STAGE_END
	Globals.game_paused = true
	
func end_game():
	$GameTimer.stop()
	#$AnimationPlayer.play("fade_screen")
	Globals.game_paused = true
	$ColorRect.show()
	$Main/M.hide()
	$Main/GameOver.show()
	$Main/Ringing.hide()
	yield(get_tree().create_timer(0.5), "timeout")
	$Main/GameOver/VBoxContainer/Clicktorestart.modulate.a = 1
	state = STATE.GAME_OVER

func task_changed(val):
	if val == null:
		$Main/Ringing.hide()
	else:
		$GameTimer.start()
		$Main/Ringing.show()

func task_popup_start():
	$Main/Ringing.hide()

func task_popup_end():
	$Main/Ringing.show()
	$GameTimer.start()
