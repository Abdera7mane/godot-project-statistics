tool
extends "./StatisticsView.gd"

onready var tree: Tree
onready var summary_tree: Tree

func display(stats: ProjectStatistics) -> void:
	.display(stats)
	update_tree(stats)

func update_tree(stats: ProjectStatistics) -> void:
	pass

func _on_item_activated() -> void:
	if tree.get_selected_column() == 0:
		var path: String = tree.get_selected().get_metadata(0)
		emit_signal("file_selected", path)

func _on_column_title_pressed(column: int) -> void:
	if stats:
		stats = stats.duplicate()
		_sort_by_column(column)
		update_tree(stats)
		update_icons()

func _sort_by_column(column: int) -> void:
	pass

func sort_name(file1: FileStatistics, file2: FileStatistics) -> bool:
	var result: int = file2.get_name().casecmp_to(file1.get_name())
	return result == 1 if result != 0 else sort_path(file1, file2)

func sort_path(file1: FileStatistics, file2: FileStatistics) -> bool:
	return file2.path.casecmp_to(file1.path) == 1

func sort_extension(file1: FileStatistics, file2: FileStatistics) -> bool:
	var result: int = file2.get_extension().casecmp_to(file1.get_extension())
	return result == 1 if result != 0 else sort_path(file1, file2)

func sort_resource_type(file1: FileStatistics, file2: FileStatistics) -> bool:
	var result: int = file2.type.casecmp_to(file1.type)
	return result == 1 if result != 0 else sort_path(file1, file2)

func sort_node_type(file1: FileStatistics, file2: FileStatistics) -> bool:
	var result: int = file2.base_node_type.casecmp_to(file1.base_node_type)
	return result == 1 if result != 0 else sort_path(file1, file2)

func sort_size(file1: FileStatistics, file2: FileStatistics) -> bool:
	return file1.size > file2.size if file1.size != file2.size else sort_name(file1, file2)

func sort_total_lines(file1: FileStatistics, file2: FileStatistics) -> bool:
	return file1.total_lines > file2.total_lines if file1.total_lines != file2.total_lines else sort_source_code_lines(file1, file2)

func sort_source_code_lines(file1: FileStatistics, file2: FileStatistics) -> bool:
	return file1.source_code_lines > file2.source_code_lines if file1.source_code_lines != file2.source_code_lines else sort_comment_lines(file1, file2)

func sort_comment_lines(file1: FileStatistics, file2: FileStatistics) -> bool:
	return file1.comment_lines > file2.comment_lines if file1.comment_lines != file2.comment_lines else sort_blank_lines(file1, file2)

func sort_blank_lines(file1: FileStatistics, file2: FileStatistics) -> bool:
	return file1.blank_lines > file2.blank_lines if file1.blank_lines != file2.blank_lines else sort_size(file1, file2)

func sort_node_count(file1: FileStatistics, file2: FileStatistics) -> bool:
	return file1.node_count > file2.node_count if file1.node_count != file2.node_count else sort_connection_count(file1, file2)

func sort_connection_count(file1: FileStatistics, file2: FileStatistics) -> bool:
	return file1.connection_count > file2.connection_count if file1.connection_count != file2.connection_count else sort_name(file1, file2)

func sort_local_to_scene(file1: FileStatistics, file2: FileStatistics) -> bool:
	return file1.local_to_scene if not file1.local_to_scene and file2.local_to_scene else sort_name(file1, file2)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			if is_instance_valid(tree):
				tree.clear()
			if is_instance_valid(tree):
				summary_tree.clear()
