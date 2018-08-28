extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var rebaniocabras = preload("res://mini_cabras/cabra.tscn")

var speed = 3
var vel = Vector2(0.0,0.0)

var tiempo = 0
var tiempocabra = 3

var anim

var cabrasencerradas = 0

func change_anim(new_anim):
	if (new_anim != anim):
		anim = new_anim
		$player/AnimationPlayer.play(new_anim)

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
		
func add_cabra () :
	var micabra = rebaniocabras.instance()
	micabra.set_player($player)
	var lado = randf()
	if (lado < 0.5):
		micabra.velocidad.x = micabra.speed
		micabra.position.x = -240
	else:
		micabra.velocidad.x = - micabra.speed
		micabra.position.x = 240
	micabra.position.y = randf()*240 - 120
	add_child(micabra)
	
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


func _ready():
	randomize()
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	tiempo += delta
	moverse()
	$player.move_and_collide(vel)
	
	if (tiempo >= tiempocabra):
		add_cabra()
		tiempo = 0
	
	
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Area2D_body_entered(body):
	if (body.name != "player"):
		body.queue_free()
		cabrasencerradas += 1
		print(cabrasencerradas)
	pass # replace with function body
