extends VBoxContainer

var npcClasses : Array = []
var npcFeatures : Array = []
var npcTemplates : Array = []
var fLoc : String = "res://data/"

#lcp is formatted as an array of lcpDict's
#lcpDict's{name, version, classes, features, templates}
#lcpDict{ name : String, version : int
#classes, features, templates : all = Array[ of {dictionaries}, ... ]     }
func lcpsLoaded(lcpData : Array):
	npcClasses.clear()
	npcFeatures.clear()
	npcTemplates.clear()
	for dict in lcpData:
		if dict.has("npc_classes"):
			npcClasses.append_array(dict.npc_classes)
		if dict.has("npc_features"):
			npcFeatures.append_array(dict.npc_features)
		if dict.has("npc_templates"):
			npcTemplates.append_array(dict.npc_templates)
	optionPop()

func optionPop():
	$h/o.clear()
	$h/o.add_item("Choose One" , 0)
	#clear any previously showing npc copy data
	for vBox in [$ct/classes/s0/v, $ct/classes/s1/v]:
		for ch in vBox.get_children():
			ch.queue_free()
	
	#populate the option buttons
	for c in npcClasses:
		var s = Glo.firstLetterCapRestLower(c.name)
		$h/o.add_item(s)
	
	$ct.populateTemplates(npcTemplates)

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
	for scroll in $ct/classes.get_children():
		var vBox = scroll.get_children()[0]
		for ch in vBox.get_children():
			ch.queue_free()
	
	#make new info and nodes
	var dict : Dictionary
	dict = npcClasses[index]
	$stats.changeAll(dict.stats, get_parent().tier)
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
	var nd = preload("res://txt.tscn").instantiate()
	if toggle: #optional
		$ct/classes/s1/v.add_child(nd)
	else: #base
		$ct/classes/s0/v.add_child(nd)
	nd.visible = true
	nd.changeText(txt)

func searchFeatures(f : String):
	for i in npcFeatures:
		var string : String = ""
		var sensors = -1
		if i.id == f:
			match i.type:
				"Weapon":
					return get_parent().npcWeaponPasta(i)
				"System":
					return get_parent().systemPasta(i)
				"Trait":
					return get_parent().systemPasta(i)
				"Tech":
					if i.has("attack_bonus"):
						return get_parent().npcWeaponPasta(i)
					else:
						return get_parent().systemPasta(i)
				"Reaction":
					return get_parent().reactionPasta(i)
				_:
					return ""
