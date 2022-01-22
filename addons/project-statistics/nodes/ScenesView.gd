tool
extends "./TreeView.gd"

enum {
	NAME_COLUMN,
	BASE_NODE_TYPE_COLUMN,
	NODE_COUNT_COLUMN,
	NODE_CONNECTIONS_COLUMN,
	LOCAL_TO_SCENE_COLUMN,
	SIZE_COLUMN
}

var total_scenes: TreeItem
var total_nodes: TreeItem
var total_connections: TreeItem
var total_size: TreeItem

func _ready() -> void:
	tree = $VSplitContainer/Tree
	summary_tree = $VSplitContainer/SummaryTree
	
	tree.set_column_title(NAME_COLUMN, "Scene")
	tree.set_column_title(BASE_NODE_TYPE_COLUMN, "Base node")
	tree.set_column_title(NODE_COUNT_COLUMN, "Node count")
	tree.set_column_title(NODE_CONNECTIONS_COLUMN, "Node connection count")
	tree.set_column_title(LOCAL_TO_SCENE_COLUMN, "Local to scene")
	tree.set_column_title(SIZE_COLUMN, "Size")
	tree.set_column_titles_visible(true)
	tree.hide_root = true
	
	tree.connect("item_activated", self, "_on_item_activated")
	tree.connect("column_title_pressed", self, "_on_column_title_pressed")
	
	var root: TreeItem = summary_tree.create_item()
	total_scenes = summary_tree.create_item(root)
	total_nodes = summary_tree.create_item(root)
	total_connections = summary_tree.create_item(root)
	total_size = summary_tree.create_item(root)
	
	total_scenes.set_text(0, "Total scenes")
	total_nodes.set_text(0, "Total nodes")
	total_connections.set_text(0, "Total connections")
	total_size.set_text(0, "Total size")
	summary_tree.hide_root = true

func display(stats: ProjectStatistics) -> void:
	.display(stats)
	
	total_scenes.set_text(1, str(stats.scenes.size()))
	total_nodes.set_text(1, str(stats.get_total_nodes()))
	total_connections.set_text(1, str(stats.get_total_connections()))
	total_size.set_text(1, String.humanize_size(stats.get_total_scenes_size()))

func update_tree(stats: ProjectStatistics) -> void:
	tree.clear()
	var root: TreeItem = tree.create_item()
	for file_stats in stats.scenes:
		var item: TreeItem = tree.create_item(root)
		item.set_cell_mode(LOCAL_TO_SCENE_COLUMN, TreeItem.CELL_MODE_CHECK)
		
		item.set_text(NAME_COLUMN, file_stats.get_name())
		item.set_tooltip(NAME_COLUMN, file_stats.path)
		item.set_metadata(NAME_COLUMN, file_stats.path)
		
		item.set_text(BASE_NODE_TYPE_COLUMN, file_stats.base_node_type)
		item.set_metadata(BASE_NODE_TYPE_COLUMN, file_stats.base_node_type)
		
		item.set_text(NODE_COUNT_COLUMN, str(file_stats.node_count))
		item.set_text(NODE_CONNECTIONS_COLUMN, str(file_stats.connection_count))
		item.set_checked(LOCAL_TO_SCENE_COLUMN, file_stats.local_to_scene)
		
		_format_size(item, SIZE_COLUMN, file_stats.size)

func update_icons() -> void:
	var root: TreeItem = tree.get_root()
	if not root:
		return
	var next: TreeItem = root.get_children()
	while next:
		next.set_icon(NAME_COLUMN, get_icon("PackedScene", "EditorIcons"))
		next.set_icon(BASE_NODE_TYPE_COLUMN, get_icon(next.get_metadata(BASE_NODE_TYPE_COLUMN), "EditorIcons"))
		next.set_icon(NODE_COUNT_COLUMN, get_icon("Node", "EditorIcons"))
		next.set_icon(NODE_CONNECTIONS_COLUMN, get_icon("Slot", "EditorIcons"))
		next = next.get_next()

func _sort_by_column(column: int) -> void:
	match column:
		NAME_COLUMN:
			stats.scenes.sort_custom(self, "sort_name")
		BASE_NODE_TYPE_COLUMN:
			stats.scenes.sort_custom(self, "sort_node_type")
		NODE_COUNT_COLUMN:
			stats.scenes.sort_custom(self, "sort_node_count")
		NODE_CONNECTIONS_COLUMN:
			stats.scenes.sort_custom(self, "sort_connection_count")
		LOCAL_TO_SCENE_COLUMN:
			stats.scenes.sort_custom(self, "sort_local_to_scene")
		SIZE_COLUMN:
			stats.scenes.sort_custom(self, "sort_size")
