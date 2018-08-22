extends Node2D


var velsaltoplayer = Vector2(0.0,0.0)

var tiempojuego = 60

var tiempo = 0

var anim

var obs_class = preload("res://mini_escaparguardias/obstaculo.tscn")

func add_obst():
	var obst = obs_class.instance()
	if (randf() < 0.6):
		obst.vel.x = obst.vel1
	else:
		obst.vel.x = obst.vel2
	obst.position.x = 200
	add_child(obst)
	
func saltar(delta):
	if (Input.is_action_just_pressed("ui_accept")):
		velsaltoplayer.y = -3.2
	velsaltoplayer.y += delta*11
	

func _ready():
	randomize()
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	tiempo += delta
	
	if (tiempo > 2):
		add_obst()
		tiempo = 0
	saltar(delta)
	var colision = $player.move_and_collide(velsaltoplayer)
	if (colision):
		if (colision.collider.name != "suelo"):
			$player/AnimationPlayer.stop()
			$player/Sprite.frame = 4
		else:
			change_anim("run")
	else:
		anim = ""
		$player/AnimationPlayer.stop()
		$player/Sprite.frame = 4
	
	tiempojuego -= delta
	if (tiempojuego <= 0):
		print("ganaste")

func _on_guardias_body_entered(body):
	if (body.name == "player"):
		print("muerto")
	pass # replace with function body
	
func change_anim(new_anim):
	if (new_anim != anim):
		anim = new_anim
		$player/AnimationPlayer.play(new_anim)
