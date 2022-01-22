extends "../FileStatistics.gd"

func is_comment(line: String) -> bool:
	# TODO: Detect multi-line comments
	return line.strip_edges().begins_with("#")

func get_extension() -> String:
	return "GDScript"

func get_icon() -> String:
	return "GDScript"

func get_color() -> Color:
	return Color.steelblue

func is_script() -> bool:
	return true
