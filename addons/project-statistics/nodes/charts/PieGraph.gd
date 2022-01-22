tool
extends HSplitContainer

const PieChart: Script = preload("./PieChart.gd")

const CIRCLE_ICON: Texture = preload("../../icons/circle.svg")

onready var chart: PieChart = $PieChart
onready var key_tree: Tree = $KeyTree


func set_series(series: Dictionary) -> void:
	chart.series = series
	chart.update()
	key_tree.clear()
	
	var root: TreeItem = key_tree.create_item()
	
	var values: Array = series.values()
	values.sort_custom(self, "_sort_series")
	
	var total: float = _get_total(values)
	for data in values:
		var item: TreeItem = key_tree.create_item(root)
		item.set_text(0, data.name)
		item.set_icon(0, CIRCLE_ICON)
		item.set_icon_modulate(0, data.color)
		item.set_icon_max_width(0, 8)
		item.set_text(1, "%05.2f" % (data.value / total * 100))
		item.set_suffix(1, "%")
	
	chart.series = series
	chart.update()

func _get_total(series: Array) -> float:
	var total: float
	for data in series:
		total += data.value
	return total

func _sort_series(data1: PieChart.ChartData, data2: PieChart.ChartData) -> bool:
	return data1.value > data2.value

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_RESIZED, NOTIFICATION_SORT_CHILDREN:
			if chart:
				chart.radius = min(chart.rect_size.x, chart.rect_size.y) / 2 * 0.9
