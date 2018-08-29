extends Node2D

var vnglobal

var ondas_class = preload("res://mini_batallafinal/ondas.tscn")

var vidaperso = 5
var vidamala = 3

var velperso = Vector2(0.0,0.0)
var speedperso = 80.0

var velmala = Vector2(0.0,80.0)
var speedmala = 80.0
var tiempomala = 0
var timeattack = 0.5 #Time to send waves to player

#Health bar container
var corazones

#Finish the minigame
func finish():
	#Set the variable
	if (vidaperso > 0):
		vnglobal.set_var("ganar", 1)
	else:
		vnglobal.set_var("ganar", 0)
	
	#Stop the music
	$music.stop()
	
	#Make the fade out and assign the VN to the transition
	$transition/anim.play("fade_out")

#Handle player input
func moverse ():
	if (Input.is_action_pressed("ui_up") and $player.position.y > -100):
		velperso.y = -speedperso
	elif (Input.is_action_pressed("ui_down") and $player.position.y < 100):
		velperso.y = speedperso
	else :
		velperso.y = 0


#Witch movement
func mala():
	if ($mala.position.y < -100):
		velmala.y = speedmala
	elif ($mala.position.y > 100):
		velmala.y = -speedmala

#Create a new wave attacking the player
func atacar():
	var onda = ondas_class.instance()
	onda.position.x = $mala.position.x
	onda.position.y = $mala.position.y
	add_child(onda)
	$mala/AnimationPlayer.play("attack")

#Plays the music and shows the UI container
func resume_pause():
	if (not $music.playing):
		$music.playing = true
		$ui/corazones.show()

func _ready():
	#Store the ui
	corazones = $ui/corazones
	vnglobal = get_tree().root.get_node("/root/vn_global")
	pass


func _process(delta):
	#Player movement
	moverse() 
	$player.position += velperso*delta
	
	#Witch movement
	mala()
	$mala.position += velmala*delta
	
	#From time to time, do an attack
	tiempomala += delta
	if (tiempomala >= timeattack):
		atacar()
		tiempomala = 0
	
	#Call code to return waves
	if (Input.is_action_just_pressed("ui_accept")):
		#Emit particles as an effect
		$player/reflect.emitting = true
		get_tree().call_group("ondas", "darselavuelta")
	

#Hurt the player if wave enters
func _on_player_area_entered(area):
	area.queue_free()
	vidaperso -= 1
	corazones.eliminar_vida()
	#TODO perder
	if (vidaperso == 0):
		finish()

#If the wave is inside the sensor area, make ready
#for reverse
func _on_Area2D_area_entered(area):
	area.preparado = true

#Deal damage to the witch when wave enter
func _on_mala_area_entered(area):
	if (area.vel.x > 0):
		area.queue_free()
		vidamala -= 1
		if (vidamala == 0):
			finish()
