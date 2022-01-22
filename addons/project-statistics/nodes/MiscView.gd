tool
extends "./TreeView.gd"

enum {
	NAME_COLUMN,
	EXTENSION_COLUMN,
	TOTAL_LINES_COLUMN,
	SOURCE_LINES_COLUMN,
	COMMENT_LINES_COLUMN,
	BLANK_LINES_COLUMN,
	SIZE_COLUMN
}

var total_files: TreeItem
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
	tree.set_column_title(EXTENSION_COLUMN, "Extension")
	tree.set_column_title(TOTAL_LINES_COLUMN, "Total lines")
	tree.set_column_title(SOURCE_LINES_COLUMN, "Source lines")
	tree.set_column_title(COMMENT_LINES_COLUMN, "Comment lines")
	tree.set_column_title(BLANK_LINES_COLUMN, "Blank lines")
	tree.set_column_title(SIZE_COLUMN, "Size")
	tree.set_column_titles_visible(true)
	tree.hide_root = true
	
	tree.connect("item_activated", self, "_on_item_activated")
	tree.connect("column_title_pressed", self, "_on_column_title_pressed")
	
	var root: TreeItem = summary_tree.create_item()
	total_files = summary_tree.create_item(root)
	total_lines = summary_tree.create_item(root)
	total_code_lines = summary_tree.create_item(root)
	total_comments_lines = summary_tree.create_item(root)
	total_blank_lines = summary_tree.create_item(root)
	total_size = summary_tree.create_item(root)
	
	total_files.set_text(0, "Total files")
	total_lines.set_text(0, "Total lines")
	total_code_lines.set_text(0, "Total code lines")
	total_comments_lines.set_text(0, "Total comments lines")
	total_blank_lines.set_text(0, "Total blank lines")
	total_size.set_text(0, "Total size")
	summary_tree.hide_root = true

func display(stats: ProjectStatistics) -> void:
	.display(stats)
	total_files.set_text(1, str(stats.misc.size()))
	total_lines.set_text(1, str(stats.get_total_lines(false)))
	total_code_lines.set_text(1, str(stats.get_total_code_lines(false)))
	total_comments_lines.set_text(1, str(stats.get_total_comment_lines(false)))
	total_blank_lines.set_text(1, str(stats.get_total_blank_lines(false)))
	total_size.set_text(1, String.humanize_size(stats.get_other_files_size()))
	
	var series: Dictionary = {}
	for file_stats in stats.misc:
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
	for file_stats in stats.misc:
		var item: TreeItem = tree.create_item(root)
		
		item.set_text(NAME_COLUMN, file_stats.get_name())
		item.set_tooltip(NAME_COLUMN, file_stats.path)
		item.set_metadata(NAME_COLUMN, file_stats.path)
		
		item.set_text(EXTENSION_COLUMN, file_stats.get_extension())
		item.set_metadata(EXTENSION_COLUMN, file_stats.get_icon())
		
		item.set_text(TOTAL_LINES_COLUMN, str(file_stats.total_lines))
		item.set_text(SOURCE_LINES_COLUMN, str(file_stats.source_code_lines))
		item.set_text(COMMENT_LINES_COLUMN, str(file_stats.comment_lines))
		item.set_text(BLANK_LINES_COLUMN, str(file_stats.blank_lines))
		
		_format_size(item, SIZE_COLUMN, file_stats.size)

func update_icons() -> void:
	var root: TreeItem = tree.get_root()
	if not root:
		return
	var next: TreeItem = root.get_children()
	while next:
		var icon_path: String = next.get_metadata(EXTENSION_COLUMN)
		if ResourceLoader.exists(icon_path):
			next.set_icon(NAME_COLUMN, ResourceLoader.load(icon_path))
			next.set_icon_max_width(NAME_COLUMN, 16)
		
		next.set_icon(TOTAL_LINES_COLUMN, get_icon("MultiLine", "EditorIcons"))
		next.set_icon(SOURCE_LINES_COLUMN, get_icon("MultiLine", "EditorIcons"))
		next.set_icon(COMMENT_LINES_COLUMN, get_icon("VisualScriptComment", "EditorIcons"))
		next = next.get_next()

func _sort_by_column(column: int) -> void:
	match column:
		NAME_COLUMN:
			stats.misc.sort_custom(self, "sort_name")
		EXTENSION_COLUMN:
			stats.misc.sort_custom(self, "sort_extension")
		TOTAL_LINES_COLUMN:
			stats.misc.sort_custom(self, "sort_total_lines")
		SOURCE_LINES_COLUMN:
			stats.misc.sort_custom(self, "sort_source_code_lines")
		COMMENT_LINES_COLUMN:
			stats.misc.sort_custom(self, "sort_comment_lines")
		BLANK_LINES_COLUMN:
			stats.misc.sort_custom(self, "sort_blank_lines")
		SIZE_COLUMN:
			stats.misc.sort_custom(self, "sort_size")
