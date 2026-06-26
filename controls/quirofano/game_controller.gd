## Controlador principal del quirófano.
## Maneja la máquina de estados de la cirugía y coordina todos los
## nodos de la escena (expediente, diales, monitor, instrumentos, etc.).
extends Node

# --- Señales ---

## Emitida cuando cambia el estado del juego.
signal estado_cambiado(nuevo_estado: int)

## Emitida al terminar la cirugía, con resultado y puntaje.
signal cirugia_completada(exito: bool, puntaje: int)

# --- Estados ---

enum Estado {
	ESPERANDO,     ## Sin actividad, esperando inicio
	EXPEDIENTE,    ## Mostrando el expediente del paciente
	PREPARACION,   ## Ajustando diales de anestesia/suero/antibiótico
	CIRUGIA,       ## Operación en curso
	COMPLICACION,  ## ¡Algo salió mal!
	RESULTADO,     ## Pantalla de resultado final
}

# --- Exportadas ---

## Tiempo límite de la cirugía en segundos (3 minutos por defecto).
@export var tiempo_limite: float = 180.0

## Modo debug: Muestra qué instrumento necesitas en la pantalla
@export var modo_debug: bool = true

# --- Referencias a nodos de la escena ---

@onready var expediente_popup: PanelContainer = %ExpedientePopup
# PanelDiales se usará en la escena del baño (Eduardo)
# @onready var panel_diales: PanelContainer = %PanelDiales
@onready var monitor_ecg: Node2D = %MonitorECG
@onready var alerta_roja: PanelContainer = %AlertaRoja
@onready var timer_display: Label = %TimerDisplay
@onready var info_rango: Label = %InfoRango
@onready var instrumento_activo: ColorRect = %InstrumentoActivo

# --- Variables de estado ---

## Estado actual de la máquina de estados.
var estado_actual: int = Estado.ESPERANDO

## Puntaje acumulado durante la cirugía.
var puntaje: int = 0

## Frecuencia cardíaca actual del paciente.
var bpm_actual: float = 72.0

## Paso actual dentro de la secuencia quirúrgica.
var paso_actual: int = 0

## Nombre del instrumento correcto para el paso actual.
var instrumento_correcto: String = ""

## Tiempo restante de la cirugía (se decrementa en _process).
var _tiempo_restante: float = 0.0


# --- Funciones del ciclo de vida ---

func _ready() -> void:
	# Activar hitboxes visibles para debug
	get_tree().debug_collisions_hint = true

	# Conectar señales de los nodos hijos
	expediente_popup.expediente_cerrado.connect(_on_expediente_cerrado)

	# Añadir la zona del paciente al grupo para detección de colisión
	var zona_paciente: Area2D = %ZonaPaciente
	zona_paciente.add_to_group("zona_paciente")

	# Conectar señales de cada instrumento
	var instrumentos: Array[String] = ["Bisturi", "Pinzas", "Tijeras", "Aspirador", "Retractor", "Sutura"]
	for instrumento_name: String in instrumentos:
		var instrumento_node: Node = owner.get_node("%" + instrumento_name)
		if instrumento_node and instrumento_node.has_signal("instrumento_usado"):
			instrumento_node.instrumento_usado.connect(_on_instrumento_usado)

	# Ocultar elementos de UI al inicio
	alerta_roja.visible = false
	timer_display.text = ""

	# Iniciar cirugía directamente para pruebas
	iniciar_cirugia()


func _process(delta: float) -> void:
	if estado_actual != Estado.CIRUGIA:
		return

	# Decrementar el temporizador
	_tiempo_restante -= delta

	if _tiempo_restante <= 0.0:
		_tiempo_restante = 0.0
		_on_tiempo_agotado()
		return

	# Actualizar la etiqueta del temporizador con formato MM:SS
	var minutos: int = int(_tiempo_restante / 60.0)
	var segundos: int = int(_tiempo_restante) % 60
	timer_display.text = "%02d:%02d" % [minutos, segundos]

	# Cambiar color del timer cuando queda poco tiempo
	if _tiempo_restante < 30.0:
		timer_display.add_theme_color_override("font_color", Color.RED)
	elif _tiempo_restante < 60.0:
		timer_display.add_theme_color_override("font_color", Color.YELLOW)


