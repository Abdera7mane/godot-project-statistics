extends "../FileStatistics.gd"

func is_comment(line: String) -> bool:
	line = line.strip_edges()
	return (line.begins_with("//")
		or line.begins_with("/*")
		or line.begins_with("*")
		or line.ends_with("*/"))

func get_extension() -> String:
	return "C#"

func get_icon() -> String:
	return "CSharpScript"

func get_color() -> Color:
	return Color.limegreen

func is_script() -> bool:
	return true
