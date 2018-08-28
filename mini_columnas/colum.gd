extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var velocidad = Vector2(0.0,0.0)
var tiempo = 0

func caer_columna(delta):
	velocidad.y += delta*10
	var colisionando = move_and_collide(velocidad)
	if (colisionando):
		if (colisionando.collider.name == "player"):
			print("Muertooooooooo mancoooo")
		tiempo+=delta
		if (tiempo >= 2):
			queue_free()
		

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	caer_columna(delta)
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
	pass
