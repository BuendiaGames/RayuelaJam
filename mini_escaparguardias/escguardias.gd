extends Node2D


var velsaltoplayer = Vector2(0.0,0.0)

var vnglobal
var caught = false

var tiempojuego = 60

var tiempo = 0 #Timecounter
var tiempo_obs = 2.0 #Time at which obstacles are placed
var anim #Stores animation

var obs_class = preload("res://mini_escaparguardias/obstaculo.tscn")

#Bg scroll speed
var bg_speed = -120.0

#Create a new obstacle
func add_obst():
	var obst = obs_class.instance()
	#Set random speed
	if (randf() < 0.6):
		obst.vel.x = obst.vel1
	else:
		obst.vel.x = obst.vel2
	obst.position.x = 300
	add_child(obst)

#Makes the character jamp when the action is pressed
func saltar(delta):
	if (Input.is_action_just_pressed("ui_accept")):
		velsaltoplayer.y = -3.2
	velsaltoplayer.y += delta*11

#Plays the music and shows the UI container
func resume_pause():
	if (not $music.playing):
		$music.playing = true



#Make the background scroll
func bg_scroll(delta):
	
	for bg in $bg.get_children():
		bg.position.x += delta * bg_speed
		#Restore position: 1024-screen size, /2 because camera at 0
		if (bg.position.x <= -1024/2):
			bg.position.x = 1024/2


#Finish the minigame
func finish():
	
	#Set the variable
	if (not caught):
		vnglobal.set_var("escapar", 1)
	else:
		vnglobal.set_var("escapar", 0)
	
	#Stop the music
	$music.stop()
	
	#Make the fade out and assign the VN to the transition
	$transition/anim.play("fade_out")

func _ready():
	randomize()
	vnglobal = get_tree().root.get_node("/root/vn_global")
	pass

func _process(delta):
	#Move bg
	bg_scroll(delta)
	
	
	#Add obstacle from time to time
	tiempo += delta
	if (tiempo > tiempo_obs):
		add_obst()
		tiempo = 0
	
	#Allow player to jump
	saltar(delta)
	
	#Get and process the colision
	var colision = $player.move_and_collide(velsaltoplayer)
	if (colision):
		#Set jump animation
		if (colision.collider.name != "suelo"):
			$player/AnimationPlayer.stop()
			$player/Sprite.frame = 4
		else:
			change_anim("run")
	else:
		#Probably not called at all
		anim = ""
		$player/AnimationPlayer.stop()
		$player/Sprite.frame = 4
	
	tiempojuego -= delta
	if (tiempojuego <= 0):
		finish()

#Check if we got the guards
func _on_guardias_body_entered(body):
	if (body.name == "player"):
		caught = true
		finish()

#Change animation
func change_anim(new_anim):
	if (new_anim != anim):
		anim = new_anim
		$player/AnimationPlayer.play(new_anim)
