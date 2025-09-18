extends CanvasLayer

var dashContainer:HBoxContainer = null;
var dashPointers = {};

func _ready() -> void:
	dashContainer = find_child("DashContainer");

func _on_player_timeslow_tick(percentage_left: float):
	find_child("Timeslow").value = percentage_left
	
func _on_player_setup(dashes: int) -> void:
	var dashBar:ProgressBar = null;
	for i in dashes:
		dashBar = ProgressBar.new();
		dashBar.show_percentage = false;
		dashBar.max_value = 1.0;
		dashBar.step = 1.0;
		dashBar.value = 1.0;
		dashBar.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN;
		dashBar.custom_minimum_size = Vector2(50,30);
		dashBar.name = "Dash"+str(i);
		dashBar.modulate = Color("00249c");
		dashContainer.add_child(dashBar);
		dashPointers.set(i, dashBar)

func _on_player_dash(dashes_left: int):
	dashPointers[dashes_left].value = abs(dashPointers[dashes_left].value - 1);