# --- Flujo principal ---

## Inicia una nueva cirugía desde el estado ESPERANDO.
func iniciar_cirugia() -> void:
	puntaje = 0
	bpm_actual = 72.0
	paso_actual = 0
	instrumento_correcto = ""
	_tiempo_restante = tiempo_limite

	cambiar_estado(Estado.EXPEDIENTE)
	expediente_popup.mostrar()


## Callback: el jugador cerró el expediente del paciente.
## En el juego completo, aquí Eduardo calcularía las dosis desde el baño.
## Por ahora se pasa directo a cirugía.
func _on_expediente_cerrado() -> void:
	# Configurar el primer paso de la cirugía
	paso_actual = 1
	instrumento_correcto = "bisturi"
	if modo_debug:
		info_rango.text = "DEBUG: Eduardo dice 'Usa el %s'" % instrumento_correcto.capitalize()
	else:
		info_rango.text = "Paso 1: Arrastra el instrumento correcto al paciente"

	cambiar_estado(Estado.CIRUGIA)


## Callback: el jugador usó un instrumento sobre el paciente.
func _on_instrumento_usado(nombre_instrumento: String) -> void:
	if estado_actual != Estado.CIRUGIA:
		return

	if nombre_instrumento == instrumento_correcto:
		# ¡Instrumento correcto!
		puntaje += 200
		bpm_actual = clampf(bpm_actual - 2.0, 50.0, 180.0)
		info_rango.text = "✓ ¡Bien hecho! Eduardo está impresionado."
		paso_actual += 1

		# Verificar si se completaron todos los pasos (placeholder: 5 pasos)
		if paso_actual > 5:
			cambiar_estado(Estado.RESULTADO)
			cirugia_completada.emit(true, puntaje)
			return

		# Avanzar al siguiente instrumento (placeholder)
		var instrumentos_secuencia: Array[String] = [
			"bisturi", "pinzas", "aspirador", "sutura", "gasa"
		]
		if paso_actual <= instrumentos_secuencia.size():
			instrumento_correcto = instrumentos_secuencia[paso_actual - 1]
			if modo_debug:
				info_rango.text = "DEBUG: Eduardo dice 'Ahora usa el %s'" % instrumento_correcto.capitalize()
			else:
				info_rango.text = "Paso %d: Usa el instrumento correcto" % paso_actual
	else:
		# Instrumento incorrecto — ¡tensión!
		puntaje -= 100
		bpm_actual = clampf(bpm_actual + 15.0, 30.0, 200.0)
		info_rango.text = "✗ ¡Instrumento equivocado! Eduardo grita por el auricular."

		# Si el BPM sube demasiado, ¡complicación!
		if bpm_actual > 160.0:
			_on_complicacion()
			return

	# Actualizar el monitor ECG
	monitor_ecg.actualizar_bpm(bpm_actual)


## Callback: ocurrió una complicación durante la cirugía.
func _on_complicacion() -> void:
	cambiar_estado(Estado.COMPLICACION)
	alerta_roja.visible = true
	info_rango.text = "¡¡COMPLICACIÓN!! Eduardo dice: '¡No toques nada!'"

	# Dar un breve momento antes de declarar fracaso
	var timer: SceneTreeTimer = get_tree().create_timer(3.0)
	timer.timeout.connect(_finalizar_con_fracaso)


## Callback: se agotó el tiempo de la cirugía.
func _on_tiempo_agotado() -> void:
	info_rango.text = "⏰ ¡Se acabó el tiempo! El anestesiólogo está furioso."
	cambiar_estado(Estado.RESULTADO)
	cirugia_completada.emit(false, puntaje)


# --- Utilidades ---

## Cambia el estado actual y emite la señal correspondiente.
func cambiar_estado(nuevo: int) -> void:
	estado_actual = nuevo
	estado_cambiado.emit(nuevo)


## Finaliza la cirugía con fracaso (llamada tras complicación).
func _finalizar_con_fracaso() -> void:
	alerta_roja.visible = false
	cambiar_estado(Estado.RESULTADO)
	cirugia_completada.emit(false, puntaje)
