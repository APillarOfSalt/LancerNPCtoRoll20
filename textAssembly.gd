extends PanelContainer

@onready var txtRes : Resource = load("res://textResource.gd").new()

func _on_tier_item_selected(index: int) -> void:
	if index == -1:
		tier = max(tier,1)
	tier = index
	if $uiHandler.currentClass >= 0:
		$uiHandler._on_o_item_selected($uiHandler.currentClass)

func _on_o_item_selected(index):
	_on_tier_item_selected(-1)

var tier : int = 0 #0=1,1=2,2=3

func tagAssembler(tags : Array, tie : int = -1) -> String:
	if tags.size():
		var output = " {{TAGS="
		for t in tags:
			var num : int = -1
			if t.has("val"):
				if t.val is int or t.val is float:
					num = int(t.val)
				elif t.val is String:
					num = t.val.substr(1 + (tie*2), 1) #1+(0*2)=1, 1+(1*2)=3, 1+(2*2)=5
				else:
					print(t.val.typeof())
			var a = txtRes.getTag(t.id, num)
			output += a + ", "
		output = output.left(output.length()-2)
		output += "}}"
		return output
	return ""

func accDiffStr(num : int = 0) -> String:
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
	
	var dup = ACCDIFF.duplicate(1)
	var y = -num+7 #mx+b
	dup[0] = dup[y]
	dup[y] = ""
	var output : String = ""
	for i in dup:
		output+=i
	return output


func rangeStr(r : Array = []) -> String:
	if r.size():
		var output : String = ""
		for range in r:
			output += "{{" + range.type + "=[[" + str(range.val) + "]]}}"
		return output
	return ""

func dmgStr(dmg : Array = []) -> String:
	if dmg.size():
		var output = "{{DMG="
		for d in dmg:
			output += "[[" + str(d.damage[tier]) + "]] " + d.type + " "
		output = output.left(output.length()-1)
		return output + "}}"
	return ""



var currentSensors : int = -1
func setSensors(sense : int = -1):
	currentSensors = sense

# Dictionary Structure for NPC weapons
# dict.name : String
# dict.weapon_type : String
# dict.attack_bonus : Array [#,#,#]
# dict.accuracy : Array [#,#,#]
# dict.tags : Array [{ 
#		"id" : String,
#		"val" : int (optional)
#	},
#]
# dict.type : String
# dict.damage : Array [{
#		"type" : String,
#		"damage" : Array [#,#,#]
#	},
#]
# dict.effect : String
# dict.range : Array [{
#		"type" : String,
#		"val" : int
#	},
#]
# dict.on_hit : String

func npcWeaponPasta(dict : Dictionary) -> String:
	#eflip false:Evasion, true:E-Def
	var atkRollStr = func atkRollStr(atkBonus : int, acc : int, eFlip : bool) -> String:
		var output : String = "{{TARGETING=@{target|Target1|name}}} {{ATK=[[ [[d20]] +"
		output += str(atkBonus)
		output += "+ ?{ACC/DIFF"
		output += accDiffStr(acc)
		output += "}]]** v **[[@{target|Target1|autocalc_"
		var s = "evasion}]] Evade }}"
		if eFlip:
			s = "edef}]] E-Defense }}"
		output += s
		return output
	
	dict.name = Glo.firstLetterCapRestLower(dict.name)
	#template and name
	var output : String = "&{template:default} {{name="
	output += dict.name
	if dict.has("weapon_type"):
		output += " (" + dict.weapon_type + ")"
	output += "}}"
	#attack roll if included
	if dict.has("type") and dict.has("attack_bonus"):
		var eDefFlip : bool = (dict.type == "Tech") #false=Evasion, true=E-Defense
		for t in dict.tags:
			if t.id == "tg_smart":
				eDefFlip = true
		var acc : int = 0
		if dict.has("accuracy"):
			acc = dict.accuracy[tier]
		output += atkRollStr.call(dict.attack_bonus[tier], acc, eDefFlip)
	#range or sensors range if included
	if dict.has("range"):
		output += rangeStr(dict.range)
	elif currentSensors > 0:
		output += "{{SENSORS=[["+ str(currentSensors) +"]]}}"
	#damage if included
	if dict.has("damage"):
		output += dmgStr(dict.damage)
	#effect if included
	if dict.has("effect"):
		if dict.effect != "":
			var _str : String = txtRes.parseText(dict.effect, tier)
			output += " {{EFFECT=" + _str + "}}"
	#on hit effect if included
	if dict.has("on_hit"):
		if dict.on_hit != "":
			var _str : String = txtRes.parseText(dict.on_hit, tier)
			output += " {{ON HIT=" + _str + "}}"
	#tags if included
	if dict.has("tags") and dict.has("tier"):
		output += tagAssembler(dict.tags, tier)
	return output

func systemPasta(dict : Dictionary):
	dict.name = Glo.firstLetterCapRestLower(dict.name)
	var tg = ""
	if dict.has("tags"):
		tg = tagAssembler(dict.tags, tier)
	var _str : String = txtRes.parseText(dict.effect, tier)
	return "&{template:default} {{name="+dict.name+"}} {{EFFECT="+_str+"}}" + tg

func reactionPasta(dict : Dictionary) -> String:
	dict.name = Glo.firstLetterCapRestLower(dict.name)
	var tg = ""
	if dict.has("tags"):
		tg = tagAssembler(dict.tags, tier)
	var _str : String = txtRes.parseText(dict.effect, tier)
	return "&{template:default} {{name="+dict.name+"}} {{TRIGGER="+dict.trigger+"}} {{EFFECT="+_str+"}}" + tg
