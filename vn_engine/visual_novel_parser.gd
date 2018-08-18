extends Node2D

# Visual novel parser: this script reads text files
# and makes the dialogues.  

#Reference to the dialog box:
var dialogbox_class = preload("res://vn_engine/dialogbox.tscn")
var dialogbox

#Constants that identify the characters
const DIOS = 0
const PADRE = 1
const HIJE = 2

#Constants that store paths to all graphics in game
const gpath = "res://vn_engine/graphics/"
const DIOS_NORMAL = gpath + "dios_normal.png"
const DIOS_CONTENTO = gpath + "dios_contento.png"

#Stores all paths and names to load them accordingly
const paths = {"D_Contento":DIOS_CONTENTO, "D_Normal":DIOS_NORMAL}
const ch_names = {"D_Contento":"Dios", "D_Normal":"Dios"}
#Shortcut to the sprites of the scene, "slotX"
var sprites

#An array that stores all the currently used...
var tex_array = [] #...textures
var names_array = [] #...names

#cf[j] stores the jth line of the dialogue
var cf
var linec #Current line of the dialogue

#Branching and decision-making
var in_decision = false #Is the player choosing an option now?
var selected_index #Current option chosen
var n_options #Number of available options
var tag_options #Stores tags of the options 


#Set initially only process to input
func _ready():
	
	#Store all sprites
	sprites = $sprites.get_children()
	
	#Get the dialogbox
	dialogbox = dialogbox_class.instance()
	add_child(dialogbox)
	
	set_process(false)
	set_physics_process(false)
	set_process_input(true)
	
	#load_textures([null, null], [ch_names[DIOS], ch_names[HIJE]])
	start_dialogue("prueba.txt")
	next_step()



#The process is for doing animations
func _process(delta):
	pass

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




#These two functions load the textures we are going to
#need, or unload the non-necessary ones. 
#It is useful to save memory, since textures are large!
func load_textures(command):
	
	tex_array = []
	names_array = []
	
	var n_char = len(command) - 1
	
	for j in range(1, n_char+1):
		var arg = get_arg(command[j])
		tex_array.append(load(paths[arg]))
		names_array.append(ch_names[arg])

#Auxiliary function that assign a character texture
#to one of the sprites of the scene, or that eliminates it
func draw_character(command):
	
	#Get the character and slot where it will be drawn
	var ch = int(get_arg(command[1]))
	#To ensure common notation with dialogues, -1
	var pos = int(get_arg(command[2]))-1 
	
	#Set to sprite
	sprites[pos].texture = tex_array[ch]

#TODO: add a fade-out
func hide_character(pos):
	sprites[pos].texture = null

#Used to parse the arguments given when doing a branch
#This will store all the information and start the decision dialog
func parse_options(command):
	#How many options do we have?
	n_options = int(get_arg(command[1]))
	print(n_options)
	#Restart tag array
	tag_options = []
	
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
	print(options)
	#Put it in decision, and set selected index
	in_decision = true
	selected_index = 0
	
	dialogbox.set_options(options)
	dialogbox.mark_option(selected_index)

#Takes the file and jump lines until we get to the desired point
#Does effectively the branching when player selects a decision
func jump_to_tag(index, skip=false):
	var tag = "%" + tag_options[index] #Get the tag
	var command 
	var line
	var c0 
	
	#Read next line and get the command
	line = cf[linec]
	command = line.split(";")
	c0 = get_arg(command[0])
	print(line)
	#If the command is not %tag, skip lines until desired one
	if (c0 != tag):
		while (c0 != tag):
			line = cf[linec]
			print(line)
			print(linec)
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
	file.open("res://visual_novel/" + filename, File.READ)
	cf = file.get_as_text().split("\n")
	file.close()
	
	linec = 0 #Restart line counter

#Parse the options for making decisions


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
			#print(names_array[ic0-1]) 
			#print(c1)
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
				pass
			#Skip lines until tag is reached
			elif (c0 == "skip"):
				c1 = get_arg(command[1])
				tag_options = [c1]
				jump_to_tag(0, true)
			#Show a conditional to choose. 
			elif (c0 == "do_branch"):
				next = false
				parse_options(command)
				#TODO: ADD ARGS:
				#N_CONDITIONS; COND_1; TAG_1; ... COND_N; TAG_N
				#JUMP LINES UP TO %TAG_N
			#Start a minigame
			elif (c0 == "minigame"):
				#TODO START MINIGAME
				pass
			else:
				pass #Raise error maybe
	
	linec += 1 #Increase our position by one line
	
	return next

#Return the argument of the command without any spaces
#at the edges of the string
func get_arg(command):
	return command.strip_edges()

