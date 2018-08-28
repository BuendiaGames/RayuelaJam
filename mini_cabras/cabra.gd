extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var speed = 1.5

var velocidad = Vector2(0.0,0.0)
var aceleracion = Vector2(0.0,0.0)

var tiempotrayectoria = 0

var anim

var player

var encerrada = false


func change_anim(new_anim):
	if (new_anim != anim):
		anim = new_anim
		$AnimationPlayer.play(new_anim)

func eliminar_cabra (): #Sacrificio debe ser una cabra
	if (position.x < -300 or position.x > 300 or position.y < -200 or position.y > 200):
		queue_free()

func set_player (p):
	player = p

func fuerza_repulsiva (delta):
	var r2 = position.distance_squared_to(player.position)
	var f = 1.0/(r2/25000)
	var n = position - player.position
	n = n.normalized()
	aceleracion = f*n
	velocidad += aceleracion*delta

func _ready():
	pass

func _process(delta):
	move_and_collide(velocidad)
	if (velocidad.x != 0 or velocidad.y != 0):
		change_anim("walk")
		if (velocidad.x > 0):
			$Sprite.flip_h = false
		else:
			$Sprite.flip_h = true
	else:
		$AnimationPlayer.stop(true)
		anim = ""
		
	tiempotrayectoria += delta
	
	if (tiempotrayectoria >= 1):
		var dir = randf()
		if (dir < 0.25):
			velocidad.x = speed
			velocidad.y = 0
		elif (dir < 0.5):
			velocidad.x = -speed
			velocidad.y = 0
		elif (dir < 0.75):
			velocidad.x = 0
			velocidad.y = -speed
		else :
			velocidad.x = 0
			velocidad.y = speed
		tiempotrayectoria = 0
	
	fuerza_repulsiva(delta)
	eliminar_cabra()
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
	pass
