extends Control

var loading_scene = preload("res://scenes/Loading.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().root.add_child(loading_scene)
	self.visible = false
	
	await get_tree().create_timer(3).timeout
	self.visible = true
	
	get_tree().root.remove_child(loading_scene)
	loading_scene.free()
