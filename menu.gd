extends Control

@onready var lit_background: TextureRect = %LitBackground
@onready var menu_layer: Control = %MenuLayer
@onready var prototype_label: Label = $MenuLayer/Buttons/PrototypeLabel
@onready var start_button: Button = %StartButton
@onready var language_button: Button = %LanguageButton
@onready var quit_button: Button = %QuitButton
@onready var switch_player: AudioStreamPlayer = %SwitchPlayer


func _ready() -> void:
	lit_background.visible = false
	menu_layer.modulate.a = 0.0
	start_button.disabled = true
	language_button.disabled = true
	quit_button.disabled = true
	start_button.pressed.connect(_start_game)
	language_button.pressed.connect(_toggle_language)
	quit_button.pressed.connect(_quit_game)
	_refresh_text()
	_play_opening()


func _play_opening() -> void:
	await get_tree().create_timer(0.38).timeout
	MusicManager.play_music()
	switch_player.play()
	await get_tree().create_timer(1.02).timeout
	lit_background.visible = true
	await get_tree().create_timer(0.07).timeout
	lit_background.visible = false
	await get_tree().create_timer(0.74).timeout
	lit_background.visible = true
	await get_tree().create_timer(0.22).timeout
	var menu_tween := create_tween()
	menu_tween.tween_property(menu_layer, "modulate:a", 1.0, 0.42)
	await menu_tween.finished
	start_button.disabled = false
	language_button.disabled = false
	quit_button.disabled = false


func _refresh_text() -> void:
	prototype_label.text = Locale.text("menu_prototype")
	start_button.text = Locale.text("menu_start")
	language_button.text = Locale.text("menu_language")
	quit_button.text = Locale.text("menu_quit")


func _toggle_language() -> void:
	Locale.toggle_language()
	_refresh_text()


func _start_game() -> void:
	start_button.disabled = true
	language_button.disabled = true
	quit_button.disabled = true
	var fade := create_tween()
	fade.tween_property(self, "modulate:a", 0.0, 0.28)
	await fade.finished
	GameState.current_station = "counter"
	get_tree().change_scene_to_file("res://service_counter.tscn")


func _quit_game() -> void:
	get_tree().quit()
