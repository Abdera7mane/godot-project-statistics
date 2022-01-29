extends "../FileStatistics.gd"

func get_extension() -> String:
	return "Config File"
	
func get_color() -> Color:
	return Color.teal

func get_icon() -> String:
	return "File"

func is_comment(line: String) -> bool:
	return line.strip_edges().begins_with(";")
