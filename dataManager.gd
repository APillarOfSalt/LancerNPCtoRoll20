extends MarginContainer

onready var ui = $textAssembly/uiHandler

func windowResized():
	rect_size = OS.get_window_size()

var config

func _ready() -> void:
	#pop self into the lcp enable disable menu so it can change data here
	$textAssembly/uiHandler/h/a.bigDaddy = self
	#size to screen
	get_tree().get_root().connect("size_changed", self, "windowResized")
	windowResized()
	
	#fix confirmation dialog button
	$ConfirmationDialog.get_cancel().text = "Close"
	
	#open saved config
	var dir = Directory.new()
	dir.open("user://")
	dir.list_dir_begin()
	var fileName = dir.get_next()
	var file = File.new()
	if !dir.file_exists("config.json"): #if no config file exists yet
		file.open("user://config.json", File.WRITE)
		config = {"theme" : "gms"}
		file.store_line(to_json(config))
		$ConfirmationDialog.popup()
	else:
		file.open("user://config.json", File.READ)
		config = JSON.parse(file.get_line()).result 
		file.close()
		if config == null:
			config = {}
		if config.size() == 0:
			config.theme = "gms"
			file.open("user://config.json", File.WRITE)
			file.store_line(to_json(config))
			file.close()
			$ConfirmationDialog.popup()
		else: #check if a default style is saved
			if config.has("theme"):
				Glo.defaultStylebox = Glo.styleboxes[config.theme]
				get_tree().call_group("stylebox", "swapStyle", Glo.defaultStylebox)
				var sel = 0
				match config.theme:
					"gms" : sel = 0
					"hor" : sel = 1
					"aps" : sel = 2
				$settings/p/v/h/o.selected = sel
	
	#check for saved lcp's
	if !dir.dir_exists("savedLCPs"): #if no savedLCP folder exists make one
		dir.make_dir("user://savedLCPs")
	else:
		loadAllLCPs() #load all lcps
	#check for disabled lcps and move them out of main
	#store all the data for enabled lcps

func lcpIO(named : String, toggle : bool):
	config[named] = toggle
	var f = File.new()
	f.open("user://config.json", File.WRITE)
	f.store_line(to_json(config))
	f.close()
	loadAllLCPs()

func _on_ConfirmationDialog_confirmed() -> void:
	$loader.popup()


var allData : Array #inside are lcpDict's
#lcp dictionary = {
# name : string
# version : int
# classes : dict
# features : dict
# templates : dict
# }


func loadAllLCPs():
	var dir = Directory.new()
	dir.open("user://savedLCPs")
	dir.list_dir_begin(true, true)
	#saved lcps will be in folders check all folders
	var named = dir.get_next()
	while named != "": #check through the savedLCP's folder
		var folder = Directory.new()
		folder.open("user://savedLCPs/" + named) #open folder
		folder.list_dir_begin(true, true)
		var jname = folder.get_next()
		var lcpDict : Dictionary = {
			"name" : "",
			"version" : 0,
			"classes" : [],
			"features" : [],
			"templates" : [],
		}
		while jname.get_extension() == "json": #check through the individual LCP folder
			var file = File.new()
			file.open("user://savedLCPs/" + named + "/" + jname, File.READ) #open each json
			var s = file.get_as_text()
			var data = JSON.parse(s).result
			match jname:
				"lcp_manifest.json":
					lcpDict.name = data.name
					if !config.has(data.name):
						config[data.name] = true
					var ver = data.version
					ver.replace(".","")
					lcpDict.version = int(ver)
				"npc_classes.json":
					lcpDict.classes = data
				"npc_features.json":
					lcpDict.features = data
				"npc_templates.json":
					lcpDict.templates = data
			jname = folder.get_next()
		folder.list_dir_end()
		named = dir.get_next()
		#now that we have this LCP's dictionary fully populated
		#check if its empty
		if !lcpDict.has("name"):
			return
		
		var actuallySaveItToggle : bool = true
		#search current lcp vs any other loaded lcps for duplicates
		for d in allData:
			if d.name == lcpDict.name:
				#if duplicate throw away the older version (old if same)
				if lcpDict.version <= d.version: #if the previously loaded version is newer or the same
					actuallySaveItToggle = false #don't save the new one
				else: #if the previously loaded version is older
					allData.erase(d) #erase old data
		#now that its not a duplicate
		if actuallySaveItToggle:
			#save enabled disabled to config file
			
			allData.append(lcpDict)
	#finished loading saved data
	#allData is formatted as an array of lcpDict's
	#lcpDict's{name, version, classes, features, templates}
	#lcpDict{ name : String, version : int
	#classes, features, templates : all = Array[ of {dictionaries}, ... ]     }
	dir.list_dir_end()
	ui.npcClasses = []
	ui.npcFeatures = []
	ui.npcTemplates = []
	
	$textAssembly/uiHandler/h/a.get_popup().clear()
	#merge all the dictionaries and send them to the ui
	for lcp in allData: #for each lcpDict
		var active = $textAssembly/uiHandler/h/a.get_popup()
		var ind = active.get_item_count()
		active.add_check_item(lcp.name)
		active.set_item_checked(ind, config[lcp.name])
		if config[lcp.name]:
			for cl in lcp.classes:
				ui.npcClasses.append(cl)
			for fe in lcp.features:
				ui.npcFeatures.append(fe)
			for te in lcp.templates:
				ui.npcTemplates.append(te)
	ui.optionPop()



func _on_settings_confirmed(toBeDeleted, toBeEnabled, toBeDisabled) -> void:
	for e in toBeEnabled:
		config[e] = true
	for d in toBeDisabled:
		config[d] = false
	for del in toBeDeleted:
		config.erase(del)
		var dir = Directory.new()
		dir.open("user://savedLCPs")
		dir.list_dir_begin(true, true)
		var fileName = dir.get_next()
		while fileName != "":
			if fileName == del:
				var dir2 = Directory.new()
				dir2.open("user://savedLCPs/" + fileName)
				dir2.list_dir_begin(true, true)
				var fn = dir2.get_next()
				while fn != "":
					dir2.remove(fn)
					fn = dir2.get_next()
				dir.remove(fileName)
			fileName = dir.get_next()
		get_tree().reload_current_scene()
	loadAllLCPs()


func _on_settings_pressed() -> void:
	if $settings.visible:
		$settings.hide()
	else:
		var xy = $textAssembly/uiHandler/h/settings.rect_global_position
		xy += $textAssembly/uiHandler/h/settings.rect_size
		$settings.position = xy
		$settings.get_node("p").rect_position.x = $settings.loadLCPs(allData, config)
		$settings.show()


func _on_settings_themeChanged(style) -> void:
	config.theme = style
	var f = File.new()
	f.open("user://config.json", File.WRITE)
	f.store_line(to_json(config))
	f.close()
