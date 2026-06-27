extends Control

var mano_abierta = preload("res://media/manos/mano_abierta.png")
var mano_cerrada = preload("res://media/manos/mano_cerrada.png")

@onready var mano = $TextureRect

func _ready():
	mano.texture = mano_abierta
	mano.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mano.size = Vector2(400, 400)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _input(event):
	if event is InputEventMouseMotion:
		mano.position = event.position - Vector2(200, 200)
	
	if event is InputEventMouseButton:
		if event.pressed:
			mano.texture = mano_cerrada
		else:
			mano.texture = mano_abierta
