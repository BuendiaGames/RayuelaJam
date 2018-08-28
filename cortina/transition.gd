extends Node2D

export(String, MULTILINE) var text = "Descripción"

func _ready():
	$description.parse_bbcode(text)
	#Pause the game from the beginning
	get_tree().paused = true
	set_process(true)

#Wait until user presses key, then make anim
func _process(delta):
	if (Input.is_action_just_pressed("ui_accept")):
		$anim.play("start")
		set_process(false)

#Once anim finishes, return to minigame
func _on_anim_animation_finished(anim_name):
	if (anim_name == "start"):
		get_tree().paused = false
		get_parent().resume_pause() #Start music
		queue_free()
