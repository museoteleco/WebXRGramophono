extends Node3D
class_name FilterSystem

signal picked_up
signal mounted
signal stashed

@export var filter: Filter
@export var mounted_filter_snap_zone: FilterSnapZone
@export var stashed_filter_snap_zone: FilterSnapZone


func _ready() -> void:
	# Start with the filter stashed
	filter.set_interactable(true)
	stashed_filter_snap_zone.set_active(true)
	stashed_filter_snap_zone.pick_up_object(filter)
	stashed_filter_snap_zone.set_active(false)
	filter.set_interactable(false)
	
	mounted_filter_snap_zone.has_picked_up.connect(_on_mounted)
	stashed_filter_snap_zone.has_picked_up.connect(_on_stashed)
	mounted_filter_snap_zone.has_dropped.connect(_on_dropped)
	stashed_filter_snap_zone.has_dropped.connect(_on_dropped)


func set_active(value: bool) -> void:
	filter.set_interactable(value)
	mounted_filter_snap_zone.set_active(value)
	stashed_filter_snap_zone.set_active(value)


func show_pickup_hint(color: Color) -> void:
	filter.set_interactable(true)
	filter.set_outline_shader_params(color, 1.5)


func hide_hint() -> void:
	filter.set_interactable(false)


func _on_dropped() -> void:
	picked_up.emit()


func _on_mounted(_what: Variant) -> void:
	mounted.emit()


func _on_stashed(_what: Variant) -> void:
	stashed.emit()
