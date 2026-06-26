## Monitor ECG del quirófano.
## Anima una Line2D para simular la onda cardíaca en el monitor CRT.
## Cambia de color según el estado del paciente (verde/amarillo/rojo).
extends Node2D

# --- Referencias ---

## La línea que dibuja la onda ECG.
@onready var linea: Line2D = $LineaECG

## Etiqueta que muestra los BPM actuales.
@onready var label_bpm: Label = $LabelBPM

# --- Exportadas ---

## Frecuencia cardíaca actual en latidos por minuto.
@export var bpm: float = 72.0

## Amplitud vertical de la onda ECG en píxeles.
@export var amplitud: float = 20.0

## Ancho del área de pantalla del monitor en píxeles.
@export var ancho_pantalla: float = 180.0

## Alto del área de pantalla del monitor en píxeles.
@export var alto_pantalla: float = 80.0

# --- Variables internas ---

## Acumulador de tiempo para el desplazamiento de la onda.
var tiempo: float = 0.0

## Cantidad de puntos que componen la línea ECG.
var num_puntos: int = 60

## Bandera para indicar si el paciente está en línea plana (muerto).
var _linea_plana: bool = false


func _ready() -> void:
	# Inicializar la línea con puntos vacíos
	linea.clear_points()
	for i: int in range(num_puntos):
		linea.add_point(Vector2.ZERO)

	# Configurar apariencia inicial
	linea.width = 2.0
	linea.default_color = Color.GREEN
	label_bpm.text = "%d BPM" % int(bpm)


func _process(delta: float) -> void:
	tiempo += delta

	if _linea_plana:
		# Línea plana: todos los puntos al centro vertical
		_dibujar_linea_plana()
		return

	_dibujar_onda_ecg()
	label_bpm.text = "%d BPM" % int(bpm)


## Genera los puntos de la onda ECG con el clásico complejo QRS.
func _dibujar_onda_ecg() -> void:
	# Frecuencia de la onda basada en BPM
	# Un latido completo dura 60/bpm segundos
	var frecuencia: float = bpm / 60.0
	var centro_y: float = alto_pantalla * 0.5

	for i: int in range(num_puntos):
		var x: float = (float(i) / float(num_puntos - 1)) * ancho_pantalla

		# Posición normalizada en el ciclo cardíaco (0.0 a 1.0)
		var t: float = fmod((float(i) / float(num_puntos) + tiempo * frecuencia), 1.0)
		var y: float = centro_y

		# Generar la forma del complejo PQRST
		if t >= 0.0 and t < 0.10:
			# Onda P (pequeña elevación)
			var fase_p: float = (t - 0.0) / 0.10
			y = centro_y - sin(fase_p * PI) * amplitud * 0.15

		elif t >= 0.15 and t < 0.18:
			# Onda Q (pequeña depresión antes del pico)
			var fase_q: float = (t - 0.15) / 0.03
			y = centro_y + sin(fase_q * PI) * amplitud * 0.2

		elif t >= 0.18 and t < 0.25:
			# Onda R (pico alto principal — el "bip" del ECG)
			var fase_r: float = (t - 0.18) / 0.07
			y = centro_y - sin(fase_r * PI) * amplitud

		elif t >= 0.25 and t < 0.30:
			# Onda S (depresión rápida tras el pico)
			var fase_s: float = (t - 0.25) / 0.05
			y = centro_y + sin(fase_s * PI) * amplitud * 0.3

		elif t >= 0.35 and t < 0.50:
			# Onda T (elevación suave de repolarización)
			var fase_t: float = (t - 0.35) / 0.15
			y = centro_y - sin(fase_t * PI) * amplitud * 0.25

		# El resto es línea base (y = centro_y)

		linea.set_point_position(i, Vector2(x, y))


## Dibuja una línea completamente plana (paciente sin pulso).
func _dibujar_linea_plana() -> void:
	var centro_y: float = alto_pantalla * 0.5
	for i: int in range(num_puntos):
		var x: float = (float(i) / float(num_puntos - 1)) * ancho_pantalla
		linea.set_point_position(i, Vector2(x, centro_y))


## Actualiza los BPM y cambia el color de la línea según la gravedad.
## Verde = normal, Amarillo = elevado (>120), Rojo = crítico (>160 o <40).
func actualizar_bpm(nuevo_bpm: float) -> void:
	bpm = nuevo_bpm
	_linea_plana = false

	if bpm > 160.0 or bpm < 40.0:
		# Estado crítico — rojo
		linea.default_color = Color.RED
	elif bpm > 120.0:
		# Elevado — amarillo
		linea.default_color = Color.YELLOW
	else:
		# Normal — verde
		linea.default_color = Color.GREEN

	label_bpm.text = "%d BPM" % int(bpm)


## Pone el monitor en línea plana. El paciente ha muerto.
func linea_plana() -> void:
	_linea_plana = true
	bpm = 0.0
	linea.default_color = Color.RED
	label_bpm.text = "0 BPM"
