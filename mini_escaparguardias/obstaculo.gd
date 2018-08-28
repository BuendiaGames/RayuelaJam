extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var perso

var vel1 = -5.0
var vel2 = -3.0

var vel = Vector2(0.0,0.0)


		

func _ready():
	add_to_group("caja")
	pass

func _process(delta):
	
	var colision = move_and_collide(vel)
	
	if (colision):
		if (colision.collider.name == "player"):
			perso = colision.collider
			perso.position.x += vel.x
	if (position.x < -300):
		queue_free()
	
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
