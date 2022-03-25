extends CanvasLayer

var task = null
var correct_answer = ""
var success = false
var dismissed = false
var complete = false

func _ready():
	$CenterContainer/Results.hide()
	$CenterContainer/TaskPrompt.show()
	task = Globals.tasks[Globals.stage][Globals.current_task]
	var task_choices = []
	for c in task["choices"]:
		task_choices.append(c)
	correct_answer = task["choices"][0]
	task_choices.shuffle()
	
	$CenterContainer/TaskPrompt/MarginContainer/VBoxContainer/Choices/Button/Label.text = task_choices[0]
	$CenterContainer/TaskPrompt/MarginContainer/VBoxContainer/Choices/Button2/Label.text = task_choices[1]
	$CenterContainer/TaskPrompt/MarginContainer/VBoxContainer/Choices/Button3/Label.text = task_choices[2]
	
	$CenterContainer/TaskPrompt/MarginContainer/VBoxContainer/TaskQuestion.text = task["task"]


func check_answer(ans):
	$Choose.hide()
	if ans == correct_answer:
		Globals.emit_signal("small_victory")
		$CenterContainer/Results/CenterContainer/MarginContainer/VBoxContainer/ResultsTitle.text = "CORRECT!"
		$CenterContainer/Results/CenterContainer/MarginContainer/VBoxContainer/ResultsText.text = task["success"]
		success = true
	else:
		Globals.emit_signal("failure")
		$CenterContainer/Results/CenterContainer/MarginContainer/VBoxContainer/ResultsTitle.text = "INCORRECT!"
		$CenterContainer/Results/CenterContainer/MarginContainer/VBoxContainer/ResultsText.text = task["incorrect"]
	$CenterContainer/TaskPrompt.hide()
	$CenterContainer/Results.show()
	$EnterToContinue.show()
	complete = true

func _on_Button_pressed():
	check_answer($CenterContainer/TaskPrompt/MarginContainer/VBoxContainer/Choices/Button/Label.text)

func _on_Button2_pressed():
	check_answer($CenterContainer/TaskPrompt/MarginContainer/VBoxContainer/Choices/Button2/Label.text)

func _on_Button3_pressed():
	check_answer($CenterContainer/TaskPrompt/MarginContainer/VBoxContainer/Choices/Button3/Label.text)

func _input(event):
	if complete and not dismissed and Input.is_action_just_pressed("interact"):
		dismissed = true
		Globals.pause_game(false)
		var doors = get_tree().get_nodes_in_group("doors")
		for d in doors:
			if d.task_id == Globals.current_task:
				d.close()
		if success:
			Globals.completed_tasks += 1
			var l = get_tree().get_nodes_in_group("Level")
			for i in range(10):
				l[0].create_heart(Globals.get_player_pos())
		else:
			Globals.failed_tasks += 1
		Globals.emit_signal("task_popup_ended")
		queue_free()
