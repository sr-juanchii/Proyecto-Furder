extends Area2D

var Player_is_in:bool

@export_file("*.tscn") var ThisDoorGoTo: String
@export var Elevator_Animation:AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Player_is_in = true	
		Elevator_Animation.play("openelevator")
		print(Player_is_in)
	


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Player_is_in = false	
		Elevator_Animation.play("closedelevator")
		print(Player_is_in)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interaction") and Player_is_in == true:
		print("teleport")
		get_tree().change_scene_to_file(ThisDoorGoTo)
