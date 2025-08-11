extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$AudioStreamPlayer.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/2D/Apartment.tscn")


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_quit_game_pressed() -> void:
	get_tree().quit() # Replace with function body.
