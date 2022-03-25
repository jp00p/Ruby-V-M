extends Node

func goto_scene(path, current_scene):
	var loader = ResourceLoader.load_interactive(path)
	var loading_screen = load("res://ProgressBar.tscn").instance()
	var progress_bar = loading_screen.get_node("Progress")
	get_tree().get_root().call_deferred('add_child', loading_screen)
	
	while true:
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			# done loading
			var resource = loader.get_resource()
			get_tree().get_root().call_deferred('add_child', resource.instance())
			current_scene.queue_free()
			loading_screen.queue_free()
			break
		
		if err == OK:
			# still loading
			var progress = float(loader.get_stage())/float(loader.get_stage_count())
			progress_bar.value = progress * 100
			print("%s" % progress)
		
		yield(get_tree(), "idle_frame")
