## Panel de diales de preparación preoperatoria.
## Permite al jugador ajustar anestesia, suero IV y antibiótico
## antes de comenzar la cirugía. Eduardo da las indicaciones por el auricular.
extends PanelContainer

# --- Señales ---

## Emitida al confirmar los valores. Envía anestesia (ml), suero (ml), antibiótico (mg).
signal diales_confirmados(anestesia: float, suero: float, antibiotico: float)

# --- Referencias a sliders ---

## Slider de dosis de anestesia (0 – 10 ml, paso 0.1).
@onready var slider_anestesia: HSlider = $MargenContenido/VBoxContainer/AnestesiaContainer/SliderAnestesia

## Slider de volumen de suero IV (0 – 1000 ml, paso 50).
@onready var slider_suero: HSlider = $MargenContenido/VBoxContainer/SueroContainer/SliderSuero

## Slider de dosis de antibiótico (0 – 500 mg, paso 10).
@onready var slider_antibiotico: HSlider = $MargenContenido/VBoxContainer/AntibioticoContainer/SliderAntibiotico

# --- Referencias a etiquetas de valor ---

## Muestra el valor actual de anestesia.
@onready var label_anestesia: Label = $MargenContenido/VBoxContainer/AnestesiaContainer/ValorAnestesia

## Muestra el valor actual de suero.
@onready var label_suero: Label = $MargenContenido/VBoxContainer/SueroContainer/ValorSuero

## Muestra el valor actual de antibiótico.
@onready var label_antibiotico: Label = $MargenContenido/VBoxContainer/AntibioticoContainer/ValorAntibiotico

# --- Referencia al botón ---

## Botón para confirmar los valores y proceder a la cirugía.
@onready var boton_confirmar: Button = $MargenContenido/VBoxContainer/BotonConfirmar


func _ready() -> void:
	# Ocultar al inicio — se muestra con mostrar()
	visible = false

	# Configurar rangos de los sliders
	_configurar_slider(slider_anestesia, 0.0, 10.0, 0.1)
	_configurar_slider(slider_suero, 0.0, 1000.0, 50.0)
	_configurar_slider(slider_antibiotico, 0.0, 500.0, 10.0)

	# Conectar señales de cambio de valor
	slider_anestesia.value_changed.connect(_on_slider_changed)
	slider_suero.value_changed.connect(_on_slider_changed)
	slider_antibiotico.value_changed.connect(_on_slider_changed)

	# Conectar botón de confirmación
	boton_confirmar.pressed.connect(_on_confirmar)

	# Actualizar etiquetas con valores iniciales
	_actualizar_etiquetas()


## Configura un slider con sus valores mínimo, máximo y paso.
func _configurar_slider(slider: HSlider, minimo: float, maximo: float, paso: float) -> void:
	slider.min_value = minimo
	slider.max_value = maximo
	slider.step = paso
	slider.value = minimo


## Muestra el panel, reseteando todos los sliders a cero.
func mostrar() -> void:
	slider_anestesia.value = 0.0
	slider_suero.value = 0.0
	slider_antibiotico.value = 0.0
	_actualizar_etiquetas()
	visible = true


## Callback genérico para cualquier slider que cambie de valor.
## Ignora el parámetro porque actualizamos todas las etiquetas a la vez.
func _on_slider_changed(_value: float) -> void:
	_actualizar_etiquetas()


## Actualiza las tres etiquetas con los valores formateados de cada slider.
func _actualizar_etiquetas() -> void:
	label_anestesia.text = "%.1f ml" % slider_anestesia.value
	label_suero.text = "%.0f ml" % slider_suero.value
	label_antibiotico.text = "%.0f mg" % slider_antibiotico.value


## Callback del botón confirmar: emite la señal con los tres valores y oculta el panel.
func _on_confirmar() -> void:
	diales_confirmados.emit(
		slider_anestesia.value,
		slider_suero.value,
		slider_antibiotico.value
	)
	visible = false
