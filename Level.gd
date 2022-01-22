extends Node2D

onready var ghost = preload("res://DashGhost.tscn")

func _ready():
	Globals.connect("create_dash_ghost", self, "create_dash_ghost")
	randomize()

func _on_CloudTimer_timeout():
	var cloud = load("res://Cloud.tscn").instance()
	var pos_x = rand_range(0, 3500)
	var pos_y = rand_range(0, 300)
	cloud.global_position = Vector2(pos_x, pos_y)
	$Clouds.add_child(cloud)

func create_dash_ghost(frame, where, flip=false):
	var g = ghost.instance()
	g.get_node("Sprite").texture = frame
	g.get_node("Sprite").flip_h = flip
	g.global_position = where
	g.modulate.h = Globals.ghost_color
	Globals.ghost_color = Globals.ghost_color + 0.05
	add_child(g)
	
