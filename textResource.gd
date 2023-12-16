extends Resource
class_name TextResource

func _init():
	textIntSub = textWithTierInts.new()
	condNTags = statusNtag.new()
	html = htmlMarkdown.new()

func getTag(nid, num : int = -1) -> String:
	return condNTags.newRoll20Macro(nid, num)

func parseText(txt : String, tier : int) -> String:
	txt = textIntSub.processText(txt, tier)
	txt = processForConditions(txt)
	return html.processForHTMLmarkdown(txt)

func processForConditions(str: String) -> String:
	for i in condNTags.statuses:
		if str.find(i.name) != -1:
			var _str = condNTags.makeR20toolTip(i.name, i.description)
			str = str.replace(i.name, _str)
	return str

var textIntSub : textWithTierInts
class textWithTierInts:
	#reminder: tier is 0->tier1,  1->tier2,  2->tier3
	func processText(txt : String, tier : int) -> String:
		var arr = arrayForInts(txt)
		var str = processArrayForInts(arr, tier)
		return processForPoorlyWrittenTierInts(str, tier)
	
	func processForPoorlyWrittenTierInts(str : String, tier : int) -> String:
		var arr = Array(str.split("/"))
		for i in arr.size():
			if arr[i].is_valid_int():
				for flip in [-1, 1]:
					var test = null
					var count = ( arr[i+flip].length()-1 ) * ( -min(flip,0) )
					for char in arr[i+flip].length():
						if arr[i+flip][count].is_valid_int():
							test = arr[i+flip][count]
							count += flip
						else:
							break
					if test != null:
						if test.is_valid_int():
							var _s = Array( arr[i+flip].split(test) )
							if flip == -1:
								arr[i] = test + _s.pop_back() + "/" + arr[i] 
							else:
								arr[i] += "/" + test + _s.pop_front()
							arr[i+flip] = "".join(_s)
				print("oop")
				var _arr = validateString(arr[i])
				if _arr != []:
					arr[i] = str(_arr[tier])
		var output : String = arr.pop_front()
		for i in arr.size():
			if !( arr[i].is_valid_int() or arr[i-1].is_valid_int() ):
				output += "/"
			output += arr[i]
		return output
	
	#returns array.size(3) if string "lr" found   else returns array.size(2)
	func splitEm(str : String, lr : String) -> Array:
			var split = Array( str.split(lr, true, 1) )
			if split.size() > 1:
				return [ split[0], lr, split[1] ]
			return [str, ""]
	
	func arrayForInts(str : String, lr : bool = false) -> Array:
		var _s : String = ["{","}"][int(lr)]
		var output : Array = []
		var test : Array = splitEm(str, _s)
		output.append( test.pop_front() )
		output.append( test.pop_front() )
		if test.size():
			output.append_array( arrayForInts( test[0], !lr ) )
		while output.has(""):
			output.erase("")
		return output
	
	func processArrayForInts(arr : Array, tier : int) -> String:
		var output : Array = []
		var i : int = 0
		while i < arr.size():
			if arr[i] == "{" and arr[i+2] == "}": #the next entry should be "#/#/#" or "text"
				var _ints = validateString( arr[i+1] ) #_ints if valid = ["#","#","#"]
				if _ints.size(): #if valid
					i += 2 #[ 0"{", 1"#/#/#", 2"}" ] 0-> 2
					output.append( _ints[tier] )
				else: #if arr[i+1] == "text"
					output.append(arr[i])
			else:
				output.append(arr[i])
			i += 1
		var str : String = ""
		for s in output:
			str += s
		return str
	
	#str should = "num/num/num" if its valid ("num" == int in valid cases)
	func validateString(str : String) -> Array:
		var flip : bool = false #looking for:  0 = only ints,   1 = ints and "/",
		var nums : Array = ["","",""]
		var numAccess : int = 0
		for i in str.length(): # "{#/#/#}" or maybe {#/#/##} cuz double digits???
			var s = str[i]
			if flip: #if we last recieved a number
				if s == "/": # if its the correct symbol
					numAccess += 1
					if numAccess >= nums.size(): #too many "/"s get out
						return []
					flip = false
				elif s.is_valid_int(): #if the number is double digits
					nums[numAccess] += s
				else: #its wrong leave
					return []
			elif s.is_valid_int(): #if we didnt last recieve a number, we better be getting one now
				flip = true
				nums[numAccess] += s
			else: #if its not a number, and we didnt last recieve a number
				return [] #gtfo
		#at this point nums should be filled
		for i in nums:
			if i == "" or !i.is_valid_int():
				return []
		return nums

