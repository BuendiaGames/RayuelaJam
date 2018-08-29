extends Node2D

#Goat class
var rebaniocabras = preload("res://mini_cabras/cabra.tscn")
var vnglobal #To communicate with visual novel


#Movement of player
var speed = 3
var vel = Vector2(0.0,0.0)

#Time of creating goats
var tiempo = 0
var tiempocabra = 3

var counter = 0.0
var fin = 3.0

#Animation controller
var anim

#Number of goats
var cabrasencerradas = 0

#Change anim
func change_anim(new_anim):
	if (new_anim != anim):
		anim = new_anim
		$player/AnimationPlayer.play(new_anim)

#Player movement
func moverse():
	if (Input.is_action_pressed("ui_right")):
		vel.x = speed
		vel.y = 0
		change_anim("walk")
	elif (Input.is_action_pressed("ui_left")):
		vel.x = -speed
		vel.y = 0
		change_anim("walk2")
	elif (Input.is_action_pressed("ui_up")):
		vel.x = 0
		vel.y = -speed
		change_anim("down")
	elif (Input.is_action_pressed("ui_down")):
		vel.x = 0
		vel.y = speed
		change_anim("up")
	else :
		anim = ""
		vel.x = 0
		vel.y = 0
		$player/AnimationPlayer.stop(true)

#Create a new goat
func add_cabra () :
	
	var micabra = rebaniocabras.instance()
	micabra.set_player($player) #Give the player to the goat
	var lado = randf()
	#Create it in random place
	if (lado < 0.5):
		micabra.velocidad.x = micabra.speed
		micabra.position.x = -240
	else:
		micabra.velocidad.x = - micabra.speed
		micabra.position.x = 240
	micabra.position.y = randf()*240 - 120
	add_child(micabra)

#Delete a goat
func eliminar_cabra (sacrificio): #Sacrificio debe ser una cabra
	if (sacrificio.position.x < -300 or sacrificio.position.x > 300 or sacrificio.position.y < -200 or sacrificio.position.y > 200):
		sacrificio.queue_free()
	if (sacrificio.encerrada):
		sacrificio.queue_free()
		cabrasencerradas += 1


#Plays the music and shows the UI container
func resume_pause():
	if (not $music.playing):
		$music.playing = true

#Finish the minigame
func finish():
	#Get the money
	var dinero
	if (cabrasencerradas >= 6): dinero = 20
	else: dinero = 12
	
	vnglobal.set_var("dinero", dinero)
	
	#Hide goats
	get_tree().call_group("rebanio", "hide")
	
	#Stop the music
	$music.stop()
	
	#Make the fade out and assign the VN to the transition
	$transition/anim.play("fade_out")



func _ready():
	randomize()
	#Load the global script
	vnglobal = get_tree().root.get_node("/root/vn_global")
	pass

func _process(delta):
	tiempo += delta
	counter += delta
	
	moverse()
	$player.move_and_collide(vel)
	
	if (tiempo >= tiempocabra):
		add_cabra()
		tiempo = 0
	
	if (counter >= fin):
		finish()
		set_process(false)



func _on_Area2D_body_entered(body):
	if (body.name != "player"):
		body.queue_free()
		cabrasencerradas += 1
		print(cabrasencerradas)
	pass # replace with function body
