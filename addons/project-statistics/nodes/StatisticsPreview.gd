tool
extends Control

const ProjectStatistics: Script = preload("../loaders/ProjectStatistics.gd")

var editor_interface: EditorInterface

onready var overview: Control = $VSplitContainer/ScrollContainer/MarginContainer/TabContainer/Overview
onready var scenes_view: Control = $VSplitContainer/ScrollContainer/MarginContainer/TabContainer/Scenes
onready var resources_view: Control = $VSplitContainer/ScrollContainer/MarginContainer/TabContainer/Resources
onready var scripts_view: Control = $VSplitContainer/ScrollContainer/MarginContainer/TabContainer/Scripts
onready var misc_view: Control = $VSplitContainer/ScrollContainer/MarginContainer/TabContainer/Misc

func _on_refresh_pressed() -> void:
	var stats: ProjectStatistics = ProjectStatistics.new()
	stats.load()
	
	overview.display(stats)
	scenes_view.display(stats)
	resources_view.display(stats)
	scripts_view.display(stats)
	misc_view.display(stats)

func _on_file_selected(path: String) -> void:
	if Engine.editor_hint:
		editor_interface.select_file(path)
		if not ResourceLoader.exists(path):
			return
		var resource: Resource = ResourceLoader.load(path)
		if resource:
			if resource is PackedScene:
				editor_interface.open_scene_from_path(path)
			else:
				editor_interface.edit_resource(resource)
