extends Control
class_name SettingsUIContent

signal started

@onready var hand_interactions_control: Control = $Control/HandInteractionsControl
@onready var continue_button: Button = $Control/HandInteractionsControl/ContinueButton

@onready var steps_control: Control = $Control/StepsControl
@onready var start_button: Button = $Control/StepsControl/StartButton

@onready var instructions_control: Control = $Control/InstructionsControl
@onready var instructions_label: RichTextLabel = $Control/InstructionsControl/VBoxContainer/InstructionsLabel
@onready var restart_button: Button = $Control/InstructionsControl/RestartButton


func _ready() -> void:
	continue_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	start_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	restart_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	
	continue_button.pressed.connect(_on_continue_pressed)
	start_button.pressed.connect(_on_start_pressed)
	restart_button.pressed.connect(_on_restart_pressed)


func set_instructions(text: String) -> void:
	instructions_label.text = text


func _on_continue_pressed() -> void:
	hand_interactions_control.set_visible(false)
	steps_control.set_visible(true)


func _on_start_pressed() -> void:
	steps_control.set_visible(false)
	instructions_control.set_visible(true)
	started.emit()


func _on_restart_pressed() -> void:
	call_deferred("_reload_scene")


func _reload_scene() -> void:
	get_tree().reload_current_scene()
