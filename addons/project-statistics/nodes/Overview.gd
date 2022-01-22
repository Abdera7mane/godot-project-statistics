tool
extends "./StatisticsView.gd"

const BURNT_SIENNA: Color = Color("#EC6B56")
const CRAYOLA_MAIZE: Color = Color("#FFC154")
const KEPPEL: Color = Color("#47B39C")

var total_scenes: TreeItem
var total_resources: TreeItem
var total_scripts: TreeItem
var other_files: TreeItem

onready var summary: Tree = $HSplitContainer/SummaryTree
onready var graph: Control = $HSplitContainer/VBoxContainer/PieGraph

func _ready() -> void:
	var root: TreeItem = summary.create_item()
	total_scenes = summary.create_item(root)
	total_resources = summary.create_item(root)
	total_scripts = summary.create_item(root)
	other_files = summary.create_item(root)
	
	total_scenes.set_text(0, "Total scenes")
	total_resources.set_text(0, "Total resources")
	total_scripts.set_text(0, "Total scripts")
	other_files.set_text(0, "Other files")
	
	summary.hide_root = true

func display(stats: ProjectStatistics) -> void:
	.display(stats)
	total_scenes.set_text(1, str(stats.scenes.size()))
	total_resources.set_text(1, str(stats.resources.size()))
	total_scripts.set_text(1, str(stats.scripts.size()))
	other_files.set_text(1, str(stats.misc.size()))
	
	var series: Dictionary = {}
	series["Scenes"] = _create_chart_data("Scenes", BURNT_SIENNA)
	series["Resources"] = _create_chart_data("Resources", CRAYOLA_MAIZE)
	series["Scripts"] = _create_chart_data("Scripts", KEPPEL)
	series["Other"] = _create_chart_data("Other", Color.lightgray)
	for file_stats in stats.scenes:
		series["Scenes"].value += file_stats.size
	for file_stats in stats.resources:
		series["Resources"].value += file_stats.size
	for file_stats in stats.scripts:
		series["Scripts"].value += file_stats.size
	for file_stats in stats.misc:
		series["Other"].value += file_stats.size
	graph.set_series(series)

func update_icons() -> void:
	total_scenes.set_icon(0, get_icon("PackedScene", "EditorIcons"))
	total_resources.set_icon(0, get_icon("Object", "EditorIcons"))
	total_scripts.set_icon(0, get_icon("Script", "EditorIcons"))
	other_files.set_icon(0, get_icon("File", "EditorIcons"))

func _create_chart_data(name: String, color: Color) -> PieChart.ChartData:
	var data: PieChart.ChartData = PieChart.ChartData.new()
	data.name = name
	data.color = color
	return data
