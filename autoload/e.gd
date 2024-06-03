extends Node


class _PriorityProps:
	var deadline: int
	var color: Color
	var display_text: String
	
	func _init(deadl: int, cl: Color, dis_text: String):
		deadline = deadl
		color = cl
		display_text = dis_text
	
enum Priority {
	DISASTER,
	CRITICAL,
	SIGNIFICANT,
	IMPORTANT
}

var PriorityProps = {
	Priority.DISASTER: _PriorityProps.new(0, Color("#D32F2F"), "Disaster"),
	Priority.CRITICAL: _PriorityProps.new(2, Color("#F57C00"), "Critical"),
	Priority.SIGNIFICANT: _PriorityProps.new(5, Color("#1976D2"), "Significant"),
	Priority.IMPORTANT: _PriorityProps.new(7, Color("#388E3C"), "Important")
}
