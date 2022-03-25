extends Node

signal task_changed(task)
signal task_popup_started()
signal task_popup_ended()
signal hearts_changed(val)
signal create_dash_ghost(frame, where)
signal stage_changed(stage)
signal game_won()
signal small_victory()
signal failure()
signal stage_complete()
signal game_over()

var game_paused = false setget pause_game
var previous_tasks = []
var current_task = null setget task_changed
var completed_tasks = 0 setget task_complete
var failed_tasks = 0 setget task_failed
var hearts = 10 setget set_hearts
var stage = 1 setget set_stage

var ghost_color = 0.0 setget set_ghost_color

onready var heart = preload("res://Heart.tscn")

onready var extras = [
	preload("res://extra1.tres"),
	preload("res://extra2.tres"),
	preload("res://extra3.tres"),
	preload("res://extra4.tres"),
	preload("res://extra5.tres")
]

onready var heart_textures = [
	preload("res://assets/hearts/Hearts-68.png"),
	preload("res://assets/hearts/Hearts-69.png"),
	preload("res://assets/hearts/Hearts-70.png")
]

onready var task_popup = preload("res://Task.tscn")

onready var explosion = preload("res://Explosion.tscn")

var stage_sky_limits = {
	1: -1800,
	2: -350
}

var stage_sky_starts = {
	1: -3185,
	2: -1800
}

var tasks = {
	1: {
		"task1" : {
			"task" : "Hello! I am checking to see what your hours are?",
			"choices" : ["I'm happy to help out! The office is open until 6pm.", "If you can get here before dinner, that would be best.", "Sure, can you hold on a moment while I look it up?"],
			"success" : "Yes! We always deliver exceptional experiences. Even for mundane questions.",
			"incorrect": "Not quite! We want to deliver exceptional experiences."
		},
		"task2" : {
			"task" : "Hi. I have a big case I'd like to speak with Ms. Attorney about.",
			"choices" : ["Ms. Attorney is in court right now, but I will have her contact you as soon as she is able!", "That sounds messy. I can have her get back to you later, okay?", "Ms. Attorney is busy but I think maybe tomorrow will work."],
			"success" : "Woo-hoo! Yes! We empower our customers to pursue their purpose.",
			"incorrect": "Whoops! We want to present our customers in the best, most professional light!"
		},
		"task3" : {
			"task" : "Hi, I'm with the Chamber of Commerce. Would Ms. Attorney like to join our board?",
			"choices" : ["Thank you for reaching out, I will see that Ms. Attorney gets your message!", "How exciting, I'm certain she will totally say yes!", "Ms. Attorney is really busy, but I will pass along your message."],
			"success" : "Yeah! We help our customers to cultivate diverse and thriving local economies by providing clear, kind responses in the way that their own office would.",
			"incorrect": "That's a miss! We can't speak for our customers beyond the instructions and information they provide."
		},
		"task4" : {
			"task" : "Our high school is hosting a mock debate. Would Ms. Attorney like to be a judge?",
			"choices" : ["Wow how fun! I will certainly pass the message along to her.", "She's probably too busy but I can pass it on", "I'll give her the message."],
			"success" : "Yep yep! We help our customers cultivate relationships with their callers and clients.",
			"incorrect": "Ack, nope. We help our customers cultivate relationships with their callers and clients."
		},
		"task5" : {
			"task" : "I need to drop off a document at 6 a.m. before I leave town. Will somebody be there?",
			"choices" : ["Unfortunately no, but we do have a secure document slot you can use.", "Just throw it through the mail slot, we get all the mail.", "Maybe. Can you call back in a little while?"],
			"success" : "Correct! We always provide exceptional experiences so that our customers know that we value their clients and their work.",
			"incorrect": "Yikes! We always provide exceptional experiences so that our customers know that we value their clients and their work."
		},
	},
	2: {
		"task1" : {
			"task" : "Hi. I am hoping to get a quote for installing some new plumbing.",
			"choices" : ["No problem. I can have one of our team members give you a call as soon as they finish up today.", "We have a big job today so maybe try somebody else.", "That usually costs thousands, if I had to guess."],
			"success" : "This! We create meaningful connections for our customers and their clients.",
			"incorrect": "Womp womp! We can’t speak about our customers’ business past the information they provide to us. "
		},
		"task2" : {
			"task" : "Help! I am an existing client and I broke one of my pipes!",
			"choices" : ["Oh dear that sounds like an emergency! Our team is at a job, but I will message them immediately.", "That’s awful, what a mess. Maybe get some floaties out and make it a party?", "Sounds like you are having a bad day. Did you try turning off the water to the house?"],
			"success" : "Spot on! We provide our customers with insights and capture opportunities so they don’t go elsewhere.",
			"incorrect": "Sad trombone. We follow our customers’ directions and requests to keep their business flowing smoothly."
		},
		"task3" : {
			"task" : "Hello. I am making a delivery of copper piping and need to speak to the owner.",
			"choices" : ["They are currently at a job, but I can have them reach out as soon as they are able.", "They are too busy today can you call back tomorrow?", "Just drop it by the roll up door."],
			"success" : "Yeah! We help our customers to cultivate diverse and thriving local economies by providing clear, kind responses in the way that their own office would.",
			"incorrect": "That's a miss! We can't speak for our customers beyond the instructions and information they provide."
		}
	}
}


