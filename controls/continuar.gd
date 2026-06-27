extends Button

func _ready() -> void:
	pressed.connect(_on_continuar_presionado)

func _on_continuar_presionado() -> void:
	get_tree().change_scene_to_file("res://controls/continuar/prueba_mano.tscn")
