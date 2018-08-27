extends Node2D


#Music variables
const note_tempo = 60.0 / 210.0 #Time of a single note
var beer_throw = [] #When a beer should be thrown
var beer_index = 0 #Current beer

#Times
var tiempo = 0 #Time counter
var tiempobeber = 0 #Time counter for drinking

var tiempocogida = 0
var tiempomaxcoger = 0.3
var tiempoentrecerv = 4.0 
var tiempoentrebeber = note_tempo#1.3
var margen = 0.1


var cerveza_class = preload("res://mini_cervezas/cerveza.tscn")

var vida = 3



var cervpreparada = false
var cervcogida = false
var completado = false

var corazones #Stores the ui container


#Create a new beer 
func add_cerveza():
	
	cervcogida = false
	completado = false
	
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

func _physics_process(delta):
	tiempo += delta
	
	#Ana's original code
	#if (tiempo >= tiempoentrecerv):
	#	add_cerveza()
	#	tiempo = 0
	
	#Check it is time to throw a beer
	if (beer_index < len(beer_throw)):
		if (tiempo >= beer_throw[beer_index]):
			beer_index += 1 #To next beer
			add_cerveza()
	
	if (cervpreparada):
		tiempocogida += delta
		if (Input.is_action_just_pressed("ui_accept")):
			$player.frame = 1
			cervcogida = true
			tiempobeber = 0

	if (cervpreparada and !cervcogida and tiempocogida >= tiempomaxcoger):
		vida -= 1
		corazones.eliminar_vida()
		tiempocogida = 0
	
	if (cervcogida):
		tiempobeber += delta
		if (Input.is_action_just_pressed("ui_accept") and tiempobeber >= tiempoentrebeber-margen and tiempobeber <= tiempoentrebeber+margen):
			$player.frame = 2
			completado = true
		elif (!completado and tiempobeber >= tiempoentrebeber+margen):
			vida -= 1
			corazones.eliminar_vida()
			tiempobeber = 0
		
	if (vida == 0):
		print("muerto")
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Area2D_area_entered(area):
	tiempocogida = 0
	cervpreparada = true
	pass


func _on_Area2D_area_exited(area):
	cervpreparada = false
	area.queue_free()
	pass # replace with function body
