extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var preparado = false

var speed = 50.0
var vel = Vector2(0.0,0.0)

var dir_arriba = Vector2(-1.0/sqrt(2),-1.0/sqrt(2))
var dir_recto = Vector2(-1.0,0)
var dir_abajo = Vector2(-1.0/sqrt(2),1.0/sqrt(2))

func lanzaronda():
	var prob = randf()
	if (prob <= 0.33):
		vel = speed*dir_arriba
	elif (prob <= 0.66):
		vel = speed*dir_recto
	else:
		vel = speed*dir_abajo
		
func darselavuelta():
	if (preparado):
		vel.x = -vel.x
	

func _ready():
	randomize()
	lanzaronda()
	add_to_group("ondas")
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	
	position += vel*delta
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
