@tool
extends XRToolsPickable
class_name Vinyl

enum VinylSide { A, B }

@onready var snap_pivot: Node3D = $SnapPivot

@export var outline: MeshInstance3D
@export var _song_a: Song
@export var _song_b: Song

var side: VinylSide = VinylSide.A
var song: Song:
	get:
		return _song_a if side == VinylSide.A else _song_b


func set_interactable(value: bool) -> void:
	self.enabled = value
	outline.visible = value


func set_outline_shader_color(color: Color) -> void:
	var mat := outline.get_surface_override_material(0)
	
	if mat is ShaderMaterial:
		mat.set_shader_parameter("shell_color", color)


# Updates which side is facing up based on world orientation
func update_side_before_snapping() -> void:
	if not is_instance_valid(snap_pivot):
		return
	
	# Use pivot's world up for determining side
	var vinyl_up: Vector3 = snap_pivot.global_transform.basis.y
	var dot := vinyl_up.dot(Vector3.UP)
	side = VinylSide.A if dot > 0.0 else VinylSide.B


func pick_up(by: Node3D) -> void:
	if by is VinylSnapZone:
		update_side_before_snapping()           # Read side before snapping
		super.pick_up(by)
		call_deferred("_apply_snap_orientation") # Apply snap orientation after positioning
	else:
		super.pick_up(by)


func _apply_snap_orientation() -> void:
	if not is_instance_valid(snap_pivot):
		return
	
	# Reset pivot to default
	snap_pivot.basis = Basis.IDENTITY
	
	# Rotate around Z axis for B-side
	if side == VinylSide.B:
		snap_pivot.rotate(Vector3(0, 0, 1), PI)
