extends ProgressBar

func _ready():
	var tween = create_tween()
	tween.tween_property(self, "value", 100, 2).as_relative()
