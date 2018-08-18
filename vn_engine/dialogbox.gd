extends Node2D

const flecha = [-55, -20, 20, 60]

func _ready():
	pass


func set_text(slot,name,text):
	
	#Set the name near to the speaker
	if (slot == 1 or slot == 3):
		$name.position.x = -350
	else:
		$name.position.x = 300
	
	#Change the text in each box
	$name/name.text = name
	
	#Make the newlines and put it into the box
	text = handle_newlines(text)
	$text.parse_bbcode(text)

#Write the content of the options in the dialogbox
func set_options(text):
	#Prepare option dialog
	$name.hide()
	$flecha.show()
	#Set options
	$text.parse_bbcode(text)

#Mark the adequate option
func mark_option(index):
	$flecha.position.y = flecha[index]

#Return to normal display after choosing
func option_chosen():
	$name.show()
	$flecha.hide()

#This effectively handles the newlines of the text
func handle_newlines(text):
	var split = text.split("\\n")
	var texto = split[0]
	
	for j in range(1,len(split)):
		texto += "\n" + split[j]
	
	return texto
