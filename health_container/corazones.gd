extends Node2D

#Number of hearts
export var maxvida = 3

#Store texture and distance between them
const textura = preload("res://graficos/corazon.png")
const offset = 24

func _ready():
	
	
	#Create maxvida hearts, position them and add
	var corazon
	for j in range(maxvida):
		corazon = Sprite.new()
		corazon.texture = textura
		corazon.position.x = j * offset
		add_child(corazon)
	
	set_process(false)


#Set the number of hearts to create
func set_vida(vida):
	maxvida = vida


#Delete the last one when eliminating it
#TODO play sound
func eliminar_vida():
	get_child(get_child_count()-1).queue_free()
