class_name GameManagerAutoload
extends Node

func _ready():
	var scenes: Array[String] = []

	for i in range(1000):
		scenes.append("res://scenes/characters/player_character/player_character.tscn")

	LoadingManager.threaded_load_scene_array(scenes).scenes_loaded.connect(_on_scenes_loaded)

func _on_scenes_loaded(scenes: Array[Resource], _group):
	print("%s scenes loaded" % scenes.size())