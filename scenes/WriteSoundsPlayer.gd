extends AnimationPlayer


func play_sound():
	var stream_players : Array = get_children().duplicate()
	stream_players.shuffle()
	var stream_player : AudioStreamPlayer = stream_players.pop_front()
	while (stream_player.playing):
		stream_player = stream_players.pop_front()
	stream_player.play()
