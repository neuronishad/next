extends PanelContainer

var inside = false
var length = 150
var startPos: Vector2
var curPos: Vector2
var swiping = false

var threshold = 20

func set_task(description: String, priority: E.Priority, _id: int):
	var id = $Task/MarginContainer/HSplitContainer/id
	id.text = str(_id)
	
	var desc = $Task/MarginContainer/HSplitContainer/Description
	desc.text = description
	
	var prio = $Task/MarginContainer/HSplitContainer/Priority
	prio.text = E.PriorityProps[priority].display_text
	var style = prio.get_theme_stylebox("normal").duplicate()
	style.bg_color = E.PriorityProps[priority].color
	prio.add_theme_stylebox_override("normal", style)

func _process(_delta):
	if inside and Input.is_action_just_pressed("press"):
		if !swiping:
			swiping = true
			startPos = get_global_mouse_position()
		
	if inside and Input.is_action_pressed("press"):
		if swiping:
			curPos = get_global_mouse_position()
			if startPos.distance_to(curPos) >= length:
				if abs(startPos.y - curPos.y) <= threshold:
					var id = $Task/MarginContainer/HSplitContainer/id
					await Api.delete_task(int(id.text))
					Events.emit_signal("home_refresh_tasks")
					swiping = false
			else:
				if curPos.x > startPos.x:
					var tween = get_tree().create_tween()
					tween.tween_property($Task, "position:x", curPos.x - startPos.x, 0.2).set_ease(Tween.EASE_OUT)
	else:
		swiping = false


func _on_task_button_down():
	inside = true


func _on_task_button_up():
	inside = false
	$Task.release_focus()
	var tween = get_tree().create_tween()
	tween.tween_property($Task, "position:x", 0, 0.2).set_ease(Tween.EASE_OUT)
