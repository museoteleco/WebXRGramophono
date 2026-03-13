extends Node3D
class_name GramophoneVinylSystem

signal vinyl_picked_up
signal vinyl_mounted
signal vinyl_stashed

enum Expectation { NONE, MOUNT_OR_STASH, PICK_UP }
var expectation: Expectation = Expectation.NONE
var mounted_vinyl: Vinyl = null

@export var vinyls: Array[Vinyl]
@export var mounted_snap_zone: VinylSnapZone
@export var stashed_snap_zones: Array[VinylSnapZone]


func _ready() -> void:
	for i in range(vinyls.size()):
		vinyls[i].enabled = true
		stashed_snap_zones[i].set_active(true)
		stashed_snap_zones[i].pick_up_object(vinyls[i])
		stashed_snap_zones[i].set_active(false)
		vinyls[i].enabled = false
	
	mounted_snap_zone.has_picked_up.connect(_on_mounted_snap_zone_has_picked_up)
	mounted_snap_zone.has_dropped.connect(_on_snap_zone_has_dropped)
	
	for stashed_snap_zone in stashed_snap_zones:
		stashed_snap_zone.has_picked_up.connect(_on_stashed_snap_zone_has_picked_up)
		stashed_snap_zone.has_dropped.connect(_on_snap_zone_has_dropped)
	
	reset()

func reset() -> void:
	expectation = Expectation.NONE
	_set_active(false)

func expect_pick_up(value: bool = true) -> void:
	expectation = Expectation.PICK_UP if value else Expectation.NONE
	
	for vinyl in vinyls:
		vinyl.enabled = value
	if mounted_snap_zone.picked_up_object:
		mounted_snap_zone.activated = value
		mounted_snap_zone.set_highlight_color(Color(1,0.7,0))
	else:
		for stashed_snap_zone in stashed_snap_zones:
			stashed_snap_zone.activated = value
			stashed_snap_zone.set_highlight_color(Color(0,1,0))


func expect_mount_or_stash(value: bool = true) -> void:
	expectation = Expectation.MOUNT_OR_STASH if value else Expectation.NONE
	
	mounted_snap_zone.set_highlight_color(Color(0,1,0))
	for stashed_snap_zone in stashed_snap_zones:
		stashed_snap_zone.set_highlight_color(Color(1,0.7,0))
	
	# Only for the picked up vinyl
	_set_active(value)


func _set_active(value: bool) -> void:
	for vinyl in vinyls:
		vinyl.enabled = value
	mounted_snap_zone.set_active(value)
	for stashed_snap_zone in stashed_snap_zones:
		stashed_snap_zone.set_active(value)


func _on_mounted_snap_zone_has_picked_up(_vinyl: Vinyl) -> void:
	if expectation != Expectation.MOUNT_OR_STASH:
		return
	reset()
	
	#TODO: Bad logic, because we should also unbind this when vinyl get removed from the turntable
	mounted_vinyl = _vinyl
	
	vinyl_mounted.emit()


func _on_stashed_snap_zone_has_picked_up(_vinyl: Vinyl) -> void:
	if expectation != Expectation.MOUNT_OR_STASH:
		return
	reset()
	
	vinyl_stashed.emit()


func _on_snap_zone_has_dropped() -> void:
	if expectation != Expectation.PICK_UP:
		return
	reset()
	vinyl_picked_up.emit()
