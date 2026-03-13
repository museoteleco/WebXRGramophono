@tool
extends XRToolsSnapZone
class_name CrankSnapZone

@export var highlight: MeshInstance3D


func set_active(value: bool) -> void:
	self.enabled = value
	highlight.visible = value


func set_highlight_visible(value: bool) -> void:
	highlight.visible = value

# You have to make the children editable in the parent node 
# and  highlight material unique in the editor
# for the following function to work
func set_highlight_color(color: Color) -> void:
	# Modify alpha channel so the highlight is better visible
	color.a = 0.9
	
	var mat := highlight.get_surface_override_material(0)
	
	if mat is StandardMaterial3D:
		mat.albedo_color = color
