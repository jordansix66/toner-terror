extends AudioStreamPlayer

var background_music: AudioStreamMP3 = preload("res://audio/talk-about-it-instrumental.mp3")


func _ready() -> void:
	background_music.loop = true
	stream = background_music
	volume_db = 0.0
	await get_tree().create_timer(0.38).timeout
	play_music()


func play_music() -> void:
	if not playing:
		play()
