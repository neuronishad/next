extends Control

var task_card = preload("res://app/components/task_card.tscn")

@onready var addTask = $AddTask
@onready var taskDescription = $AddTask/MarginContainer/Bg/MarginContainer/AddTaskContainer/Description
@onready var descriptionError = $AddTask/MarginContainer/Bg/MarginContainer/AddTaskContainer/DescriptionError
@onready var taskPrioriry = $AddTask/MarginContainer/Bg/MarginContainer/AddTaskContainer/Priority
@onready var priorityError = $AddTask/MarginContainer/Bg/MarginContainer/AddTaskContainer/PriorityError
@onready var addTaskContainer = $AddTask/MarginContainer/Bg/MarginContainer/AddTaskContainer
@onready var taskContainer = $Bg/MarginContainer/VSplitContainer/ScrollContainer/MarginContainer/TaskContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("home_refresh_tasks", Callable(self, "refresh_tasks"))
	
	await Loader.load_data(self, Callable(self, "load_tasks"))

func _emtpy_container():
	for n in taskContainer.get_children(): n.queue_free()

func load_tasks():
	var tasks = Api.get_tasks()
	
	for task in tasks:
		var card = task_card.instantiate(1)
		card.name = "TASK-%d" % task.id
		print("adding task - ", card.name)
		card.set_task(task.description, task.priority as E.Priority, task.id)
		
		taskContainer.add_child(card)

func refresh_tasks():
	await _emtpy_container()
	#await Loader.load_data(taskContainer, Callable(self, "load_tasks"))
	await load_tasks()

func _on_add_pressed():
	addTask.visible = true

func _on_cancel_pressed():
	addTask.visible = false

func _on_save_pressed():
	var error = false
	
	if taskDescription.text == "":
		error = true
		descriptionError.visible = true
	else:
		descriptionError.visible = false
		
	if taskPrioriry.selected == 0:
		error = true
		priorityError.visible = true
	else:
		priorityError.visible = false
	
	if error:
		addTaskContainer.add_theme_constant_override("separation", 20)
		return
	
	await Api.add_task(taskDescription.text, taskPrioriry.selected as E.Priority)
	addTask.visible = false
	refresh_tasks()
