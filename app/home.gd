extends Control

var task_card = preload("res://app/components/task_card.tscn")

@onready var addTask = $AddTask
@onready var taskDescription = $AddTask/MarginContainer/Bg/MarginContainer/AddTaskContainer/Description
@onready var descriptionError = $AddTask/MarginContainer/Bg/MarginContainer/AddTaskContainer/DescriptionError
@onready var taskPriority = $AddTask/MarginContainer/Bg/MarginContainer/AddTaskContainer/Prioriry/Box/List
@onready var priorityError = $AddTask/MarginContainer/Bg/MarginContainer/AddTaskContainer/PriorityError
@onready var addTaskContainer = $AddTask/MarginContainer/Bg/MarginContainer/AddTaskContainer
@onready var taskContainer = $Bg/MarginContainer/VBoxContainer/ScrollContainer/MarginContainer/TaskContainer
@onready var taskCount = $Bg/MarginContainer/VBoxContainer/PanelContainer/Count

var priorityGroupStyle = ResourceLoader.load("res://resources/select_priority_button.stylebox") as StyleBoxFlat
var _priority: int
var _priorityButton: Button

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("home_refresh_tasks", Callable(self, "refresh_tasks"))
	
	await Loader.load_data(self, Callable(self, "init_tasks"))
	
	for id in E.Priority.values():
		if id != E.Priority.DISASTER:
			var btn = _load_priority_button(E.PriorityProps[id].display_text, id, E.PriorityProps[id].color)
			taskPriority.add_child(btn)

func _load_priority_button(prio: String, id: int, clr: Color):
	var btn = Button.new()
	btn.name = "prio-" + str(id)
	btn.text = prio
	btn.toggle_mode = true
	btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	btn.custom_minimum_size = Vector2(100,0)
	btn.add_theme_font_size_override("font_size", 17)
	btn.add_theme_color_override("font_color", Color("#212121"))
	btn.add_theme_color_override("font_pressed_color", Color("#ffffff"))
	btn.add_theme_color_override("font_hover_color", Color("#ffffff"))
	btn.add_theme_color_override("font_focus_color", Color("#ffffff"))
	btn.add_theme_stylebox_override("normal", priorityGroupStyle)
	var focus_style = priorityGroupStyle.duplicate()
	focus_style.bg_color = clr
	btn.add_theme_stylebox_override("hover", focus_style)
	btn.add_theme_stylebox_override("pressed", focus_style)
	btn.add_theme_stylebox_override("focus", focus_style)
	btn.connect("toggled", Callable(self, "_change_priority").bind(id, btn))
	return btn
	
func _change_priority(toggled_on: bool, id: int, btn: Button):
	if toggled_on:
		_priority = id
		_priorityButton = btn
	else:
		_priority = 0
		btn.set_pressed(false)
		btn.release_focus()
		
func load_tasks():
	var tasks = Api.get_tasks()
	
	for task in tasks:
		var card = task_card.instantiate()
		card.name = "TASK-%d" % task.id
		print("adding task - ", card.name)
		card.set_task(task.description, task.priority as E.Priority, task.id)
		
		taskContainer.add_child(card)
	
	taskCount.text = str(Api.get_task_count())
		
func unload_tasks():
	for n in taskContainer.get_children(): n.queue_free()

func init_tasks():
	await Api.reprioritise()
	await load_tasks()

func refresh_tasks():
	await unload_tasks()
	await load_tasks()
	
func _refresh_add_form():
	taskDescription.text = ""
	if _priorityButton:
		_priorityButton.emit_signal("toggled", false)
	_priority = 0

func _on_add_pressed():
	addTask.visible = true
	taskDescription.grab_focus()

func _on_cancel_pressed():
	_refresh_add_form()
	addTask.visible = false
	

func _on_save_pressed():
	var error = false
	
	if taskDescription.text == "":
		error = true
		descriptionError.visible = true
	else:
		descriptionError.visible = false
		
	if _priority == 0:
		error = true
		priorityError.visible = true
	else:
		priorityError.visible = false
	
	if error:
		addTaskContainer.add_theme_constant_override("separation", 20)
		return
	
	await Api.add_task(taskDescription.text, _priority as E.Priority)
	addTask.visible = false
	refresh_tasks()
	_refresh_add_form()
