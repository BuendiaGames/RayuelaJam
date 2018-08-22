extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

#var vel = Vector2 (0.0,0.0)

var speed = 100



func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	position.x += speed*delta
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
