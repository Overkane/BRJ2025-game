extends Node

func _ready():
	get_tree().change_scene_to_packed(SceneCollector.target_scene)
