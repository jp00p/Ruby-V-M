extends Node

var current_task = false

var ghost_color = 0.0 setget set_ghost_color
signal create_dash_ghost(frame, where)

func set_ghost_color(val):
	ghost_color = wrapf(val, 0.0, 1.0)


# tasks...
# give player task at start
# show pop up with task description
# while task is active...
# show arrow pointing towards building if it's offscreen
# highlight building
# when player arrives at building...
# stop player movement
# person comes out door
# player gets 3 choices
# after player chooses...
# new task assigned
