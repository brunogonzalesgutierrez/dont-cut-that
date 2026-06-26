## Instrumento quirúrgico arrastrable.
## Se adjunta a cada Area2D de la mesa de instrumentos.
## El jugador lo arrastra sobre la zona del paciente para usarlo.
extends Area2D

# --- Señales ---

## Emitida cuando el jugador selecciona este instrumento (clic).
signal instrumento_seleccionado(instrumento: Node)

## Emitida cuando el instrumento se usa sobre la zona del paciente.
signal instrumento_usado(nombre: String)

# --- Exportadas ---

## Nombre interno del instrumento (bisturi, pinzas, aspirador, etc.).
@export var nombre_instrumento: String = "bisturi"

## Color del instrumento en reposo (gris plateado metálico).
@export var color_normal: Color = Color(0.69, 0.72, 0.69)

## Color del instrumento al pasar el mouse por encima.
@export var color_hover: Color = Color(0.8, 0.85, 0.8)

# --- Variables internas ---

## Indica si el instrumento está seleccionado/activo.
var seleccionado: bool = false

## Indica si el jugador está arrastrando el instrumento.
var arrastrando: bool = false

## Posición original en la mesa para volver después de usarlo.
var posicion_original: Vector2 = Vector2.ZERO

# --- Referencias ---

## Representación visual del instrumento (un ColorRect simple).
@onready var sprite: ColorRect = $Visual


func _ready() -> void:
	# Guardar la posición inicial para poder regresar al soltar
	posicion_original = global_position

	# Configurar el color inicial
	sprite.color = color_normal

	# Conectar señales de mouse para efecto hover
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	# Habilitar la detección de input en el Area2D
	input_pickable = true


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	# Detectar clic del mouse sobre el instrumento
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			seleccionado = true
			arrastrando = true
			instrumento_seleccionado.emit(self)
			# Traer al frente visualmente
			z_index = 10


func _input(event: InputEvent) -> void:
	if not arrastrando:
		return

	# Seguir el movimiento del mouse mientras se arrastra
	if event is InputEventMouseMotion:
		var motion_event: InputEventMouseMotion = event as InputEventMouseMotion
		global_position += motion_event.relative

	# Soltar el instrumento al liberar el botón del mouse
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
			arrastrando = false
			seleccionado = false
			z_index = 0

			# Verificar si el instrumento se soltó sobre la zona del paciente
			var areas_superpuestas: Array[Area2D] = get_overlapping_areas()
			var sobre_paciente: bool = false

			for area: Area2D in areas_superpuestas:
				# Buscar un Area2D que pertenezca al grupo "zona_paciente"
				if area.is_in_group("zona_paciente"):
					sobre_paciente = true
					break

			if sobre_paciente:
				# ¡Instrumento usado sobre el paciente!
				instrumento_usado.emit(nombre_instrumento)

			# Siempre devolver a la posición original
			devolver()


## Efecto visual: mouse entra sobre el instrumento.
func _on_mouse_entered() -> void:
	if not arrastrando:
		sprite.color = color_hover


## Efecto visual: mouse sale del instrumento.
func _on_mouse_exited() -> void:
	if not arrastrando:
		sprite.color = color_normal


## Anima el instrumento de regreso a su posición original con un tween.
func devolver() -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "global_position", posicion_original, 0.4)
