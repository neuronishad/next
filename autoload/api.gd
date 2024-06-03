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

func reprioritise():
	# Escalte priority for tasks where deadline is exceded
	var ESCALATE_PRIORITY = """
		UPDATE tasks set priority = priority - 0.5 where strftime('%s', 'now') > deadline and priority != 0;
	"""
	DB.query(ESCALATE_PRIORITY)
	
	# UPDATE DISASTER TASKS
	var UPDATE_DISASTER = """
		UPDATE tasks set deadline = 0, priority = 0 WHERE priority = 0.5;
	"""
	DB.query(UPDATE_DISASTER)
	
	# UPDATE CRITICAL TASKS
	var UPDATE_CRITICAL_TASKS = """
		UPDATE tasks set deadline = deadline + (%d * 86400), priority = 1 where priority = 1.5;
	""" % E.PriorityProps[E.Priority.CRITICAL].deadline
	DB.query(UPDATE_CRITICAL_TASKS)
	
	# UPDATE VITAL TASKS
	var UPDATE_SIGNIFICANT_TASKS = """
		UPDATE tasks set deadline = deadline + (%d * 86400), priority = 2 where priority = 2.5;
	""" % E.PriorityProps[E.Priority.SIGNIFICANT].deadline
	DB.query(UPDATE_SIGNIFICANT_TASKS)
	

func get_task_count():
	# Get task count
	var TASK_COUNT = """
		SELECT count(id) as total from tasks;
	"""
	
	return DB.query(TASK_COUNT)[0]['total']
	

