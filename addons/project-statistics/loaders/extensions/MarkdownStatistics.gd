extends "../FileStatistics.gd"

const ICON: Texture = preload("../../icons/markdown.svg")

func get_extension() -> String:
	return "Markdown"

func get_color() -> Color:
	return Color.ghostwhite

func get_icon() -> String:
	return ICON.resource_path
