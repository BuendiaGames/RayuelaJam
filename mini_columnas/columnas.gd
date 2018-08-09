extends Node2D

var vel = Vector2(0.0,0.0)
var speed = 2.0

var anim

var tiempo = 0

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
	add_child(columna)
	columna.get_node("Sprite").frame = tipo
	#(randf() * (y-x)) + x
	columna.position.x = (randf()*(200))
	

func _ready():
	randomize()
	#var columna = col_class.instance()
	#add_child(columna)
	
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	moverse()
	tiempo += delta
	if (tiempo > 2):
		add_columna(2)
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
