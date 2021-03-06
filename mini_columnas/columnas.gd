extends Node2D

var vel = Vector2(0.0,0.0)
var speed = 2.0 #Player movement speed

var vnglobal

var anim #Animation state

var tiempo = 0 #Time counter
var counter = 0.0 #Total time counter
var time_end = 30.0 #To finish game

var vida = 3 #Number of hits
var vulnerable = true #If true, columns can hurt him
var corazones #Stores the life container

#Column class
var col_class = preload("res://mini_columnas/colum.tscn")

#Process player input
func moverse():
	if (Input.is_action_pressed("ui_right")):
		vel.x = speed
		change_anim("right")
	elif (Input.is_action_pressed("ui_left")):
		vel.x = -speed
		change_anim("left")
	else :
		anim = ""
		vel.x = 0
		$player/AnimationPlayer.stop(true)
		

#This function adds a column
func add_columna(tipo):
	var columna = col_class.instance()
	columna.position.x = (randf()*(320)-160)
	columna.position.y = -100
	add_child(columna)
	columna.get_node("Sprite").frame = tipo

#Plays the music and shows the UI container
func resume_pause():
	if (not $music.playing):
		$music.playing = true
		$ui/corazones.show()

#Finish the minigame
func finish():
	#Set the variable
	if (vida > 0):
		vnglobal.set_var("columna", 1)
	else:
		vnglobal.set_var("columna", 0)
	
	#Stop the music
	$music.stop()
	
	#Make the fade out and assign the VN to the transition
	$transition/anim.play("fade_out")


func _ready():
	randomize() #Gets a "random" seed
	corazones = $ui/corazones #Store ui container
	vnglobal = get_tree().root.get_node("/root/vn_global")

func _process(delta):
	moverse() #Process player movement
	
	#Throw columns to the player
	tiempo += delta
	counter += delta
	
	if (tiempo > 1):
		#Select type randomly
		if (randf()>= 0.6):
			add_columna(2)
		else:
			add_columna(1)
		tiempo = 0
		
	$player.move_and_collide(vel)
	
	if (counter >= time_end):
		finish()
		set_process(false) 
	


#Changes animation of the animation player
func change_anim(new_anim):
	if (new_anim != anim):
		anim = new_anim
		$player/AnimationPlayer.play(new_anim)

#Hurt player, switching off hitbox after a hit
#That avoid multiple collisions
func _on_sensor_body_entered(body):
	if (vulnerable):
		vulnerable = false
		vida -= 1
		corazones.eliminar_vida()
		#TODO: add death condition
		if (vida == 0):
			finish()

#After a crash with a column, vulnerable again
#when the column dissapears (or when you move away)
func _on_sensor_body_exited(body):
	vulnerable = true
