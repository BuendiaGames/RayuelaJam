extends Node2D


#Music variables
const note_tempo = 60.0 / 210.0 #Time of a single note
var beer_throw = [] #When a beer should be thrown
var beer_index = 0 #Current beer

var tiempo = 0.0 #Time counter (music)
var tiempo_got = 0.0 #Time counter between get and drink

#Time bounds to get it right
const margen = 0.15 #Time margin to get it ok
const timeA = note_tempo - margen
const timeB = note_tempo + margen

var beer_enter = false #Is beer inside area?
var beer_got = false #Did player got it?


var cerveza_class = preload("res://mini_cervezas/cerveza.tscn")

var vida = 5

var corazones #Stores the ui container


#Create a new beer 
func add_cerveza():
	
	$player.frame = 0
	var cerv = cerveza_class.instance()
	cerv.position.x = -200
	cerv.position.y = 0
	#203 -> space between cerv position and sensor pos
	#2*note tempo: time to reach area (2 beats)
	cerv.speed = 203.0 / (2.0*note_tempo)
	add_child(cerv)

func _ready():
	#When a beer should be thrown, in music units (time
	#142 -> Repetition
	beer_throw = [6,22,40,44,48,56,60,64,68,72,76,80,88,92,96,102,110,118,126,130,142,158,164,172,180,197]
	
	#Convert the array to times
	for j in range(len(beer_throw)):
		beer_throw[j] *= note_tempo
	
	print(beer_throw)
	
	
	corazones = $ui/corazones
	set_physics_process(true)

#Plays the music and shows the UI container
func resume_pause():
	if (not $music.playing):
		$music.playing = true
		$ui/corazones.show()

func _physics_process(delta):
	
	#Check it is time to throw a beer
	if (beer_index < len(beer_throw)):
		if (tiempo >= beer_throw[beer_index]):
			beer_index += 1 #To next beer
			add_cerveza()
	
	#Increase time (really don't count unless beer_got = true)
	tiempo += delta
	tiempo_got += delta 
	
	if (Input.is_action_just_pressed("ui_accept")):
		#Beer touched the sensor area
		if (beer_enter):
			$player.frame = 1
			#Reinit
			beer_enter = false
			beer_got = true
			tiempo_got = 0.0
		#In this case check we do it in correct time
		elif (beer_got):
			
			#Reinit
			beer_got = false
			#If got in time, good, if not -hurt
			if (timeA <= tiempo_got and tiempo_got <= timeB):
				$player.frame = 2
			else:
				$player.frame = 0
				vida -= 1
				corazones.eliminar_vida()
		else: #Press in bad moment
			$player.frame = 0
			vida -= 1
			corazones.eliminar_vida()
	
	
	
	#If we hold the beer too much without drink, bad
	if (beer_got and tiempo_got >= timeB):
		vida -= 1
		corazones.eliminar_vida()
		beer_got = false
		$player.frame = 0
			
	
	
	

#Area that checks beer entering
func _on_Area2D_area_entered(area):
	beer_enter = true


func _on_Area2D_area_exited(area):
	area.queue_free()
	beer_enter = false
	#If we didn't got it, hurt player
	if (not beer_got):
		vida -= 1
		corazones.eliminar_vida()

