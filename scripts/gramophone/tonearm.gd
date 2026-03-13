extends Node3D
class_name Tonearm

signal mounted
signal stashed

@export var outline: MeshInstance3D
@export var animation_player: AnimationPlayer
@export var interactable_hinge: XRToolsInteractableHinge
@export var interactable_handle: XRToolsInteractableHandle

var _is_animation_playing: bool = false


func _ready():
	interactable_hinge.hinge_moved.connect(_on_hinge_moved)


func set_interactable(value: bool) -> void:
	interactable_handle.enabled = value
	outline.visible = value


func set_outline_shader_color(color: Color) -> void:
	if not outline:
		return
	
	var mat3 := outline.get_surface_override_material(3)
	if mat3 is ShaderMaterial:
		mat3.set_shader_parameter("shell_color", color)


func play_animation(animation_name: String) -> void:
	_is_animation_playing = true
	set_interactable(false)
	
	animation_player.play(animation_name)
	await animation_player.animation_finished
	
	set_interactable(true)
	_is_animation_playing = false


func _on_hinge_moved(angle: float):
	if _is_animation_playing:
		return
		
	if angle <= -35.0:
		mounted.emit()
		
	elif angle >= -20.0:
		stashed.emit()
