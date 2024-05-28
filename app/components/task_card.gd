extends PanelContainer

var inside = false
var length = 100
var startPos: Vector2
var curPos: Vector2
var swiping = false

var threshold = 20

func set_task(description: String, priority: E.Priority, _id: int):
	var id = $MarginContainer/HSplitContainer/id
	id.text = str(_id)
	
	var desc = $MarginContainer/HSplitContainer/Description
	desc.text = description
	
	var status = $MarginContainer/HSplitContainer/Priority
	status.text = E.PriorityProps[priority].display_text
	var style = status.get_theme_stylebox("normal").duplicate()
	style.bg_color = E.PriorityProps[priority].color
	status.add_theme_stylebox_override("normal", style)

func _process(_delta):
	if inside and Input.is_action_just_pressed("press"):
		if !swiping:
			swiping = true
			startPos = get_local_mouse_position()
			print(startPos)
		
	if inside and Input.is_action_pressed("press"):
		if swiping:
			curPos = get_local_mouse_position()
			if startPos.distance_to(curPos) >= length:
				if abs(startPos.y - curPos.y) <= threshold:
					swiping = false
					var id = $MarginContainer/HSplitContainer/id
					await Api.delete_task(int(id.text))
					Events.emit_signal("home_refresh_tasks")
	else:
		swiping = false

func _on_mouse_entered():
	inside = true

func _on_mouse_exited():
	inside = false
