extends Node2D

# Visual novel parser: this script reads text files
# and makes the dialogues.  

const gpath = "res://vn_engine/ginfo.txt"
const mpath = "res://vn_engine/main.txt"

var paths = {}
var ch_names = {}
var offset = {}
var ch_scale = {}
#Stores all paths and names to load them accordingly
#const paths = {"D_Contento":DIOS_CONTENTO, "D_Normal":DIOS_NORMAL}
#const ch_names = {"D_Contento":"Dios", "D_Normal":"Dios"}

#Default position of each slot
var slot_pos = []

#Reference to the dialog box:
var dialogbox_class = preload("res://vn_engine/dialogbox.tscn")
var dialogbox

#Shortcut to the sprites of the scene, "slotX"
var sprites
var showing = [false, false, false, false] #Array of bools to control show/hide anims
var hiding = [false, false, false, false]
var m_speed = 5.0 #Speed of fade

#An array that stores all the currently used...
var tex_array = {} #...textures
var names_array = [] #...names


#cf[j] stores the jth line of the dialogue
var cf
var linec #Current line of the dialogue

#In order to work with the variables of the metalanguage
var vnglobal

#Branching and decision-making
var in_decision = false #Is the player choosing an option now?
var selected_index #Current option chosen
var n_options #Number of available options
var tag_options #Stores tags of the options 


#Set initially only process to input
func _ready():
	#Locate graphics
	set_up_graphics()
	
	#Store all sprites
	sprites = $sprites.get_children()
	
	#Store default positions of slots
	for s in sprites:
		slot_pos.append(s.position)
	
	#Get the dialogbox
	dialogbox = dialogbox_class.instance()
	add_child(dialogbox)
	
	#Start VNGlobal
	vnglobal = get_tree().root.get_node("/root/vn_global")
	
	#Set process
	set_process(false)
	set_physics_process(false)
	set_process_input(true)
	
	#Open the file and start
	start_dialogue(mpath)
	next_step()


#The process is for doing animations
func _process(delta):
	
	#Check each slot
	for j in range(4):
		
		#If it fading in/out, modify modulation
		if (showing[j]):
			sprites[j].modulate.a += m_speed * delta
			
			#At the end, disable and check if there 
			#is other slots still working
			if (sprites[j].modulate.a >= 0.98):
				sprites[j].modulate.a = 1.0
				showing[j] = false
				check_process()
		
		elif (hiding[j]):
			sprites[j].modulate.a -= m_speed * delta
			
			if (sprites[j].modulate.a <= 0.02):
				sprites[j].modulate.a = 0.0
				hiding[j] = false
				check_process()


#Every time you get a click, advance. Also check options
func _input(event):
	
	if (event.is_action_pressed("ui_accept")):
		if (not in_decision):
			next_step()
		else:
			#Finish decision
			in_decision = false
			dialogbox.option_chosen()
			jump_to_tag(selected_index)
			next_step()
	
	#To move between decisions
	if (in_decision):
		#Increase/decrease index, checking bounds so it is in [0,n_options-1]
		if (event.is_action_pressed("ui_up")):
			selected_index -= 1
			selected_index = max(selected_index, 0)
		elif (event.is_action_pressed("ui_down")):
			selected_index += 1
			selected_index = min(selected_index, n_options-1)

		
		#Update marker
		dialogbox.mark_option(selected_index)

#Load a file that stores all the information of the 
#graphics and names in a dictionary
func set_up_graphics():
	var line
	var prefix
	var g = File.new()
	
	g.open(gpath, File.READ)
	
	#Read first line and ensure format
	line = g.get_line()
	line = line.split(";")
	for j in range(len(line)):
		line[j] = get_arg(line[j])
	
	#First line first
	#Check if it is prefix, in that case save it
	if (line[0] == "#PREFIX"):
		prefix = line[1] 
	else:
		#Load name and path
		ch_names[line[0]] = line[1]
		paths[line[0]] = prefix+line[2]
		
		#Offset is an optional parameter
		if (len(line) > 3):
			offset[line[0]] = Vector2(float(line[3]), float(line[4]))
		else:
			offset[line[0]] = Vector2(0.0, 0.0)
		if (len(line) == 6):
			ch_scale[line[0]] = float(line[5])
		else:
			ch_scale[line[0]] = 1.0
	
	
	#Read all the file
	while (not g.eof_reached()):
		line = g.get_line()
		line = line.split(";")
		
		#Check this is a valid line
		if (len(line) >= 3):
			for j in range(3):
				line[j] = get_arg(line[j])
			
			ch_names[line[0]] = line[1]
			paths[line[0]] = prefix+line[2]
			
			if (len(line) > 3):
				offset[line[0]] = Vector2(float(line[3]), float(line[4]))
			else:
				offset[line[0]] = Vector2(0.0, 0.0)
			
			if (len(line) == 6):
				ch_scale[line[0]] = float(line[5])
			else:
				ch_scale[line[0]] = 1.0
	
	
	g.close()
	

