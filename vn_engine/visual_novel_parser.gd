extends Node2D

# Visual novel parser: this script reads text files
# and makes the dialogues.  

#Reference to the dialog box:
var dialogbox_class
var dialogbox

#Constants that identify the characters
const DIOS = 0
const PADRE = 1
const HIJE = 2

#Names of the characters. The order must be the same
#as the ones stated above:
const ch_names = ["Dios", "Padre", "Hijo"]

#Constants that store paths to all graphics in game
const gpath = "res://vn_engine/graphics/"
const DIOS_NORMAL = gpath + "dios_normal.png"
const DIOS_CONTENTO = gpath + "dios_contento.png"

#Shortcut to the sprites of the scene, "slotX"
var sprites

#An array that stores all the currently used...
var tex_array = [] #...textures
var names_array = [] #...names

#cf[j] stores the jth line of the dialogue
var cf
var linec #Current line of the dialogue

#Set initially only process to input
func _ready():
	
	#Store all sprites
	sprites = $sprites.get_children()
	
	set_process(false)
	set_physics_process(false)
	set_process_input(true)
	
	load_textures([null, null], [ch_names[DIOS], ch_names[HIJE]])
	start_dialogue("prueba.txt")
	parse_line()
	parse_line()
	parse_line()


#The process is for doing animations
func _process(delta):
	pass

#Every time you get a click, advance. Also check options
func _input(event):
	pass



#These two functions load the textures we are going to
#need, or unload the non-necessary ones. 
#It is useful to save memory, since textures are large!
func load_textures(path_array, n_array):
	var n_char = len(path_array) #Get number of used slots
	
	#Load textures and names
	for j in range(n_char):
		#tex_array.append(load(path_array[j]))
		names_array.append(n_array[j])

func dispose_textures():
	tex_array = []
	names_array = []

#Auxiliary function that assign a character texture
#to one of the sprites of the scene, or that eliminates it
func draw_character(ch, pos):
	sprites[pos].texture = tex_array[ch]


#TODO: add a fade-out
func hide_character(pos):
	sprites[pos].texture = null

#Open the file, store each line in a variable
func start_dialogue(filename):
	
	var file = File.new()
	
	#Load the entire file into the cf 
	file.open("res://visual_novel/" + filename, File.READ)
	cf = file.get_as_text().split("\n")
	file.close()
	
	linec = 0 #Restart line counter

#The master function of the engine. This reads each line
#the file and makes all the dark magic associated with the
#commands
func parse_line():
	
	var line = cf[linec] #Get the next line
	
	#Ignore comments
	if (line[0] == "#"):
		pass
	else:
		#Store command 
		var command = line.split(";")
		var c0 = command[0]
		var c1 #To get the argument
		
		var ic0 = int(c0) #0 if c0 is not a integer
		
		#Use this to detect a dialogue
		if (1 <= ic0 and ic0 <= 4):
			c1 = get_arg(command[1])
			
			print(names_array[ic0-1]) 
			print(c1)
		else:
			#Jump and read a different file
			if (ic0 == "jump"):
				c1 = get_arg(command[1])
				start_dialogue(c1)
			#Show a conditional to choose. 
			elif (ic0 == "show_conditions"):
				pass
				#TODO: ADD ARGS:
				#N_CONDITIONS; COND_1; TAG_1; ... COND_N; TAG_N
				#JUMP LINES UP TO %TAG_N
			#Start a minigame
			elif (ic0 == "minigame"):
				#TODO START MINIGAME
				pass
			else:
				pass #Raise error maybe
	
	linec += 1 #Increase our position by one line

#Return the argument of the command without any spaces
#at the edges of the string
func get_arg(command):
	return command.strip_edges()