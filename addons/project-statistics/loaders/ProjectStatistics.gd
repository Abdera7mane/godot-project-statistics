const FileStatistics: Script = preload("./FileStatistics.gd")
const CSharpStatistics: Script = preload("./extensions/CSharpStatistics.gd")
const GDScriptStatistics: Script = preload("./extensions/GDScriptStatistics.gd")
const JSONStatistics: Script = preload("./extensions/JSONStatistics.gd")
const MarkdownStatistics: Script = preload("./extensions/MarkdownStatistics.gd")
const ResourceStatistics: Script = preload("./extensions/ResourceStatistics.gd")
const YAMLStatistics: Script = preload("./extensions/YAMLStatistics.gd")

var directories: PoolStringArray

var scenes: Array
var resources: Array
var scripts: Array
var misc: Array

func load(root: String = "res://") -> int:
	var directory: Directory = Directory.new()
	var error: int = directory.open(root)
	if error != OK:
		return error
	
	directory.list_dir_begin(true, true)
	var file_name: String = directory.get_next()
	while not file_name.empty():
		var current_path: String = directory.get_current_dir().plus_file(file_name)
		if path_force_included(current_path) or not path_ignored(current_path):
			if directory.current_is_dir():
				directories.append(current_path)
				self.load(current_path)
			else:
				var file_stats: FileStatistics = get_file_loader(current_path)
				if file_stats.load(current_path) == OK:
					if file_stats.is_scene():
						scenes.append(file_stats)
					elif file_stats.is_script():
						scripts.append(file_stats)
					elif file_stats.is_resource():
						resources.append(file_stats)
					else:
						misc.append(file_stats)
		file_name = directory.get_next()
	directory.list_dir_end()
	
	return OK

func get_used_langauges() -> PoolStringArray:
	var languages: PoolStringArray = []
	for file_stats in scripts:
		var extension: String = file_stats.get_extension()
		if not file_stats.get_extension() in languages:
			languages.append(extension)
	return languages

func get_total_lines(of_scripts: bool = true) -> int:
	var source: Array = scripts if of_scripts else misc
	var total: int
	for file_stats in source:
		total += file_stats.total_lines
	return total

func get_total_code_lines(of_scripts: bool = true) -> int:
	var source: Array = scripts if of_scripts else misc
	var total: int
	for file_stats in source:
		total += file_stats.source_code_lines
	return total

func get_total_comment_lines(of_scripts: bool = true) -> int:
	var source: Array = scripts if of_scripts else misc
	var total: int
	for file_stats in source:
		total += file_stats.comment_lines
	return total

func get_total_blank_lines(of_scripts: bool = true) -> int:
	var source: Array = scripts if of_scripts else misc
	var total: int
	for file_stats in source:
		total += file_stats.blank_lines
	return total

func get_total_nodes() -> int:
	var total: int
	for file_stats in scenes:
		total += file_stats.node_count
	return total

func get_total_connections() -> int:
	var total: int
	for file_stats in scenes:
		total += file_stats.connection_count
	return total

func get_total_scenes_size() -> int:
	var total: int
	for file_stats in scenes:
		total += file_stats.size
	return total

func get_total_scripts_size() -> int:
	var total: int
	for file_stats in scripts:
		total += file_stats.size
	return total

func get_other_files_size() -> int:
	var total: int
	for file_stats in misc:
		total += file_stats.size
	return total

func get_file_loader(file_path: String) -> FileStatistics:
	match file_path.get_extension().to_lower():
		"cs":
			return CSharpStatistics.new()
		"gd":
			return GDScriptStatistics.new()
		"md":
			return MarkdownStatistics.new()
		"json":
			return JSONStatistics.new()
		"yml", "yaml":
			return YAMLStatistics.new()
		
	return ResourceStatistics.new()

func duplicate():
	var clone = get_script().new()
	clone.directories = directories
	clone.scenes = scenes.duplicate()
	clone.resources = resources.duplicate()
	clone.scripts = scripts.duplicate()
	clone.misc = misc.duplicate()
	return clone

static func is_path_ignored(path: String) -> bool:
	if not Engine.editor_hint:
		return false
	var ignores: PoolStringArray = ProjectSettings.get_setting("statistics/ignore")
	for expression in ignores:
		if path.matchn(expression):
			return true
	return false

static func path_ignored(path: String) -> bool:
	if not Engine.editor_hint:
		return false
	var expressions: PoolStringArray = ProjectSettings.get_setting("statistics/ignore")
	for expression in expressions:
		if path.matchn(expression):
			return true
	return false

static func path_force_included(path: String) -> bool:
	if not Engine.editor_hint:
		return false
	var expressions: PoolStringArray = ProjectSettings.get_setting("statistics/force_include")
	for expression in expressions:
		if path.matchn(expression):
			return true
	return false