#These two functions load the textures we are going to
#need, or unload the non-necessary ones. 
#It is useful to save memory, since textures are large!
func load_textures(command):
	
	tex_array = {}
	names_array = ["", "", "", ""] #Init with size 4
	
	var n_char = len(command) - 1
	
	for j in range(1, n_char+1):
		var arg = get_arg(command[j])
		tex_array[arg] = load(paths[arg])

#Auxiliary function that assign a character texture
#to one of the sprites of the scene, or that eliminates it
func draw_character(command):
	
	#Get the character and slot where it will be drawn
	var ch = get_arg(command[1])
	#To ensure common notation with dialogues, -1
	var pos = int(get_arg(command[2]))-1 
	var fade
	
	#Third argument is optional and false by default
	if (len(command) == 4):
		fade = get_arg(command[3]) == "true"
	else:
		fade = false
	
	print(ch_names)
	print(ch)
	print(pos)
	print(names_array)
	#Set the name corresponding to this character
	names_array[pos] = ch_names[ch]
	
	#Set the texture and the offset
	sprites[pos].texture = tex_array[ch]
	sprites[pos].position = slot_pos[pos] + offset[ch]
	sprites[pos].scale = Vector2(0.2,0.2) * ch_scale[ch]
	#TODO: AJUSTAR BIEN ESTO CON LOS TAMAÑOS
	
	if (fade):
		#Start transparent and set a texture
		sprites[pos].modulate=Color(1,1,1,0.0)
		
		#Add to the animation procedure
		showing[pos] = true 
		set_process(true)
	else:
		#Start with color from the beginning
		sprites[pos].modulate=Color(1,1,1,1)

#Hides a slot with a fade out
func hide_character(command):
	#To ensure common notation with dialogues, -1
	var pos = int(get_arg(command[1]))-1 
	
	#Start the fade out
	hiding[pos] = true
	set_process(true)

#Make a fade in/out
func fade(is_in):
	if (is_in):
		$anim.play("screen_fade_in")
	else:
		$anim.play("screen_fade_out")
	

#Set the background
func set_bg(command):
	var bgname = get_arg(command[1])
	
	$bg.texture = load(paths[bgname])

#Returns false if there is no slot doing fade in/out
#If nobody is doing it, the process is turned off
func check_process():
	var result = false
	
	var j = 0
	
	while (j < 4 and not result):
		result = result or showing[j] or hiding[j]
		j += 1
	
	set_process(result)

#Used to parse the arguments given when doing a branch
#This will store all the information and start the decision dialog
func parse_options(command):
	#How many options do we have?
	n_options = int(get_arg(command[1]))
	
	#Restart tag array
	tag_options = []
	
	#Start the file from the beginning!
	#So tag can be found everywhere
	linec = 0
	
	var options = ""
	#Auxiliary stuff
	var c_index
	var arg1
	var arg2
	#Load all options
	for j in range(n_options):
		#x2 so options get even numbers. +1 to start with c_index=2
		c_index = (j+1) * 2
		arg1 = get_arg(command[c_index])
		arg2 = get_arg(command[c_index+1])
		
		options = options + "\n" + arg1  #One option per line
		tag_options.append(arg2)
	
	#Since initialized options as "", first character is "\n". Get rid of it
	options = options.substr(1, len(options)-1)
	
	#Put it in decision, and set selected index
	in_decision = true
	selected_index = 0
	
	dialogbox.set_options(options)
	dialogbox.mark_option(selected_index)

