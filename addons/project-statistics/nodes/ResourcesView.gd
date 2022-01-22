tool
extends "./TreeView.gd"

enum {
	NAME_COLUMN,
	RESOURCE_TYPE_COLUMN,
	LOCAL_TO_SCENE_COLUMN,
	SIZE_COLUMN
}

var total_resources: TreeItem
var total_size: TreeItem

onready var graph: Control = $VSplitContainer/HSplitContainer/MarginContainer/PieGraph

func _ready() -> void:
	tree = $VSplitContainer/Tree
	summary_tree = $VSplitContainer/HSplitContainer/SummaryTree
	
	tree.set_column_title(NAME_COLUMN, "File name")
	tree.set_column_title(RESOURCE_TYPE_COLUMN, "Type")
	tree.set_column_title(LOCAL_TO_SCENE_COLUMN, "Local to scene")
	tree.set_column_title(SIZE_COLUMN, "Size")
	tree.set_column_titles_visible(true)
	tree.hide_root = true
	
	tree.connect("item_activated", self, "_on_item_activated")
	tree.connect("column_title_pressed", self, "_on_column_title_pressed")
	
	var root: TreeItem = summary_tree.create_item()
	total_resources = summary_tree.create_item(root)
	total_size = summary_tree.create_item(root)
	
	total_resources.set_text(0, "Total resources")
	total_size.set_text(0, "Total size")
	summary_tree.hide_root = true

func display(stats: ProjectStatistics) -> void:
	.display(stats)
	total_resources.set_text(1, str(stats.resources.size()))
	total_size.set_text(1, String.humanize_size(stats.get_total_scripts_size()))
	
	var series: Dictionary = {}
	for file_stats in stats.resources:
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
	for file_stats in stats.resources:
		var item: TreeItem = tree.create_item(root)
		item.set_cell_mode(LOCAL_TO_SCENE_COLUMN, TreeItem.CELL_MODE_CHECK)
		
		item.set_text(NAME_COLUMN, file_stats.get_name())
		item.set_tooltip(NAME_COLUMN, file_stats.path)
		item.set_metadata(NAME_COLUMN, file_stats.path)
		
		item.set_text(RESOURCE_TYPE_COLUMN, file_stats.type)
		item.set_checked(LOCAL_TO_SCENE_COLUMN, file_stats.local_to_scene)
		
		_format_size(item, SIZE_COLUMN, file_stats.size)

func update_icons() -> void:
	var root: TreeItem = tree.get_root()
	if not root:
		return
	var next: TreeItem = root.get_children()
	while next:
		next.set_icon(NAME_COLUMN, get_icon(next.get_text(RESOURCE_TYPE_COLUMN), "EditorIcons"))
		next.set_icon(RESOURCE_TYPE_COLUMN, get_icon("ClassList", "EditorIcons"))
		next = next.get_next()


func _sort_by_column(column: int) -> void:
	match column:
		NAME_COLUMN:
			stats.resources.sort_custom(self, "sort_name")
		RESOURCE_TYPE_COLUMN:
			stats.resources.sort_custom(self, "sort_resource_type")
		LOCAL_TO_SCENE_COLUMN:
			stats.resources.sort_custom(self, "sort_local_to_scene")
		SIZE_COLUMN:
			stats.resources.sort_custom(self, "sort_size")
