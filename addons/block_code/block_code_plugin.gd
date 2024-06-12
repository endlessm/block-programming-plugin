@tool
class_name BlockCodePlugin
extends EditorPlugin

const MainPanel := preload("res://addons/block_code/ui/main_panel.tscn")
static var main_panel

var script_ok_button: Button
var script_ok_prev_connection: Dictionary
var prev_opened_script_idx: int

var old_feature_profile: String = ""


func _enter_tree():
	main_panel = MainPanel.instantiate()
	main_panel.undo_redo = get_undo_redo()

	# Add the main panel to the editor's main viewport.
	EditorInterface.get_editor_main_screen().add_child(main_panel)
	# Hide the main panel. Very much required.
	_make_visible(false)

	# Add signal manager for block code nodes to access
	add_autoload_singleton("SignalManager", "res://addons/block_code/block_code_node/utilities/signal_manager.gd")

	# Remove unwanted class nodes from create node
	var remove_list := [
		"BlockScriptData",
		"DragManager",
		"InstructionTree",
		"EditorInterfaceAccess",
		"SimpleCharacter",
		"Types",
		"EntryBlock",
		"Block",
		"ControlBlock",
		"ParameterBlock",
		"StatementBlock",
		"DragDropArea",
		"SnapPoint",
		"NodeBlockCanvas",
		"SerializedBlockTreeNodeArray",
		"SerializedBlockTreeNode",
		"SerializedBlock",
		"PackedSceneTreeNodeArray",
		"PackedSceneTreeNode",
		"BlockCanvas",
		"NodeCanvas",
		"NodeClass",
		"NodeClassList",
		"NodeData",
		"NodePreview",
		"NodeList",
		"CategoryFactory",
		"BlockCategoryDisplay",
		"BlockCategory",
		"Picker",
		"TitleBar",
		"MainPanel",
		"BlockCodePlugin"
	]

	old_feature_profile = EditorInterface.get_current_feature_profile()

	var editor_paths: EditorPaths = EditorInterface.get_editor_paths()
	if editor_paths:
		var config_dir := editor_paths.get_config_dir()
		var new_profile := EditorFeatureProfile.new()
		new_profile.load_from_file(config_dir + "/feature_profiles/" + old_feature_profile + ".profile")
		for _class_name in remove_list:
			new_profile.set_disable_class(_class_name, true)

		var dir = config_dir + "/feature_profiles/block_code.profile"
		DirAccess.remove_absolute(dir)
		new_profile.save_to_file(dir)
		EditorInterface.set_current_feature_profile("block_code")


func _exit_tree():
	if main_panel:
		main_panel.queue_free()

	remove_autoload_singleton("SignalManager")

	var editor_paths: EditorPaths = EditorInterface.get_editor_paths()
	if editor_paths:
		var config_dir := editor_paths.get_config_dir()
		if old_feature_profile == "" or FileAccess.file_exists(config_dir + "/feature_profiles/" + old_feature_profile + ".profile"):
			EditorInterface.set_current_feature_profile(old_feature_profile)
		else:
			print("Old feature profile was removed and cannot be reverted to. Reverting to default.")
			EditorInterface.set_current_feature_profile("")


func _reconnect_signal(_signal: Signal, _data: Dictionary):
	_signal.connect(_data.callable, _data.flags)


func _has_main_screen():
	return true


func _make_visible(visible):
	if main_panel:
		main_panel.visible = visible


func _get_plugin_name():
	return "Block Code"


func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
