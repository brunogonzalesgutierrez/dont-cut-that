extends Button

func _ready() -> void:
	pressed.connect(_on_boton_salir_presionado)

func _on_boton_salir_presionado() -> void:
	get_tree().quit()
