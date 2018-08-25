extends Node2D


var tiempo = 0
var tiempomov = 1.5
var vida = 3
var numsecuencias = 2

var cont = 0

var movactual = 0

var cooldown = 1
var coolup = 1.25

var jefedone = false
var bichosdone = false
var start = false
var seccomplete = false

var secu = []

var corazones #To store ui health

func generar_secuencia(num):
	secu = []
	secu.append(randi() % 4)
	for i in range (1,num):
		var r = randi() % 4
		while (r == secu[i-1]):
			r = randi() % 4 
		secu.append(r)
	
func iniciar():
	movactual = 0
	tiempo = 0
	cont = 0
	jefedone = false
	start = false
	
		
func playerdancing (tiempo, secuactual, secusig):
	#var pressed = false
	if (Input.is_action_just_pressed("ui_up")):
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
	
	if (tiempo >= tiempomov and movactual < len(secu) and !jefedone):
		$jefe.frame = secu[movactual] +1
		movactual += 1
		tiempo = 0
		if (movactual == len(secu)):
			jefedone = true
			movactual = 0
			tiempo = -1
			
		
	if (tiempo >= tiempomov and movactual < len(secu) and jefedone):
		start = true
		for i in $bichos.get_children():
			i.frame = secu[movactual] +1
		movactual += 1
		tiempo = 0
		if (movactual == len(secu)):
			bichosdone = true
			tiempo = -1
	
	if (jefedone):
		if (movactual == len(secu)):
			playerdancing(tiempo, secu[movactual-1], 50)
		else:
			playerdancing(tiempo, secu[movactual-1], secu[movactual])
	
	if (start):
		cont += delta
	
	if (cont >= tiempomov+0.1 and $bichos/bicho1.frame != 0 and start):
		vida -= 1
		corazones.eliminar_vida()
		cont = 0
	
	
	if (bichosdone and tiempo >= tiempomov):
		generar_secuencia(numsecuencias)
		iniciar()
		numsecuencias += 1
	
	if (vida == 0):
		print("muerto")
	
		
		
		
		
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