var intro_texts = {
	1: "Hi Ruby! I'll be in court until around 2pm today\n\nCan you please handle all my calls until then?\n\nThank you!",
	2: "Hi Ruby. My team will be at a job site today and we can’t take our calls or chats. Will you please answer them and let us know if there are any emergencies? ",
}

var outro_texts = {
	1: "You’ve unlocked Ruby’s Vision!\n\nPlease take a moment to read through before you move to level 2!\n\nVision:\"We deliver exceptional experiences that build customer loyalty and empower businesses to freely pursue their purpose, cultivating diverse and thriving local economies.\"",
	2: "Congratulations! You unlocked our Mission!\n\nMission: \"We create meaningful connections and provide actionable insights that capture opportunities and give businesses the freedom over when and how they communicate so they can achieve more.\"",
}

var client_names = {
	1: "Ms. Attorney",
	2: "Mr. Plumber"
}

func _ready():
	self.hearts = 5
	self.stage = 1

func set_ghost_color(val):
	ghost_color = wrapf(val, 0.0, 1.0)

func pause_game(state):
	print("Setting paused to %s" % state)
	game_paused = state
	var player = get_tree().get_nodes_in_group("player")
	if player:
		player[0].stopped = state
	var timer = get_tree().get_nodes_in_group("game_timer")
	if timer:
		timer[0].paused = state

func give_task():
	# loop instead of pop
	#if current_task != null and tasks[stage].size() > 0:
		#tasks[stage].erase(current_task)
	previous_tasks.append(current_task)
	var k = tasks[stage].keys()
	var random_task = k[randi()%k.size()]
	if previous_tasks.size() == k.size():
		previous_tasks = []
	while random_task in previous_tasks:
		random_task = k[randi()%k.size()]
	self.current_task = random_task
	
func get_task_pos():
	var doors = get_tree().get_nodes_in_group("doors")
	for d in doors:
		if d.task_id == current_task:
			return d.global_position
		else:
			return Vector2.ZERO
	
func get_player_pos():
	var player = get_tree().get_nodes_in_group("player")
	return player[0].global_position

func task_changed(val):
	current_task = val
	print("Task changed! %s" % current_task)
	emit_signal("task_changed", current_task)

func set_hearts(val):
	hearts = max(val, 0)
	emit_signal("hearts_changed", hearts)

func start_task_questions():
	emit_signal("task_popup_started")
	var t = task_popup.instance()
	get_tree().get_root().get_node("Level").add_child(t)

func randombit():
	if randf() < 0.5:
		return 1
	return -1

func set_stage(val):
	stage = val
	if stage == 3:
		emit_signal("game_won")
		return
	self.current_task = null
	previous_tasks = []
	emit_signal("stage_changed", stage)

func task_complete(val):
	completed_tasks = val
	if completed_tasks >= 3:
		self.current_task = null
		completed_tasks = 0
		emit_signal("stage_complete")
	else:
		give_task()

func task_failed(val):
	failed_tasks = val
	if failed_tasks >= 3:
		self.current_task = null
		emit_signal("game_over")
	else:
		give_task()
