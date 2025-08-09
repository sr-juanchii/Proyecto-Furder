extends CharacterBody2D

# Referencia al nodo Sprite2D para voltear el personaje según la dirección
@onready var PlayerSprite: Sprite2D = $PlayerCollision/PlayerSprite
# Referencia al AnimationTree para controlar las animaciones mediante estados
@onready var anim_tree: AnimationTree = $PlayerAnimator/PlayerAnimationTree

# Definición de los posibles estados del personaje para el control de animaciones y lógica
enum State { IDLE, WALK, RUN, JUMP, FALL, LAND }
var state: State = State.IDLE # Estado actual del personaje

# Constantes para controlar la física y el movimiento del personaje
const SPEED = 300.0           # Velocidad máxima horizontal al caminar
const RUN_SPEED = 500.0       # Velocidad máxima horizontal al correr
const ACCELERATION = 1200.0   # Qué tan rápido acelera el personaje
const FRICTION = 800.0        # Qué tan rápido se detiene el personaje
const JUMP_VELOCITY = -400.0  # Velocidad inicial del salto (negativo porque el eje Y apunta hacia abajo)

# Devuelve la velocidad máxima dependiendo si el jugador está corriendo o caminando
func get_max_speed() -> float:
	# Si la acción "run" está presionada, retorna la velocidad de correr, si no, la de caminar
	return RUN_SPEED if Input.is_action_pressed("run") else SPEED

# Función principal de física, se ejecuta en cada frame de física
func _physics_process(delta: float) -> void:
	# Aplica gravedad si el personaje no está en el suelo
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Permite saltar si el jugador presiona el botón de salto y está en el suelo
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Obtiene la dirección de entrada horizontal (-1 para izquierda, 1 para derecha, 0 sin movimiento)
	var direction := Input.get_axis("moveLeft", "moveRight")
	
	# Movimiento horizontal con aceleración y fricción
	if direction != 0:
		# Acelera hacia la dirección deseada, usando la velocidad máxima según si corre o camina
		velocity.x = move_toward(velocity.x, direction * get_max_speed(), ACCELERATION * delta)
		# Voltea el sprite horizontalmente si va a la izquierda
		PlayerSprite.flip_h = direction < 0
	else:
		# Aplica fricción para detener suavemente al personaje
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# Mueve al personaje y maneja colisiones
	move_and_slide()
	# Actualiza el estado lógico del personaje según su movimiento y entorno
	update_state(direction)
	# Actualiza la animación en el AnimationTree según el estado actual
	update_animation_state()

# Determina el estado actual del personaje según su movimiento y entorno
func update_state(_direction: float) -> void:
	# Si acaba de aterrizar después de saltar o caer, cambia a estado LAND
	if is_on_floor() and state in [State.FALL, State.JUMP]:
		state = State.LAND
	# Si está en el aire, determina si está subiendo (JUMP) o bajando (FALL)
	elif not is_on_floor():
		state = State.JUMP if velocity.y < 0 else State.FALL
	# Si se está moviendo horizontalmente, determina si está corriendo o caminando
	elif abs(velocity.x) > 10:
		if Input.is_action_pressed("run"):
			state = State.RUN
		else:
			state = State.WALK
	# Si no se mueve, está en reposo (IDLE)
	else:
		state = State.IDLE

# Cambia la animación del AnimationTree según el estado actual del personaje
func update_animation_state():
	match state:
		State.IDLE:
			# Cambia a la animación Idle
			anim_tree["parameters/playback"].travel("Idle")
		State.WALK:
			# Cambia a la animación Walk
			anim_tree["parameters/playback"].travel("Walk")
		State.RUN:
			# Cambia a la animación Run
			anim_tree["parameters/playback"].travel("Run")
		State.JUMP:
			# Cambia a la animación Jump
			anim_tree["parameters/playback"].travel("Jump")
		State.FALL:
			# Cambia a la animación Fall
			anim_tree["parameters/playback"].travel("Fall")
		State.LAND:
			# Cambia a la animación Land
			anim_tree["parameters/playback"].travel("Land")
