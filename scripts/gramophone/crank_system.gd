extends Node3D
class_name CrankSystem

signal crank_inserted
signal crank_stashed
signal crank_cranked
signal crank_picked_up

enum Expectation { NONE, PICK_UP, INSERT_OR_STASH, CRANK }
var expectation: Expectation = Expectation.NONE

@export var crank_pickable: CrankPickable
@export var inserted_crank_snap_zone: CrankSnapZone
@export var stashed_crank_snap_zone: CrankSnapZone


func _ready() -> void:
	crank_pickable.set_interactable(true)
	stashed_crank_snap_zone.set_active(true)
	stashed_crank_snap_zone.pick_up_object(crank_pickable)
	stashed_crank_snap_zone.set_active(false)
	crank_pickable.set_interactable(false)
	
	inserted_crank_snap_zone.has_picked_up.connect(_on_inserted_snap_zone_has_picked_up)
	stashed_crank_snap_zone.has_picked_up.connect(_on_stashed_snap_zone_has_picked_up)
	
	inserted_crank_snap_zone.has_dropped.connect(_on_snap_zone_has_dropped)
	stashed_crank_snap_zone.has_dropped.connect(_on_snap_zone_has_dropped)
	
	expect_none()


func expect_none() -> void:
	expectation = Expectation.NONE
	
	crank_pickable.set_interactable(false)
	inserted_crank_snap_zone.set_active(false)
	stashed_crank_snap_zone.set_active(false)


func expect_pick_up() -> void:
	expectation = Expectation.PICK_UP
	
	crank_pickable.set_interactable(true)
	
	# Only enable the snap zone that currently holds the crank
	if inserted_crank_snap_zone.picked_up_object:
		inserted_crank_snap_zone.set_active(true)
		inserted_crank_snap_zone.set_highlight_color(Color(1, 0.7, 0))
		crank_pickable.set_highlight_color(Color(1,0,0), 1.0)
	elif stashed_crank_snap_zone.picked_up_object:
		stashed_crank_snap_zone.set_active(true)
		stashed_crank_snap_zone.set_highlight_color(Color(0, 1, 0))
		crank_pickable.set_highlight_color(Color(0,1,0), 2.0)


func expect_insert_or_stash() -> void:
	expectation = Expectation.INSERT_OR_STASH
	
	crank_pickable.set_interactable(true)
	
	inserted_crank_snap_zone.set_highlight_color(Color(0, 1, 0))
	inserted_crank_snap_zone.set_active(true)
	stashed_crank_snap_zone.set_highlight_color(Color(1, 0.7, 0))
	stashed_crank_snap_zone.set_active(true)


func expect_cranking() -> void:
	expectation = Expectation.CRANK
	
	expect_none()
	crank_cranked.emit()


func _set_active(value: bool) -> void:
	match expectation:
		Expectation.INSERT_OR_STASH:
			inserted_crank_snap_zone.set_active(value)
			stashed_crank_snap_zone.set_active(value)
			crank_pickable.set_interactable(value)

		Expectation.PICK_UP:
			crank_pickable.set_interactable(value)
			inserted_crank_snap_zone.set_active(value)
			stashed_crank_snap_zone.set_active(value)

		Expectation.NONE:
			inserted_crank_snap_zone.set_active(false)
			stashed_crank_snap_zone.set_active(false)
			crank_pickable.set_interactable(false)


func _on_inserted_snap_zone_has_picked_up(_what: Variant) -> void:
	if expectation != Expectation.INSERT_OR_STASH:
		return
	expect_none()
	crank_inserted.emit()


func _on_stashed_snap_zone_has_picked_up(_what: Variant) -> void:
	if expectation != Expectation.INSERT_OR_STASH:
		return
	expect_none()
	crank_stashed.emit()


func _on_snap_zone_has_dropped() -> void:
	if expectation != Expectation.PICK_UP:
		return
	
	if inserted_crank_snap_zone.picked_up_object == null \
	and stashed_crank_snap_zone.picked_up_object == null:
		expect_none()
		crank_picked_up.emit()


func _on_hinge_moved(angle: float) -> void:
	if expectation == Expectation.CRANK and angle <= -900.0:
		expect_none()
		crank_cranked.emit()
