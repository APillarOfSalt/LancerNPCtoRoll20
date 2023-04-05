extends VBoxContainer

var npcClasses : Array
var npcFeatures : Array
var npcTemplates : Array
#var fLoc : String = "res://data/"

func _ready() -> void:
	pass
#	var d = Directory.new()
#	var f = File.new()
#	#load lcp data
#	d.open(fLoc)
#	d.list_dir_begin(true, true)
#	var noData = [true,true,true]
#	while true:
#		var path = d.get_next()
#		if path == "":
#			break
#		f.open(fLoc + path, File.READ)
#		var s = f.get_as_text()
#		var data = JSON.parse(s).result
#		match path:
#			"npc_classes.json":
#				npcClasses = data
#				noData[0] = false #!noData = loadedData
#			"npc_features.json":
#				npcFeatures = data
#				noData[1] = false
#			"npc_templates.json":
#				npcTemplates = data
#				noData[2] = false
#			"tagsStored.json":
#				get_parent().tagsData = data
#	get_parent().loadedData = noData
#	if noData[0] or noData[1] or noData[2]:
#		get_parent().get_node("ConfirmationDialog").popup()
#		f.close()
#	d.list_dir_end()
#	optionPop()


func optionPop():
	$h/o.clear()
	$h/o.add_item("Choose One" , 0)
	#clear any previously showing npc copy data
	for scroll in $h2.get_children():
		var vBox = scroll.get_children()[0]
		for ch in vBox.get_children():
			ch.queue_free()
	
	#populate the option buttons
	for c in npcClasses:
		var s = c.name.left(1) + c.name.right(1).to_lower()
		$h/o.add_item(s)
	$h/o.add_separator()
	for t in npcTemplates:
		var s = t.name.left(1) + t.name.right(1).to_lower()
		$h/o.add_item(s)

var allF : Dictionary = {
	"base" : [],
	"opt" : []
}


var currentClass : int = -1
# ~~~ main refresh data function ~~~
func _on_o_item_selected(index: int) -> void:
	#check if choose one is still there
	if $h/o.get_item_text(0) == "Choose One":
		$h/o.remove_item(0)
		$h/o.selected = index-1
		index -= 1
	currentClass = index
	#delete old nodes
	for scroll in $h2.get_children():
		var vBox = scroll.get_children()[0]
		for ch in vBox.get_children():
			ch.queue_free()
	
	#make new info and nodes
	var dict : Dictionary
	#check if its a template or Class
	if index < npcClasses.size(): #if its a class
		dict = npcClasses[index]
		$stats.changeAll(dict.stats, get_parent().tier)
		$stats.visible = true
	else: #if its a template
		dict = npcTemplates[index-npcClasses.size()-1]
		$stats.visible = false
	#populate the text
	for f in dict.base_features:
		var sF = searchFeatures(f)
		allF.base.append(sF)
		makeNewText(sF, false)
	for f in dict.optional_features:
		var sF = searchFeatures(f)
		allF.opt.append(sF)
		makeNewText(sF, true)

func makeNewText(txt : String, toggle : bool):
	var nd = $r.duplicate()
	if toggle: #optional
		$h2/s1/v.add_child(nd)
	else: #base
		$h2/s0/v.add_child(nd)
	nd.visible = true
	nd.changeText(txt)

func searchFeatures(f : String):
	for i in npcFeatures:
		var string : String = ""
		if i.id == f:
			match i.type:
				"Weapon":
					return get_parent().weaponPasta(i)
				"System":
					return get_parent().systemPasta(i)
				"Trait":
					return get_parent().systemPasta(i)
				"Tech":
					if i.has("attack_bonus"):
						return get_parent().weaponPasta(i)
					else:
						return get_parent().systemPasta(i)
				"Reaction":
					return get_parent().reactionPasta(i)
				_:
					return ""