var condNTags : statusNtag
class statusNtag:
	var statuses : Array
	var tags : Array
	
	func _init():
		self.statuses = self.loadAllStatuses()
		self.tags = self.loadAllTags()
	#nid is either name or id
	func newRoll20Macro(nid, num : int = -1) -> String:
		var dict : Dictionary = {}
		for i in statuses:
			if i.name == nid:
				dict = i
		for i in tags:
			if i.nm == nid or i.id == nid:
				dict = i
		if dict != {}:
			return makeR20toolTip(dict.name,dict.description,num)
		return ""
	
	func makeR20toolTip(txt : String, desc : String, num : int = -1) -> String:
		var _o1 : String = txt
		var _o2 : String = desc
		_o2 = _o2.replace(")","&#41")
		if num > 0:
			_o1 = _o1.replace("{VAL}", str(num))
			_o2 = _o2.replace("{VAL}", str(num))
		return '['+_o1+'](#" class="showtip" title="'+_o2+')'
	
	func loadAllTags() -> Array:
		var file = FileAccess.open("res://Settings/tags.json", FileAccess.READ)
		var s = file.get_as_text()
		var data = JSON.parse_string(s)
		var output : Array = []
		for tag in data:
			var _dict : Dictionary = {}
			_dict.name = tag.name
			_dict.id = tag.id
			_dict.nm = tag.name
			if "{VAL}" in _dict.nm:
				_dict.nm = _dict.nm.replace(" {VAL}","")
				_dict.nm = _dict.nm.replace("{VAL}","")
			_dict.description = tag.description
			output.append(_dict)
		return output
	
	func loadAllStatuses() -> Array:
		var file = FileAccess.open("res://Settings/statuses.json", FileAccess.READ)
		var s = file.get_as_text()
		var data = JSON.parse_string(s)
		var output : Array = []
		for status in data:
			var _dict : Dictionary = {}
			_dict.name = status.name
			_dict.id = "st_"+status.name
			_dict.description = status.terse
			output.append(_dict)
		return output

var html : htmlMarkdown
class htmlMarkdown:
	var li = ["<li>","</li>"] #each list item
	var htmlToR20 : Dictionary = {
			#h2r20.text[0] = text in **text**
			#h2r20.text[0] = ** in **text**
			"<ul>" : "</ul>", #bulleted list
			"<ol>" : "</ol>", #numbered list
			"</br>" : ["", "</br>"],
			"<br>" : ["%NEWLINE%", "<br>"],
			"</p>" : ["","</p>"],
			"<p>" : ["%NEWLINE% ", "<p>"],
			"<code>" : ["``","</code>"],
			"<b>" : ["**","</b>"],
			"<span class='horus--subtle'>[" : ["*","]</span"],
		}
	
	func processForHTMLmarkdown(txt : String) -> String:
		var str = String(txt)
		for key in htmlToR20.keys():
			#if its a list
			if (key == "<ol>" or key == "<ul>") and ("<ol>" in str) or ("<ul>" in str) : 
				str = htmlLists(str, key, htmlToR20[key])
			elif key != "<ol>" and key != "<ul>": #replace <> with "" and </> with "" or whatever symbol
				str = str.replace(key, htmlToR20[key][0])
				str = str.replace(htmlToR20[key][1], htmlToR20[key][0])
		return str
	
	func htmlLists(str : String, symbol : String, endSymbol : String) -> String:
		#split the str up into all parts that are lists and are not lists
		var arr = Array( str.split(symbol) )
		var o : Array = [arr.pop_front()]
		for i in arr:
			var ii = i.split(endSymbol, true, 1)
			#inside here ii[0] is the list itself
			var listType : bool = false #0:bullet, 1:numbered
			ii[0] = ii[0].replace("</li>", "%NEWLINE%")
			ii[0] = ii[0].replace("<li>", "•")
			if listType: #numbered list
				var _arr = ii[0].split("•")
				var _o : Array = [_arr.pop_front()]
				var count : int = 1
				for _str in _arr:
					_o.append(" "+str(count)+ ". ")
					_o.append(_str)
				ii[0] = ""
				for _s in _o:
					ii[0] += _s
			o.append_array( ii )
		var output : String = ""
		for s in o:
			output += s
		return output

