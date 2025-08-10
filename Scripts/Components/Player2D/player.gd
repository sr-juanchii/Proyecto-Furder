extends CharacterBody2D


@onready var PlayerSprite: Sprite2D = $PlayerCollision/PlayerSprite # Referencia al nodo Sprite2D para voltear el personaje según la dirección
@onready var anim_tree: AnimationTree = $PlayerAnimator/PlayerAnimationTree # Referencia al AnimationTree para controlar las animaciones mediante estados

# Definición de los posibles estados del personaje para el control de animaciones y lógica
enum State { IDLE, WALK, RUN, JUMP, FALL, LAND, FALLEN }
var state: State = State.IDLE # Estado actual del personaje

# Constantes para controlar la física y el movimiento del personaje
const SPEED = 150.0           # Velocidad máxima horizontal al caminar
const RUN_SPEED = 450.0       # Velocidad máxima horizontal al correr
const ACCELERATION = 800.0   # Qué tan rápido acelera el personaje
const FRICTION = 2000.0       # Qué tan rápido se detiene el personaje
const JUMP_VELOCITY = -400.0  # Velocidad inicial del salto (negativo porque el eje Y apunta hacia abajo)
const FALLEN_DURATION = 1.0    # Segundos que dura caído
const FALLEN_SLIDE_DECAY = 1200.0 # Qué tan rápido se detiene el deslizamiento al caer

var run_time: float = 0.0
var fallen_timer: float = 0.0
var fallen_slide_velocity: float = 0.0

# Devuelve la velocidad máxima dependiendo si el jugador está corriendo o caminando
func get_max_speed() -> float:
	# Si la acción "run" está presionada, retorna la velocidad de correr, si no, la de caminar
	return RUN_SPEED if Input.is_action_pressed("run") else SPEED

# Función principal de física, se ejecuta en cada frame de física
func _physics_process(delta: float) -> void:
	if state == State.FALLEN:
		# Mientras está caído, deslízate en la dirección de la caída y desacelera poco a poco
		if abs(fallen_slide_velocity) > 10:
			fallen_slide_velocity = move_toward(fallen_slide_velocity, 0, FALLEN_SLIDE_DECAY * delta)
		else:
			fallen_slide_velocity = 0
		velocity.x = fallen_slide_velocity
		velocity.y += get_gravity().y * delta
		move_and_slide()
		fallen_timer -= delta
		if fallen_timer <= 0:
			state = State.IDLE
		return # No permitir movimiento mientras está caído

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
		if sign(direction) != sign(velocity.x) and abs(velocity.x) > 10:
			# Aplica fricción extra al cambiar de dirección
			velocity.x = move_toward(velocity.x, 0, (FRICTION * 2) * delta)
		velocity.x = move_toward(velocity.x, direction * get_max_speed(), ACCELERATION * delta)
		PlayerSprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# Mueve al personaje y maneja colisiones
	move_and_slide()
	# Actualiza el estado lógico del personaje según su movimiento y entorno
	update_state(direction)
	# Actualiza la animación en el AnimationTree según el estado actual
	update_animation_state()

	# Detectar cambio brusco de dirección
	if direction != 0 and sign(direction) != sign(velocity.x) and abs(velocity.x) > 100:
		if randi_range(0, 99) < 1: # 1% de probabilidad
			fall_down()
			return

	# Contador de tiempo corriendo
	if state == State.RUN:
		run_time += delta
		if run_time > 3.0: # Si lleva más de 3 segundos corriendo
			if randi_range(0, 99) < 1: # 1% de probabilidad cada frame
				fall_down()
				return
	else:
		run_time = 0.0

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

func fall_down():
	state = State.FALLEN
	fallen_timer = FALLEN_DURATION
	fallen_slide_velocity = velocity.x # Mantiene la velocidad horizontal al caer
	velocity = Vector2.ZERO
	anim_tree["parameters/playback"].travel("FallDown") # Asegúrate de tener esta animación
