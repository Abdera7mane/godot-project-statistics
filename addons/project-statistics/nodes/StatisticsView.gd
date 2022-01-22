tool
extends Control

signal file_selected(path)

const ProjectStatistics: Script = preload("../loaders/ProjectStatistics.gd")
const FileStatistics: Script = preload("../loaders/FileStatistics.gd")
const PieChart: Script = preload("./charts/PieChart.gd")

var stats: ProjectStatistics

func display(stats: ProjectStatistics) -> void:
	self.stats = stats
	yield(get_tree(), "idle_frame")
	update_icons()

func update_icons() -> void:
	pass

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_THEME_CHANGED:
			call_deferred("update_icons")

static func _format_size(item: TreeItem, column: int, size: int) -> void:
	var size_text: PoolStringArray = String.humanize_size(size).split(" ")
	var size_value: String = size_text[0]
	var size_unit: String = size_text[1]
	item.set_text(column, size_value)
	item.set_suffix(column, size_unit)
	item.set_tooltip(column, str(size) + " bytes")
	item.set_text_align(column, TreeItem.ALIGN_CENTER)
