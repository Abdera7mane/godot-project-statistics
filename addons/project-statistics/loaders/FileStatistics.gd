var path: String
var size: int
var total_lines: int
var source_code_lines: int
var comment_lines: int
var blank_lines: int

func load(at_path: String) -> int:
	return _load_file_info(at_path)

func _load_file_info(at_path: String, skip_line_count: bool = false) -> int:
	var file: File = File.new()
	var error: int = file.open(at_path, File.READ)
	if error != OK:
		return error
	
	path = at_path
	size = file.get_len()
	
	total_lines = 0
	source_code_lines = 0
	comment_lines = 0
	blank_lines = 0
	
	if skip_line_count:
		return OK
	
	while not file.eof_reached():
		var line: String = file.get_line()
		
		if is_comment(line):
			comment_lines += 1
		elif is_blank(line):
			blank_lines += 1
		else:
			source_code_lines += 1
		total_lines +=1
	
	file.close()
	return OK

func get_name() -> String:
	return path.get_file()

func get_extension() -> String:
	return path.get_extension()

func get_icon() -> String:
	return ""

func get_color() -> Color:
	return Color.transparent

func is_comment(line: String) -> bool:
	return false

func is_blank(line: String) -> bool:
	return line.strip_edges().empty()

func is_script() -> bool:
	return false

func is_scene() -> bool:
	return false

func is_resource() -> bool:
	return false
