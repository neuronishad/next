extends Node

func add_task(description: String, priority: E.Priority):
	var created_at = Time.get_unix_time_from_system()
	var deadline = created_at + (E.PriorityProps[priority].deadline * 24 * 60 * 60)
	
	# INSERT INTO TASK
	var INSERT_TASK = """
		INSERT INTO tasks (description, priority, created_at, deadline)
		VALUES ('%s', %d, %d, %d);
	""" % [description, priority, created_at, deadline]
	
	DB.query(INSERT_TASK)

func delete_task(task_id: int):
	# DELETE TASK
	var DELETE_TASK = """
		DELETE from tasks where id=%d
	""" % task_id
	
	DB.query(DELETE_TASK)

func get_tasks():
	# Get tasks ordered by deadline
	var GET_TASKS_BY_DEADLINE = """
		SELECT id, description, priority from tasks order by deadline asc limit 8;
	"""
	var results = DB.query(GET_TASKS_BY_DEADLINE)
	
	return results
