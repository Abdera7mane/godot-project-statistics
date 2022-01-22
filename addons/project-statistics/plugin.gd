tool
extends EditorPlugin

const StatisticsPreview: PackedScene = preload("./nodes/StatisticsPreview.tscn")

const IGNORE_PROPERTY: String = "statistics/ignore"
const FORCE_INCLUDE_PROPERTY: String = "statistics/force_include"

const DEFAULT_IGNORE: PoolStringArray = PoolStringArray([
	"res://.import/*",
	"res://.github/*",
	"res://addons/*",
	"*.import"
])

var preview: Control

func _enter_tree() -> void:
	preview = StatisticsPreview.instance()
	preview.editor_interface = get_editor_interface()
	add_control_to_bottom_panel(preview, "Statistics")
	_setup()

func _exit_tree() -> void:
	remove_control_from_bottom_panel(preview)
	preview.editor_interface = null

func _setup() -> void:
	if not ProjectSettings.has_setting(IGNORE_PROPERTY):
		ProjectSettings.set_setting(IGNORE_PROPERTY, DEFAULT_IGNORE)
		ProjectSettings.add_property_info({
			name = IGNORE_PROPERTY,
			type = TYPE_STRING_ARRAY
		})
		ProjectSettings.set_initial_value(IGNORE_PROPERTY, DEFAULT_IGNORE)
	
	if not ProjectSettings.has_setting(FORCE_INCLUDE_PROPERTY):
		ProjectSettings.set_setting(FORCE_INCLUDE_PROPERTY, PoolStringArray())
		ProjectSettings.add_property_info({
			name = FORCE_INCLUDE_PROPERTY,
			type = TYPE_STRING_ARRAY
		})
