class_name LoadingManagerAutoload
extends Node

## Scene paths for scenes being loaded on threads
var threaded_load_groups: Array[ThreadedLoadGroup] = []

func _process(_delta):
	if !threaded_load_groups.is_empty():
		for group in threaded_load_groups:
			group.update_loading_status()
			print("Progress: %s" % group.progress)

##
## METHODS
##

## Loads an array of scene paths using threads
func threaded_load_scene_array(scenes: Array[String]) ->ThreadedLoadGroup :
	if scenes.is_empty(): return
	print("Starting load")

	var load_group = ThreadedLoadGroup.new()
	load_group.scene_paths = scenes

	threaded_load_groups.append(load_group)
	load_group.scenes_loaded.connect(_on_group_loaded)

	for scene_path in scenes:
		ResourceLoader.load_threaded_request(scene_path)
	
	return load_group 

##
## PRIVATE METHODS
##

func _on_group_loaded(_scenes: Array[Resource], group: ThreadedLoadGroup):
	var group_idx = threaded_load_groups.find(group)

	if group_idx > -1:
		threaded_load_groups.remove_at(group_idx)

##
## CLASSES
##

class ThreadedLoadGroup extends Object:
	signal scenes_loaded(scenes: Array[Resource], group: ThreadedLoadGroup)

	var scene_paths: Array[String] = []
	var loaded_scene_paths: Array[String] = []
	var failed_scene_paths: Array[String] = []

	var progress: float = 0

	## Updates the load status for each scene being loaded
	func update_loading_status() -> void:
		# Return if all scenes loaded
		if scene_paths.size() == loaded_scene_paths.size() + failed_scene_paths.size():
			progress = 1
			return

		var progress_acc := 0.

		for index in scene_paths.size():
			var scene_progress = []
			var load_status = ResourceLoader.load_threaded_get_status(scene_paths[index], scene_progress)

			if load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
				loaded_scene_paths.append(scene_paths[index])
				progress_acc += 1
				continue
			
			if load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
				printerr("Failed to load scene from path \"%s\"" % scene_paths[index])
				failed_scene_paths.append(scene_paths[index])
				progress_acc += 1
				continue

			if load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
				printerr("Invalid resource found at path \"%s\"" % scene_paths[index])
				failed_scene_paths.append(scene_paths[index])
				progress_acc += 1
				continue
			
			progress_acc += scene_progress[0]
		
		if scene_paths.size() == loaded_scene_paths.size() + failed_scene_paths.size():
			progress = 1
			var loaded_scenes = _get_loaded_scenes()
			scenes_loaded.emit(loaded_scenes, self)
		else:
			progress = progress_acc / scene_paths.size()
	
	func _get_loaded_scenes() -> Array[Resource]:
		if loaded_scene_paths.is_empty(): return []

		var result: Array[Resource] = []

		for scene_path in loaded_scene_paths:
			result.append(ResourceLoader.load_threaded_get(scene_path))
		
		return result
