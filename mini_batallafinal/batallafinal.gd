extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var ondas_class = preload("res://mini_batallafinal/ondas.tscn")

var vidaperso = 3

var velperso = Vector2(0.0,0.0)
var speedperso = 50.0

var velmala = Vector2(0.0,80.0)
var speedmala = 80.0
var tiempomala = 0

func moverse ():
	if (Input.is_action_pressed("ui_up") and $player.position.y > -100):
		velperso.y = -speedperso
		#change_anim("right")
	elif (Input.is_action_pressed("ui_down") and $player.position.y < 100):
		velperso.y = speedperso
		#change_anim("left")
	else :
		velperso.y = 0
		#$player/AnimationPlayer.stop(true)

func mala():
	if ($mala.position.y < -100):
		velmala.y = speedmala
	elif ($mala.position.y > 100):
		velmala.y = -speedmala
	#if (abs($mala.position.y) >= 100):
	#	velmala.y = -velmala.y
	
func atacar():
	var onda = ondas_class.instance()
	onda.position.x = $mala.position.x
	onda.position.y = $mala.position.y
	add_child(onda)


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	moverse()
	$player.position += velperso*delta
	mala()
	$mala.position += velmala*delta
	tiempomala += delta
	if (tiempomala >= 3):
		atacar()
		tiempomala = 0
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


#cuando pulses tecla A:
#	call_group("ondas", "darse_la_vuelta")
	
#area es lo que choca conmigo
func _on_player_area_entered(area):
	
#	mi_onda = area
	
	area.queue_free()
	vidaperso -= 1
	if (vidaperso == 0):
		print("muerto")
		#falta quitar iconitos d ecorazon una vez los tenga
	pass # replace with function body
