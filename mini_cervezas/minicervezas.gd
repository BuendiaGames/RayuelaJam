extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var cerveza_class = preload("res://mini_cervezas/cerveza.tscn")

var vida = 3

var tiempo = 0
var tiempobeber = 0

var tiempocogida = 0
var tiempomaxcoger = 0.3
var tiempoentrecerv = 4.0
var tiempoentrebeber = 1.3
var margen = 0.3

var cervpreparada = false
var cervcogida = false
var completado = false



func add_cerveza():
	cervcogida = false
	completado = false
	$player.frame = 0
	var cerv = cerveza_class.instance()
	cerv.position.x = -200
	cerv.position.y = 0
	add_child(cerv)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	tiempo += delta
	
	if (tiempo >= tiempoentrecerv):
		add_cerveza()
		tiempo = 0
		
	if (cervpreparada):
		tiempocogida += delta
		if (Input.is_action_just_pressed("ui_accept")):
			$player.frame = 1
			cervcogida = true
			tiempobeber = 0

	if (cervpreparada and !cervcogida and tiempocogida >= tiempomaxcoger):
		vida -= 1
		print(vida)
		tiempocogida = 0
	
	if (cervcogida):
		tiempobeber += delta
		if (Input.is_action_just_pressed("ui_accept") and tiempobeber >= tiempoentrebeber-margen and tiempobeber <= tiempoentrebeber+margen):
			$player.frame = 2
			completado = true
		elif (!completado and tiempobeber >= tiempoentrebeber+margen):
			vida -= 1
			print(vida)
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
