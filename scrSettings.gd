extends Position2D

signal confirmed(toBeDeleted, toBeEnabled, toBeDisabled)
signal themeChanged(style)


func _on_o_item_selected(index: int) -> void:
	var style = ""
	match index:
		0: #gms red
			style = "gms"
		1: #horus
			style = "hor"
		2: #salt
			style = "aps"
	Glo.defaultStylebox = Glo.styleboxes[style]
	get_tree().call_group("stylebox", "swapStyle", Glo.defaultStylebox)
	emit_signal("themeChanged", style)

func loadLCPs(data : Array, config : Dictionary) -> int:
	for c in $p/v/lcps/v.get_children():
		if c.name != "copy" and c.name != "Title": #if its not the copy or title
			c.queue_free() #clear it
	for lcp in data:
		var nd = $p/v/lcps/v/copy.duplicate(1)
		nd.show()
		nd.get_node("h/Label1").text = lcp.name
		nd.get_node("h/Label2").text = str(lcp.version)
		var en = nd.get_node("h/Label3")
		if config[lcp.name]: #if the lcp is enabled
			nd.get_node("h/c2").pressed = true
			en.add_color_override("font_color", Color(.25, 1, .25) )
			en.text = "Enabled"
		else: #if the lcp if disabled
			en.add_color_override("font_color", Color(1, .25, .25) )
			en.text = "Disabled"
		nd.get_node("h/c").connect("pressed", self, "deletePressed")
		nd.get_node("h/c2").connect("pressed", self, "enabledPressed")
		$p/v/lcps/v.add_child(nd)
	#set size and location
	var widest = 0
	for c in $p/v/lcps/v.get_children():
		widest = max(c.rect_size.x, widest)
	$p.rect_size.x = widest + 20
	return -widest - 20

var toBeDeleted : Array

func deletePressed():
	for c in $p/v/lcps/v.get_children():
		if c.name != "copy" and c.name != "Title": #if its not the copy or title
			if c.get_node("h/c").pressed: #if the delete button is pressed
				c.add_stylebox_override("panel", Glo.styleboxes.setDel)
				toBeDeleted.append(c.get_node("h/Label1").text)
			else: #if the delete button is not pressed
				c.add_stylebox_override("panel", Glo.styleboxes.set)
				toBeDeleted.erase(c.get_node("h/Label1").text)

var toBeEnabled : Array
var toBeDisabled  : Array

func enabledPressed():
	for c in $p/v/lcps/v.get_children():
		if c.name != "copy" and c.name != "Title": #if its not the copy or title
			var en = c.get_node("h/Label3")
			if c.get_node("h/c2").pressed: #if the enable button is pressed
				en.add_color_override("font_color", Color(.25, 1, .25) )
				en.text = "Enabled"
				toBeEnabled.append(c.get_node("h/Label1").text)
				toBeDisabled.erase(c.get_node("h/Label1").text)
			else:
				en.add_color_override("font_color", Color(1, .25, .25) )
				en.text = "Disabled"
				toBeEnabled.erase(c.get_node("h/Label1").text)
				toBeDisabled.append(c.get_node("h/Label1").text)


func _on_confirm_pressed() -> void:
	emit_signal("confirmed", toBeDeleted, toBeEnabled, toBeDisabled)




func _on_cancel_pressed() -> void:
	hide()
