extends Node

var database: SQLite

func query(queryS: String):
	database.query(queryS)
	return database.query_result
	
func _open_db():
	database.path = "user://data.db"
	database.open_db()

func _sdl():
	# create tasks table
	var CREATE_TASKS = """
		CREATE TABLE tasks (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		description VARCHAR(255),
		priority INT CHECK (priority BETWEEN 0 AND 3),
		created_at INTEGER,
		deadline INTEGER
		);
	"""
	
	query(CREATE_TASKS)

func _setup_db():
	await _open_db()
	_sdl()

func _ready():
	database = SQLite.new()
	if not FileAccess.file_exists("user://data.db"):
		print("no db found setting up db ...")
		await _setup_db()
	else:
		print("db available, opening ...")
		await _open_db()
