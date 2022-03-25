extends Node2D

onready var ghost = preload("res://DashGhost.tscn")
onready var extra = preload("res://Extra.tscn")
onready var dennis = preload("res://Dennis.tscn")
onready var cloud = preload("res://Cloud.tscn")
onready var heart = Globals.heart

func _ready():
	Globals.connect("create_dash_ghost", self, "create_dash_ghost")
	Globals.connect("game_won", self, "game_won")
	Globals.connect("small_victory", self, "victory_fanfare")
	Globals.connect("failure", self, "failure_sound")
	Globals.connect("stage_changed", self, "stage_start")
	Globals.connect("game_over", self, "game_over")
	randomize()
	
func _process(delta):
	if Globals.stage < 3:
		$Sky.rect_position.y = min($Sky.rect_position.y + 10 * delta, Globals.stage_sky_limits[Globals.stage])
	
func _input(event):
	if Input.is_action_just_pressed("fullscreen"):
		#Globals.stage += 1
		OS.set_window_fullscreen(!OS.window_fullscreen)

func _on_CloudTimer_timeout():
	var c = cloud.instance()
	var pos_x = rand_range(0, 3500)
	var pos_y = rand_range(0, 300)
	c.global_position = Vector2(pos_x, pos_y)
	$Clouds.add_child(c)

func create_dash_ghost(frame, where, flip=false):
	var g = ghost.instance()
	g.get_node("Sprite").texture = frame
	g.get_node("Sprite").flip_h = flip
	g.global_position = where
	g.modulate.h = Globals.ghost_color
	Globals.ghost_color = Globals.ghost_color + 0.05
	add_child(g)

func create_heart(where):
	var h = heart.instance()
	h.global_position = where
	call_deferred("add_child", h)

func _on_ExtraTimer_timeout():
	if randf() > 0.3:
		var e = extra.instance()
		var side = Globals.randombit()
		var layer = Globals.randombit()
		if side == -1:
			e.global_position = $ExtraSpawn2.global_position
			e.direction = -1
		else:
			e.global_position = $ExtraSpawn1.global_position
			e.direction = 1
		if layer == -1:
			$ExtrasLayerBG.add_child(e)
		else:
			$ExtrasLayerFG.add_child(e)

func _on_DennisTimer_timeout():
	if randf() > 0.7:
		var d = dennis.instance()
		var side = Globals.randombit()
		if side == -1:
			d.global_position = $ExtraSpawn2.global_position
			d.direction = -1
		else:
			d.global_position = $ExtraSpawn1.global_position
			d.direction = 1
		$ExtrasLayerBG.add_child(d)


func _on_Player_spawn_heart(where):
	create_heart(where)


func _on_UI_end_game():
	SceneChanger.goto_scene("res://Title.tscn", self)

func game_won():
	SceneChanger.goto_scene("res://Win.tscn", self)

func victory_fanfare():
	$Victory.play()

func failure_sound():
	$Error.play()

func stage_start(stage):
	if Globals.stage < 3:
		print("Setting sky")
		$Sky.rect_position.y = Globals.stage_sky_starts[Globals.stage]

func game_over():
	$BGM.stop()
	$Gameover.play()
