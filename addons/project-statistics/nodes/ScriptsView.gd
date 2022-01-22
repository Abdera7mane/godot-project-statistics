tool
extends "./TreeView.gd"

enum {
	NAME_COLUMN,
	LANGUAGE_COLUMN,
	TOTAL_LINES_COLUMN,
	CODE_LINES_COLUMN,
	COMMENT_LINES_COLUMN,
	BLANK_LINES_COLUMN,
	SIZE_COLUMN
}

var total_scripts: TreeItem
var used_languages: TreeItem
var total_lines: TreeItem
var total_code_lines: TreeItem
var total_comments_lines: TreeItem
var total_blank_lines: TreeItem
var total_size: TreeItem

onready var graph: Control = $VSplitContainer/HSplitContainer/MarginContainer/PieGraph

func _ready() -> void:
	tree = $VSplitContainer/Tree
	summary_tree = $VSplitContainer/HSplitContainer/SummaryTree
	
	tree.set_column_title(NAME_COLUMN, "File name")
	tree.set_column_title(LANGUAGE_COLUMN, "Language")
	tree.set_column_title(TOTAL_LINES_COLUMN, "Total lines")
	tree.set_column_title(CODE_LINES_COLUMN, "Code lines")
	tree.set_column_title(COMMENT_LINES_COLUMN, "Comment lines")
	tree.set_column_title(BLANK_LINES_COLUMN, "Blank lines")
	tree.set_column_title(SIZE_COLUMN, "Size")
	tree.set_column_titles_visible(true)
	tree.hide_root = true
	
	tree.connect("item_activated", self, "_on_item_activated")
	tree.connect("column_title_pressed", self, "_on_column_title_pressed")
	
	var root: TreeItem = summary_tree.create_item()
	total_scripts = summary_tree.create_item(root)
	used_languages = summary_tree.create_item(root)
	total_lines = summary_tree.create_item(root)
	total_code_lines = summary_tree.create_item(root)
	total_comments_lines = summary_tree.create_item(root)
	total_blank_lines = summary_tree.create_item(root)
	total_size = summary_tree.create_item(root)
	
	total_scripts.set_text(0, "Total scripts")
	used_languages.set_text(0, "Used languages")
	total_lines.set_text(0, "Total lines")
	total_code_lines.set_text(0, "Total code lines")
	total_comments_lines.set_text(0, "Total comments lines")
	total_blank_lines.set_text(0, "Total blank lines")
	total_size.set_text(0, "Total size")
	summary_tree.hide_root = true


func display(stats: ProjectStatistics) -> void:
	.display(stats)
	
	total_scripts.set_text(1, str(stats.scripts.size()))
	used_languages.set_text(1, stats.get_used_langauges().join(", "))
	total_lines.set_text(1, str(stats.get_total_lines()))
	total_code_lines.set_text(1, str(stats.get_total_code_lines()))
	total_comments_lines.set_text(1, str(stats.get_total_comment_lines()))
	total_blank_lines.set_text(1, str(stats.get_total_blank_lines()))
	total_size.set_text(1, String.humanize_size(stats.get_total_scripts_size()))
	
	var series: Dictionary = {}
	for file_stats in stats.scripts:
		var name: String = file_stats.get_name()
		var extension: String = file_stats.get_extension()
		var color: Color = file_stats.get_color()
		
		var chart_data: PieChart.ChartData
		if not series.has(extension):
			chart_data = PieChart.ChartData.new()
			chart_data.name = extension
			chart_data.color = color
			series[extension] = chart_data
		else:
			chart_data = series[extension]
		chart_data.value += file_stats.size
	graph.set_series(series)

func update_tree(stats: ProjectStatistics) -> void:
	tree.clear()
	var root: TreeItem = tree.create_item()
	for file_stats in stats.scripts:
		var item: TreeItem = tree.create_item(root)
		
		item.set_text(NAME_COLUMN, file_stats.get_name())
		item.set_tooltip(NAME_COLUMN, file_stats.path)
		item.set_metadata(NAME_COLUMN, file_stats.path)
		
		item.set_text(LANGUAGE_COLUMN, file_stats.get_extension())
		item.set_metadata(LANGUAGE_COLUMN, file_stats.get_icon())
		
		item.set_text(TOTAL_LINES_COLUMN, str(file_stats.total_lines))
		item.set_text(CODE_LINES_COLUMN, str(file_stats.source_code_lines))
		item.set_text(COMMENT_LINES_COLUMN, str(file_stats.comment_lines))
		item.set_text(BLANK_LINES_COLUMN, str(file_stats.blank_lines))
		
		_format_size(item, SIZE_COLUMN, file_stats.size)

func update_icons() -> void:
	var root: TreeItem = tree.get_root()
	if not root:
		return
	var next: TreeItem = root.get_children()
	while next:
		next.set_icon(NAME_COLUMN, get_icon(next.get_metadata(LANGUAGE_COLUMN), "EditorIcons"))
		next.set_icon(LANGUAGE_COLUMN, get_icon("Script", "EditorIcons"))
		next.set_icon(TOTAL_LINES_COLUMN, get_icon("MultiLine", "EditorIcons"))
		next.set_icon(CODE_LINES_COLUMN, get_icon("MultiLine", "EditorIcons"))
		next.set_icon(COMMENT_LINES_COLUMN, get_icon("VisualScriptComment", "EditorIcons"))
		next = next.get_next()

func _sort_by_column(column: int) -> void:
	match column:
		NAME_COLUMN:
			stats.scripts.sort_custom(self, "sort_name")
		LANGUAGE_COLUMN:
			stats.scripts.sort_custom(self, "sort_extension")
		TOTAL_LINES_COLUMN:
			stats.scripts.sort_custom(self, "sort_total_lines")
		CODE_LINES_COLUMN:
			stats.scripts.sort_custom(self, "sort_source_code_lines")
		COMMENT_LINES_COLUMN:
			stats.scripts.sort_custom(self, "sort_comment_lines")
		BLANK_LINES_COLUMN:
			stats.scripts.sort_custom(self, "sort_blank_lines")
		SIZE_COLUMN:
			stats.scripts.sort_custom(self, "sort_size")