#Checks the value of a variable and makes a jump 
#depending on the specified condition
func meta_if(command):
	
	#Parse condition and obtain if it is true/false
	var condition = vnglobal.if_var(command[1])
	
	#Write the options
	var opt1 = get_arg(command[2])
	var opt2 = get_arg(command[3])
	tag_options = [opt1, opt2]
	
	
	#Select correct tag
	if (condition):
		jump_to_tag(0,true)
	else:
		jump_to_tag(1,true)

#Takes the file and jump lines until we get to the desired point
#Does effectively the branching when player selects a decision
func jump_to_tag(index, skip=false):
	var tag = "%" + tag_options[index] #Get the tag
	var command 
	var line
	var c0 
	
	#Start the file from the beginning!
	#So tag can be found everywhere
	linec = 0
	
	#Read next line and get the command
	line = cf[linec]
	command = line.split(";")
	c0 = get_arg(command[0])
	
	#If the command is not %tag, skip lines until desired one
	if (c0 != tag):
		while (c0 != tag):
			line = cf[linec]
			command = line.split(";")
			c0 = get_arg(command[0])
			linec += 1
		#When using the skip command, pressing the button
		#jumps over a line automatically -correct this
		if (skip):
			linec -= 1
	else: #Case where exactly the next one is the tagged
		linec += 1 #Skip the line with %tag

#Open the file, store each line in a variable
func start_dialogue(filename):
	
	var file = File.new()
	
	#Load the entire file into the cf 
	file.open(filename, File.READ)
	cf = file.get_as_text().split("\n")
	file.close()
	
	linec = 0 #Restart line counter



#Parse new lines until text appears
func next_step():
	
	while(parse_line()):
		pass 


#The master function of the engine. This reads each line
#the file and makes all the dark magic associated with the
#commands
func parse_line():
	
	#Determines when a command is not a text command
	#and next line should be immediately parsed
	var next = false
	
	var line = cf[linec] #Get the next line
	
	#Jump over empty lines
	if (len(line) == 0):
		linec += 1
		return true
	
	#Ignore comments
	if (line[0] == "#"):
		next = true
	else:
		#Store command 
		var command = line.split(";")
		var c0 = command[0]
		var c1 #To get the argument
		
		var ic0 = int(c0) #0 if c0 is not a integer
		
		#Use this to detect a dialogue
		if (1 <= ic0 and ic0 <= 4):
			c1 = get_arg(command[1])
			
			dialogbox.set_text(ic0, names_array[ic0-1], c1)
			next = false
		else:
			next = true
			#Jump and read a different file
			if (c0 == "jump"):
				c1 = get_arg(command[1])
				start_dialogue(c1)
			#Load textures of characters
			elif (c0 == "load"):
				load_textures(command)
			#Show or hide a character in a slot
			elif (c0 == "show"):
				draw_character(command)
			elif (c0 == "hide"):
				hide_character(command)
			#Set a background
			elif (c0 == "set_bg"):
				set_bg(command)
			#Fade in/out
			elif (c0 == "fade_in"):
				fade(true)
			elif (c0 == "fade_out"):
				fade(false)
				next = false
			#Value of variable
			elif (c0 == "set"):
				c1 = get_arg(command[1])
				var c2 = get_arg(command[2])
				vnglobal.set_var(c1, c2)
				print(vnglobal.vars)
			elif (c0 == "add"):
				c1 = get_arg(command[1])
				var c2 = get_arg(command[2])
				vnglobal.add_var(c1, c2)
			elif (c0 == "if"):
				meta_if(command)
			#Find tag
			elif (c0 == "goto"):
				c1 = get_arg(command[1])
				tag_options = [c1]
				jump_to_tag(0, true)
			#Show a conditional to choose. 
			elif (c0 == "do_branch"):
				next = false
				parse_options(command)
			#Start a minigame
			elif (c0 == "load_scene"):
				next = false
				c1 = get_arg(command[1])
				vnglobal.vn_to_scene(self, c1)
			#Finish app
			elif (c0 == "end"):
				next = false
				get_tree().quit()
			else:
				pass #Raise error maybe
	
	linec += 1 #Increase our position by one line
	
	return next

#Return the argument of the command without any spaces
#at the edges of the string
func get_arg(command):
	return command.strip_edges()

