extends PanelContainer


var tagsData
var condData
var tLoc : String = "res://roll20Macros/"

func _ready() -> void:
	var d = Directory.new()
	var f = File.new()
	#load roll20 macros
	d.open(tLoc)
	d.list_dir_begin(true, true)
	while true:
		var path = d.get_next()
		if path.get_extension() == "":
			break
		f.open(tLoc + path, File.READ)
		var data = f.get_as_text()
		match path:
			"conditions.txt":
				condData = data.split("{", true)
			"tags.json":
				tagsData = JSON.parse(data).result
		f.close()
	d.list_dir_end()




var ACCDIFF : Array = [
	"", 			 #0
	"|ACC6, 6d6kh1", #1
	"|ACC5, 5d6kh1", #2
	"|ACC4, 4d6kh1", #3
	"|ACC3, 3d6kh1", #4
	"|ACC2, 2d6kh1", #5
	"|ACC1, 1d6",	 #6
	"|---, 0",		 #7
	"|DIFF1, -1d6",
	"|DIFF2, -2d6kh1",
	"|DIFF3, -3d6kh1",
	"|DIFF4, -4d6kh1",
	"|DIFF5, -5d6kh1",
	"|DIFF6, -6d6kh1", #13
]

func _on_tier_item_selected(index: int) -> void:
	tier = index
	$uiHandler._on_o_item_selected($uiHandler.currentClass)

var tier : int = 0 #0=1,1=2,2=3
func weaponPasta(dict : Dictionary) -> String:
	var output : String = "&{template:default} {{TARGETING=@{target|Target1|name}}} {{name="
	output += dict.name
	if dict.has("weapon_type"):
		output += " (" + dict.weapon_type + ")"
	output += "}} {{ATK=[[ [[d20]] +" +str( dict.attack_bonus[tier] ) + "+ ?{ACC/DIFF"
	
	var dup = ACCDIFF.duplicate(1)
	var y = 7
	if dict.has("accuracy"):
		y = -dict.accuracy[tier]+7 #mx+b
	dup[0] = dup[y]
	dup[y] = ""
	for i in dup:
		output+=i
	output += "}]]** v **[[@{target|Target1|autocalc_"
	var s = "evasion}]] Evade"
	for t in dict.tags:
		if t.id == "tg_smart":
			s = "edef}]] E-Defense"
	if dict.type == "Tech":
		s = "edef}]] E-Defense"
	output += s + " }}"
	
	if dict.has("damage"):
		output += "{{DMG="
		for d in dict.damage:
			output += "[[" + str(d.damage[tier]) + "]] " + d.type + " "
		output = output.left(output.length()-1)
		output += "}}"
	
	if dict.effect != "":
		output += " {{EFFECT=" + dict.effect + "}}"
	
	if dict.has("range"):
		for r in dict.range:
			output += " {{" + r.type + "=[[" + str(r.val) + "]]}}"
	else: 
		output += " {{SENSORS=[[@{npc_sensor}]]}}"
	
	if dict.tags.size():
		output += " {{TAGS="
		for t in dict.tags:
			var a = tagsData[t.id] + ", "
			if t.has("val"):
				var amount = t.val
				if t.val is String: #reliable values are {int/int/int} based off of tier 0{,1int,2/,3int,4/,5int,6}
					amount = t.val.substr(1 + (tier*2), 1) #1+(0*2)=1, 1+(1*2)=3, 1+(2*2)=5
				a = a.replace("X",amount)
			output += a
		output = output.left(output.length()-2)
		output += "}}"
	
	if dict.has("on_hit") and dict.on_hit != "":
		output += " {{ON HIT=" + dict.on_hit + "}}"
	
	return output

func systemPasta(dict : Dictionary):
	var n = dict.name.left(1)
	n += dict.name.right(1).to_lower()
	var tg = ""
	if dict.tags.size():
		tg = " {{TAGS="
		for t in dict.tags:
			var a = tagsData[t.id] + ", "
			if t.has("val"):
				a = a.replace("X",t.val)
			tg += a
		tg = tg.left(tg.length()-2)
		tg += "}}"
	return "&{template:default} {{name="+n+"}} {{EFFECT="+dict.effect+"}}" + tg

func reactionPasta(dict : Dictionary) -> String:
	var n = dict.name.left(1)
	n += dict.name.right(1).to_lower()
	var tg = ""
	if dict.tags.size():
		tg = " {{TAGS="
		for t in dict.tags:
			var a = tagsData[t.id] + ", "
			if t.has("val"):
				a = a.replace("X",t.val)
			tg += a
		tg = tg.left(tg.length()-2)
		tg += "}}"
	return "&{template:default} {{name="+n+"}} {{TRIGGER="+dict.trigger+"}} {{EFFECT="+dict.effect+"}}" + tg
