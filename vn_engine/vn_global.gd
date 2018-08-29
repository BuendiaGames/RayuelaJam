extends Node

#This dictionary stores all variables used in metalanguage
var vars = {}

var vn

func _ready():
	pass

#Changes from the VN to the selected scene
func vn_to_scene(the_vn, scene):
	vn = the_vn #Store for future
	get_tree().root.remove_child(vn) #Detach from root
	
	#Load the scene
	var sc_res = load(scene)
	var sc = sc_res.instance()
	get_tree().root.add_child(sc)

func scene_to_vn(the_scene):
	the_scene.queue_free()
	get_tree().root.add_child(vn)
	vn.next_step()

#To modify variables
func set_var(name, value):
	vars[name] = int(value)

func add_var(name, value):
	vars[name] += int(value)


#Parse the conditional
func if_var(condition):
	
	var args
	var name
	var value
	var op
	
	#First we check what kind of condition is
	#Then split accordingly
	if (condition.find("!") != -1):
		args = condition.split("!=")
		op = 0
	elif (condition.find(">") != -1):
		
		if (condition.find("=") != -1):
			args = condition.split(">=")
			op = 1
		else:
			args = condition.split(">")
			op = 2
		
	elif (condition.find("<") != -1):
		
		if (condition.find("=") != -1):
			args = condition.split("<=")
			op = 3
		else:
			args = condition.split("<")
			op = 4
	else:
		args = condition.split("==")
		op = 5
	
	#Fix
	args[0] = args[0].strip_edges() 
	args[1] = args[1].strip_edges()
	
	#See who is the variable and who is the value
	if (vars.has(args[0])):
		name = args[0]
		value = int(args[1])
	else:
		name = int(args[1])
		value = args[0]
	
	print(op)
	print(name)
	print(value)
	print(vars[name])
	
	#Do the comparison
	if (op == 0): return vars[name] != value
	elif (op == 1): return vars[name] >= value
	elif (op == 2): return vars[name] > value
	elif (op == 3): return vars[name] <= value
	elif (op == 4): return vars[name] < value
	elif (op == 5): return vars[name] == value