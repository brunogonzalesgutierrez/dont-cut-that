## Popup del expediente médico del paciente.
## Muestra datos generados aleatoriamente al inicio de cada cirugía.
## Incluye nombres, alergias (normales y cómicas), notas del doctor, etc.
extends PanelContainer

# --- Señales ---

## Emitida cuando el jugador cierra el expediente.
signal expediente_cerrado()

# --- Referencias a nodos hijos ---

## Etiqueta con el nombre completo del paciente.
@onready var nombre_label: Label = $MargenContenido/VBoxContainer/NombreLabel

## Texto enriquecido con los datos clínicos del paciente.
@onready var datos_label: RichTextLabel = $MargenContenido/VBoxContainer/DatosLabel

## Etiqueta con la nota cómica del doctor/enfermera.
@onready var nota_label: Label = $MargenContenido/VBoxContainer/NotaLabel

## Botón para cerrar el expediente y continuar.
@onready var boton_cerrar: Button = $MargenContenido/VBoxContainer/BotonCerrar

# --- Datos para generación aleatoria ---

## Nombres de pacientes (inspirados en nombres comunes bolivianos/latinos).
var nombres: Array = [
	"Roberto Fernández",
	"María del Carmen Quispe",
	"Juan Pablo Mamani",
	"Lucía Torrez",
	"Pedro Gonzales Gutiérrez",
]

## Alergias médicas reales.
var alergias_normales: Array = [
	"Penicilina",
	"Latex",
	"Ibuprofeno",
	"Sulfamidas",
]

## Alergias cómicas (para el humor del juego).
var alergias_comicas: Array = [
	"Los hospitales",
	"Las agujas",
	"Los practicantes",
	"Los lunes",
	"El color rojo",
]

## Notas cómicas del expediente escritas por personal del hospital.
var notas: Array = [
	"NO dejar que el practicante haga esto solo.",
	"Paciente nervioso. No mencionar la palabra \"complicación\".",
	"El paciente preguntó si el doctor se graduó. Mentirle.",
	"Revisar que el bisturí esté del lado correcto.",
	"Nota anterior: \"¿Quién dejó un café en el quirófano?\"",
]

## Tipos de cirugía disponibles.
var cirugias: Array = [
	"Apendicectomía",
	"Colecistectomía",
	"Extracción de cuerpo extraño",
	"Hernia inguinal",
	"Amigdalectomía",
]


func _ready() -> void:
	# Ocultar al inicio — se muestra con mostrar()
	visible = false

	# Conectar el botón de cerrar
	boton_cerrar.pressed.connect(_on_cerrar)


## Genera datos aleatorios y muestra el expediente en pantalla.
func mostrar() -> void:
	var datos: Dictionary = generar_datos()

	# Rellenar el nombre del paciente
	nombre_label.text = "Paciente: %s" % datos["nombre"]

	# Rellenar los datos clínicos con formato BBCode
	datos_label.clear()
	datos_label.push_bold()
	datos_label.add_text("Cirugía: ")
	datos_label.pop()
	datos_label.add_text("%s\n" % datos["cirugia"])

	datos_label.push_bold()
	datos_label.add_text("Edad: ")
	datos_label.pop()
	datos_label.add_text("%d años\n" % datos["edad"])

	datos_label.push_bold()
	datos_label.add_text("Tipo de sangre: ")
	datos_label.pop()
	datos_label.add_text("%s\n" % datos["tipo_sangre"])

	datos_label.push_bold()
	datos_label.add_text("Alergias: ")
	datos_label.pop()
	datos_label.add_text("%s\n" % datos["alergias"])

	datos_label.push_bold()
	datos_label.add_text("Peso: ")
	datos_label.pop()
	datos_label.add_text("%.1f kg\n" % datos["peso"])

	# Nota cómica del doctor
	nota_label.text = "📋 Nota: %s" % datos["nota"]

	# Mostrar el popup
	visible = true


## Callback del botón cerrar: oculta el popup y emite la señal.
func _on_cerrar() -> void:
	visible = false
	expediente_cerrado.emit()


## Genera un diccionario con datos aleatorios del paciente.
## Mezcla una alergia real con una cómica para el efecto humorístico.
func generar_datos() -> Dictionary:
	# Seleccionar una alergia normal y una cómica
	var alergia_real: String = alergias_normales[randi() % alergias_normales.size()]
	var alergia_comica: String = alergias_comicas[randi() % alergias_comicas.size()]
	var texto_alergias: String = "%s, %s" % [alergia_real, alergia_comica]

	# Tipos de sangre posibles
	var tipos_sangre: Array = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]

	var datos: Dictionary = {
		"nombre": nombres[randi() % nombres.size()],
		"cirugia": cirugias[randi() % cirugias.size()],
		"edad": randi_range(18, 85),
		"tipo_sangre": tipos_sangre[randi() % tipos_sangre.size()],
		"alergias": texto_alergias,
		"peso": randf_range(45.0, 130.0),
		"nota": notas[randi() % notas.size()],
	}

	return datos
