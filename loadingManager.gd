extends HBoxContainer


func popup():
	pathArr = ["","","",""]
	greenLabels([false,false,false,false])
	self.show()
	$fileDialog.popup()
	timerBool = false #timer is signaling that the file dialog is being shown
	$Timer.start()

func hideMe():
	visible = false
	$fileDialog.hide()

#popup this and the fileDialog

#close this popup and the fileDialog

func _ready():
	greenLabels([false,false,false,false])


var pathArr = ["","","",""]
func _on_fdClass_files_selected(paths: PackedStringArray) -> void:
#	check file name to see if it matches
	for s in paths:
		match s.get_file():
			"lcp_manifest.json":
				pathArr[0] = s
			"npc_classes.json":
				pathArr[1] = s
			"npc_features.json":
				pathArr[2] = s
			"npc_templates.json":
				pathArr[3] = s
	var arr : Array
	for d in pathArr:
		arr.append(d != "")
	greenLabels(arr)
	
	var falseToggle = true
	for bol in arr:
		if !bol:
			falseToggle = false
	if !falseToggle:
		timerBool = true #timer is being used to pop the file dialog back up
		$Timer.start()
	
	if arr == [true, true, true, false] or [true, true, true, true]:
		$v/p/save.disabled = false
	else:
		$v/p/save.disabled = true
	

func greenLabels(data : Array):
	if data[0]:
		$v/p/v/man.set("theme_override_colors/font_color", Color.GREEN)
	else:
		$v/p/v/man.set("theme_override_colors/font_color", Color.RED)
	if data[1]:
		$v/p/v/cla.set("theme_override_colors/font_color", Color.GREEN)
	else:
		$v/p/v/cla.set("theme_override_colors/font_color", Color.RED)
	if data[2]:
		$v/p/v/fea.set("theme_override_colors/font_color", Color.GREEN)
	else:
		$v/p/v/fea.set("theme_override_colors/font_color", Color.RED)
	if data[3]:
		$v/p/v/tem.set("theme_override_colors/font_color", Color.GREEN)
	else:
		$v/p/v/tem.set("theme_override_colors/font_color", Color.RED)



func _on_save_pressed() -> void:
	var f = FileAccess.open(pathArr[0], FileAccess.READ)
	var s = f.get_as_text()
	var data = JSON.parse_string(s)
	f.close()
	
	var d = DirAccess.open("user://savedLCPs")
	d.list_dir_begin()
	if !d.dir_exists(data.name):
		d.make_dir(data.name)
		#d.change_dir("user://savedLCPs/" + data.name)
		for p in pathArr:
			if p != "":
				d.copy(p ,"user://savedLCPs/" + data.name + "/" + p.get_file())
	d.list_dir_end()
	Glo.loadAllLCPs(true)
	hideMe()

func _on_b_pressed() -> void:
	if visible:
		hideMe()
	else:
		popup()

#the timer ending signals: false: fileDialog popped up,  true: re-popup file dialog
var timerBool : bool = false
func _on_Timer_timeout() -> void:
	if timerBool:
		$fileDialog.show()
		show()
	else:
		resizePopup()

func resizePopup():
	var xy : Vector2i = Vector2i($MagicNumber2.size.x, $v/MagicNumber.size.y)
	var margins : Vector2i = Vector2i(xy.x, xy.x*2)
	var xx : int = $v.position.x - $fileDialog.position.x
	var yy : int = DisplayServer.window_get_size().y
	$fileDialog.position = xy
	$fileDialog.size = Vector2i(xx,yy) -margins -$fileDialog.position

func _on_file_dialog_canceled():
	hideMe()
