extends Node2D


var tiempo = 0 #time running
var tiempomov = 1.5 #time between two movements
var vida = 3 #life of the player
var numsecuencias = 2 # number of sequences, start at 2 and finish at 5

var cont = 0 #auxiliar variable for  controlling no-push keys on dancing
var contaux = 0 #auxiliar variable for controlling no-push keys while dancing on the last movement

var movactual = 0 #index of the actual movement

#up and down margin for the player to push the key
var cooldown = 1 
var coolup = 1.25

var teclapulsada = false

#bools for control in which part are we
var jefedone = false #boss finished dancing
var start = false #player and company start to dance
var bichosdone = false #player and company finished dancing

var secu = [] #array for saving the current sequence 

var corazones #To store ui health

func generar_secuencia(num): #create a new sequence with num movements
	secu = []
	secu.append(randi() % 4)
	for i in range (1,num):
		var r = randi() % 4
		while (r == secu[i-1]): #two consecutive movements can't be the same
			r = randi() % 4 
		secu.append(r)


func iniciar(): #reset variables at the beginning
	movactual = 0
	tiempo = 0
	cont = 0
	contaux = 0
	jefedone = false
	start = false
	bichosdone = false
	

#function for the player dancing
func playerdancing (tiempo, secuactual, secusig):
	#var pressed = false
	if (Input.is_action_just_pressed("ui_up")):
		teclapulsada = true
		$player.frame = 1
		cont = 0
		if (tiempo < cooldown):
			if (secuactual != 0):
				vida -= 1
				corazones.eliminar_vida()
		elif (tiempo > coolup and secusig == 0):
			pass
		else:
			vida -= 1
			corazones.eliminar_vida()
	elif (Input.is_action_just_pressed("ui_down")):
		teclapulsada = true
		cont = 0
		$player.frame = 2
		if (tiempo < cooldown):
			if (secuactual != 1):
				vida -= 1
				corazones.eliminar_vida()
		elif (tiempo > coolup and secusig == 1):
			pass
		else:
			vida -= 1
			corazones.eliminar_vida()
	elif (Input.is_action_just_pressed("ui_left")):
		teclapulsada = true
		cont = 0
		$player.frame = 3
		if (tiempo < cooldown):
			if (secuactual != 2):
				vida -= 1
				corazones.eliminar_vida()
		elif (tiempo > coolup and secusig == 2):
			pass
		else:
			vida -= 1
			corazones.eliminar_vida()
	elif (Input.is_action_just_pressed("ui_right")):
		teclapulsada = true
		cont = 0
		$player.frame = 4
		if (tiempo < cooldown):
			if (secuactual != 3):
				vida -= 1
				corazones.eliminar_vida()
		elif (tiempo > coolup and secusig == 3):
			pass
		else:
			vida -= 1
			corazones.eliminar_vida()

func _ready():
	randomize()
	
	#Store health bar
	corazones = $ui/corazones
	
	$jefe.frame = 0
	for i in $bichos.get_children():
		i.frame = 0
	generar_secuencia(numsecuencias)
	iniciar()
	numsecuencias += 1
	pass

func _process(delta):
	tiempo += delta
	
	#boss dancing
	if (tiempo >= tiempomov and movactual < len(secu) and !jefedone):
		$jefe.frame = secu[movactual] +1
		movactual += 1
		tiempo = 0
		if (movactual == len(secu)):
			jefedone = true
			movactual = 0
			tiempo = -1
			
	#player and company dancing
	if (tiempo >= tiempomov and movactual < len(secu) and jefedone):
		start = true
		for i in $bichos.get_children():
			i.frame = secu[movactual] +1
		movactual += 1
		tiempo = 0
		if (movactual == len(secu)):
			bichosdone = true
			contaux = 0
			tiempo = -1
		#if no key pressed it takes life back
		if (not teclapulsada and movactual > 1):
			vida -= 1
			corazones.eliminar_vida()
		teclapulsada = false
	
	#allow player to move only if the boss is done
	if (jefedone):
		if (movactual == len(secu)):
			playerdancing(tiempo, secu[movactual-1], 50)
		else:
			playerdancing(tiempo, secu[movactual-1], secu[movactual])
	
	#starts contaux
	if (bichosdone):
		contaux += delta
	
	#starts cont
	if (start):
		cont += delta
	
	
	
	#after a time it generates another sequence
	if (bichosdone and tiempo >= tiempomov):
		generar_secuencia(numsecuencias)
		iniciar()
		numsecuencias += 1

	#this kills the player if they lose all the life
	if (vida == 0):
		print("muerto")
	
		
		
		
		
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
