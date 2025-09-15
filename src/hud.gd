extends CanvasLayer

func _on_player_timeslow_tick(percentage_left: float):
	find_child("ProgressBar").value = percentage_left
