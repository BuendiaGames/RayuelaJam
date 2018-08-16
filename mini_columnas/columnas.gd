extends Node2D

var vel = Vector2(0.0,0.0)
var speed = 2.0 #velocidad a la que se mueve

var anim #variable para animacion

var tiempo = 0 #contador de tiempo

#instancia de la clase columna para añadirla a la escena actual
var col_class = preload("res://mini_columnas/colum.tscn")

func moverse():
	if (Input.is_action_pressed("ui_right")):
		vel.x = speed
		change_anim("right")
	elif (Input.is_action_pressed("ui_left")):
		vel.x = -speed
		change_anim("left")
	else :
		vel.x = 0
		$player/AnimationPlayer.stop(true)
		
func add_columna(tipo):
	var columna = col_class.instance()
	columna.position.x = (randf()*(320)-160)
	columna.position.y = -100
	add_child(columna)
	columna.get_node("Sprite").frame = tipo
	#(randf() * (y-x)) + x

	

	

func _ready():
	randomize() #genera la semilla para las cosas aleatorias
	#var columna = col_class.instance()
	#add_child(columna)
	
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	#set_process(false)
	#set_physics_process(true)
	pass

func _process(delta):
	moverse()
	tiempo += delta
	if (tiempo > 1):
		if (randf()>= 0.6):
			add_columna(2)
		else:
			add_columna(1)
		tiempo = 0
	#get_node("player").move_and_collide(vel)
	$player.move_and_collide(vel)
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func change_anim(new_anim):
	if (new_anim != anim):
		anim = new_anim
		$player/AnimationPlayer.play(new_anim)
