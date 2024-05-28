extends Control

var home_scene = preload("res://app/home.tscn")


func _ready():
	get_tree().change_scene_to_packed.call_deferred(home_scene)
