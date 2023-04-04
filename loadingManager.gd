extends HBoxContainer


func popup():
	pathArr = ["","","",""]
	greenLabels([false,false,false,false])
	visible = true
	$fileDialog.popup()

func hide():
	visible = false
	$fileDialog.hide()

#popup this and the fileDialog

#close this popup and the fileDialog

func _ready():
	greenLabels([false,false,false,false])


var pathArr = ["","","",""]
func _on_fdClass_files_selected(paths: PoolStringArray) -> void:
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
		$Timer.start()
	
	if arr == [true, true, true, false] or [true, true, true, true]:
		$v/p/save.disabled = false
	else:
		$v/p/save.disabled = true
	

func greenLabels(data : Array):
	if data[0]:
		$v/p/v/man.set("custom_colors/font_color", Color.green)
	else:
		$v/p/v/man.set("custom_colors/font_color", Color.red)
	if data[1]:
		$v/p/v/cla.set("custom_colors/font_color", Color.green)
	else:
		$v/p/v/cla.set("custom_colors/font_color", Color.red)
	if data[2]:
		$v/p/v/fea.set("custom_colors/font_color", Color.green)
	else:
		$v/p/v/fea.set("custom_colors/font_color", Color.red)
	if data[3]:
		$v/p/v/tem.set("custom_colors/font_color", Color.green)
	else:
		$v/p/v/tem.set("custom_colors/font_color", Color.red)



func _on_save_pressed() -> void:
	var f = File.new()
	f.open(pathArr[0], File.READ)
	var s = f.get_as_text()
	var data = JSON.parse(s).result
	f.close()
	
	var d = Directory.new()
	d.open("user://savedLCPs")
	if !d.dir_exists(data.name):
		d.make_dir(data.name)
		d.change_dir("user://savedLCPs/")
		for p in pathArr:
			if p != "":
				d.copy(p ,OS.get_user_data_dir() + "/savedLCPs/" + data.name + "/" + p.get_file())
	get_parent().loadAllLCPs()
	hide()

func _on_b_pressed() -> void:
	popup()


func _on_Timer_timeout() -> void:
	$fileDialog.show()
	show()


func _on_fileDialog_popup_hide() -> void:
	hide()
