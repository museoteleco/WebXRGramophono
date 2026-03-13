@tool
extends XRToolsPickable
class_name Filter

@export var outline: MeshInstance3D


func set_interactable(value: bool) -> void:
	self.enabled = value
	outline.visible = value


func set_outline_shader_color(color: Color) -> void:
	var mat := outline.get_surface_override_material(0)
	
	if mat is ShaderMaterial:
		mat.set_shader_parameter("shell_color", color)
