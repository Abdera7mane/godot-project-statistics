extends "../FileStatistics.gd"

var local_to_scene: bool
var type: String
var base_node_type: String
var node_count: int
var connection_count: int

func load(at_path: String) -> int:
	if ResourceLoader.exists(at_path):
		var resource: Resource = ResourceLoader.load(at_path)
		if resource:
			_load_file_info(at_path, true)
			_load_resource(resource)
			return OK
	return ERR_CANT_ACQUIRE_RESOURCE

func _load_resource(resource: Resource) -> void:
	local_to_scene = resource.resource_local_to_scene
	type = resource.get_class()
	if resource is PackedScene:
		var scene: PackedScene = resource as PackedScene
		var state: SceneState = scene.get_state()
		base_node_type = state.get_node_type(0)
		node_count = state.get_node_count()
		connection_count = state.get_connection_count()

func get_extension() -> String:
	return type

func get_icon() -> String:
	return type

func get_color() -> Color:
	if type == "VisualScript":
		return Color.azure
	var color = Color(hash(type)).inverted()
	color.a = 1.0
	return color

func is_scene() -> bool:
	return ClassDB.is_parent_class(type, "PackedScene")

func is_script() -> bool:
	return ClassDB.is_parent_class(type, "Script")

func is_resource() -> bool:
	return true
