extends Control

@onready var station_title: Label = %StationTitle
@onready var station_description: Label = %StationDescription
@onready var development_label: Label = %DevelopmentLabel
@onready var exit_button: Button = %ExitStationButton
@onready var exit_hint: Label = %ExitHint


func _ready() -> void:
	exit_button.pressed.connect(_exit_station)
	_refresh_text()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		get_viewport().set_input_as_handled()
		_exit_station()


func _refresh_text() -> void:
	station_title.text = Locale.station_name(GameState.current_station)
	station_description.text = Locale.station_description(GameState.current_station)
	development_label.text = Locale.text("station_in_development")
	exit_button.text = Locale.text("station_exit")
	exit_hint.text = Locale.text("station_exit_hint")


func _exit_station() -> void:
	get_tree().change_scene_to_file("res://station_select.tscn")
