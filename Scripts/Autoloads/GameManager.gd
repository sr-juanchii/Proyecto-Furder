extends Node

var pause_menu: Node = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not pause_menu:
		var pause_menu_scene = preload("res://UI/Menu/PauseMenu.tscn") # Ajusta la ruta a tu escena real
		pause_menu = pause_menu_scene.instantiate()
		pause_menu.visible = false
		pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().root.call_deferred("add_child", pause_menu)

func _input(event):
	if event.is_action_pressed("pause"):
		var scena_actual: = get_tree().current_scene 
		if scena_actual and scena_actual.is_in_group("isPausable"):
			toggle_pause()

func toggle_pause():
	get_tree().paused = not get_tree().paused
	if pause_menu:
		pause_menu.visible = get_tree().paused
		# Opcional: mostrar el mouse solo en pausa
		if get_tree().paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Llama esto desde el botón "Continuar" del menú de pausa
func _on_continue_button_pressed():
	toggle_pause()

# Llama esto desde el botón "Salir" del menú de pausa
func _on_quit_button_pressed():
	get_tree().quit()
