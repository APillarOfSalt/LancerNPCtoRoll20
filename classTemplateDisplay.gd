extends VBoxContainer


#classes starts button_pressed == true
func _on_c_toggled(toggled_on):
	if toggled_on:
		$s/c.disabled = true
		$s/h/t.disabled = false
	$s/h/t.button_pressed = !toggled_on
	$classes.show()
	$Templates.hide()

#templates starts button_pressed == false
func _on_t_toggled(toggled_on):
	if toggled_on:
		$s/c.disabled = false
		$s/h/t.disabled = true
	$s/c.button_pressed = !toggled_on
	$classes.hide()
	$Templates.show()

func populateTemplates(temp : Array):
	$s/h/activeTemplate.clear()
	$s/h/activeTemplate.add_item("Choose One" , 0)
	for t in temp:
		var s = Glo.firstLetterCapRestLower(t.name)
		$s/h/activeTemplate.add_item(s)



var allF : Dictionary = {
	"base" : [],
	"opt" : []
}

func _on_active_template_item_selected(index):
	if $s/h/activeTemplate.get_item_text(0) == "Choose One":
		$s/h/activeTemplate.remove_item(0)
		$s/h/activeTemplate.selected = index-1
		index -= 1
	var dict = get_parent().npcTemplates[index]
	
	#delete old nodes
	for scroll in $Templates.get_children():
		var vBox = scroll.get_children()[0]
		for ch in vBox.get_children():
			ch.queue_free()
	
	var makeNewText = func makeNewText(txt : String, toggle : bool):
		var nd = preload("res://txt.tscn").instantiate()
		if toggle: #optional
			$Templates/s1/v.add_child(nd)
		else: #base
			$Templates/s0/v.add_child(nd)
		nd.visible = true
		nd.changeText(txt)
	var searchFeatures = func searchFeatures(f : String):
		for i in get_parent().npcFeatures:
			var string : String = ""
			if i.id == f:
				var gpa = get_parent().get_parent()
				match i.type:
					"Weapon": return gpa.npcWeaponPasta(i)
					"System": return gpa.systemPasta(i)
					"Trait": return gpa.systemPasta(i)
					"Tech":
						if i.has("attack_bonus"):
							return gpa.npcWeaponPasta(i)
						else:
							return gpa.systemPasta(i)
					"Reaction": return gpa.reactionPasta(i)
					_: return ""
	#populate the text
	for f in dict.base_features:
		var sF = searchFeatures.call(f)
		allF.base.append(sF)
		makeNewText.call(sF, false)
	for f in dict.optional_features:
		var sF = searchFeatures.call(f)
		allF.opt.append(sF)
		makeNewText.call(sF, true)
