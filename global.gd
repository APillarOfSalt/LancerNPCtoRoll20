extends Node


func firstLetterCapRestLower(str : String) -> String:
	var char = str.left(1)
	return char + str.trim_prefix(char).to_lower()


var allLCPdata : Array
var tags : Array
var statuses : Array
#[
#	lcp dictionary = {
#		name : string
#		version : int
#		classes : dict
#		features : dict
#		templates : dict
#	},
#	{},..
#]

var styleboxes : Dictionary = {
	"set" : preload("res://styleboxes/settingsStylebox.tres"),
	"setDel" : preload("res://styleboxes/settingsDeleteStylebox.tres"),
	"gms" : preload("res://styleboxes/GMSredStylebox.tres"),
	"hor" : preload("res://styleboxes/HORUSstylebox.tres"),
	"aps" : preload("res://styleboxes/APSstylebox.tres"),
}

var defaultStylebox : StyleBox = styleboxes.aps





#    group    and    signal notes:
##lcpCatcher   ->  lcpsLoaded(enabledLCPs : Array):
##playerPicked ->  pilotPicked(p : Glo.pilotData):
##pMechPicked  ->  mechPicked(m : Dictionary):
##framePicked  ->  baseFramePicked(frame : Dictionary):
##stylebox     ->  swapStyle(style : StyleBox):


var err : bool = false
#true =  no saved lcps loaded,


var config = configuration.new()
class configuration:
	#user data managment
	var data : Dictionary
	#theme : Stylebox == defaultStylebox
	#"lcpName" : bool = Lcp enable disable toggle
	func _init():
		#check for config file
		var dir = DirAccess.open("user://")
		if dir.file_exists("config.json"):
			var file = FileAccess.open("user://config.json", FileAccess.READ)
			var s = file.get_as_text()
			self.data = JSON.parse_string(s) #read config
			file.close()
			if (self.data == null) or (s == "") or !(self.data is Dictionary):
				self.data = {}
		#if there is no config file, or it is empty: make and save a new one
		if self.data.keys().size() == 0:
			self.newConfig()
	
	func newConfig():
		self.data = {"theme" : "gms"}
		self.saveConfig(self.data)
	
	func saveConfig(con : Dictionary = self.data):
		self.data = con
		var file = FileAccess.open("user://config.json", FileAccess.WRITE)
		file.store_line(JSON.stringify(self.data))
		file.close()
	
	func lcpIO(named : String, toggle : bool):
		self.data[named] = toggle
		self.saveConfig()
		Glo.loadAllLCPs(true)
	
	func changeTheme(style) -> void:
		self.data.theme = style
		saveConfig()
	
	func changeSettings(toBeDeleted, toBeEnabled, toBeDisabled, noRecursion : bool = false) -> bool:
		var delToggle : bool = false
		for e in toBeEnabled:
			self.data[e] = true
		for d in toBeDisabled:
			self.data[d] = false
		for del in toBeDeleted:
			self.data.erase(del)
			var dir = DirAccess.open("user://savedLCPs")
			dir.list_dir_begin()
			var fileName = dir.get_next()
			while fileName != "":
				if fileName == del:
					var dir2 = DirAccess.open("user://savedLCPs/" + fileName)
					dir2.list_dir_begin()
					var fn = dir2.get_next()
					while fn != "":
						dir2.remove(fn)
						fn = dir2.get_next()
					dir.remove(fileName)
				fileName = dir.get_next()
			delToggle = true
		saveConfig()
		if noRecursion:
			return delToggle
		Glo.loadAllLCPs(true)
		return delToggle



func _ready() -> void:
	var dir = DirAccess.open("user://")
#load up config file
	config = configuration.new()
	if config.data.has("theme"):
		if styleboxes.keys().find( config.data.theme ) == -1: #if the theme isnt on the current list
			config.data.theme = "gms"
			config.saveConfig()
		defaultStylebox = styleboxes[config.data.theme]
		get_tree().call_group("stylebox", "swapStyle", defaultStylebox)
#check for lcp folder
	if !dir.dir_exists("savedLCPs"): #if no savedLCP folder exists make one
		dir.make_dir("user://savedLCPs")
		err = true #no saved lcp error
#check for no saved lcps
	if !err: #there are saved lcps
		loadAllLCPs(true)


#nid is either name or id
func frameLookup(nid : String) -> Dictionary:
	for lcp in allLCPdata:
		if lcp.has("frames"):
			for frame in lcp.frames:
				if frame.id == nid or frame.name.capitalize() == nid:
					return frame
	return {}


func talentLookup(id : String) -> Dictionary:
	for lcp in allLCPdata:
		if lcp.has("talents"):
			for talent in lcp.talents:
				if talent.id == id:
					return talent
	return {}

#false: only enabled lcps are returned,  true: all lcps are returned
func returnLCPs(toggle : bool = false) -> Array:
	if toggle:
		return allLCPdata
	else:
		var arr : Array = []
		for i in allLCPdata:
			if config.data.has(i.name): #if it has settings for this lcp
				if config.data[i.name]: #if its enabled
					arr.append(i)
			else: #if it doesn't
				config.lcpIO(i.name, true) #set it as enabled and load it
				arr.append(i)
		return arr




func loadAllLCPs(gloSave : bool) -> Array:
	var alldata : Array = [] 
	var dir = DirAccess.open("user://savedLCPs")
	dir.list_dir_begin()
	#saved lcps will be in folders check all folders
	var named = dir.get_next()
	while named != "": #check through the savedLCP's folder
		var folder = DirAccess.open("user://savedLCPs/" + named) #open folder
		folder.list_dir_begin()
		var jname = folder.get_next()
		var lcpDict : Dictionary = {
			"name" : "",
			"version" : 0.0,
		}
		while jname.get_extension() == "json": #check through the individual LCP folder
			var file = FileAccess.open("user://savedLCPs/" + named + "/" + jname, FileAccess.READ) #open each json
			var s = file.get_as_text()
			var data = JSON.parse_string(s)
			match jname:
				"lcp_manifest.json":
					lcpDict.name = data.name
					if !config.data.has(data.name):
						config.data[data.name] = true
					var ver = data.version
					var verNums = ver.split(".")
					var version = verNums[0]
					version += "."
					for i in verNums.size():
						if i != 0:
							version += str(verNums[i])
					lcpDict.version = float(version)
				_:
					lcpDict[jname.trim_suffix(".json")] = data
			jname = folder.get_next()
		folder.list_dir_end()
		named = dir.get_next()
		#now that we have this LCP's dictionary fully populated
		#check if its empty
		var actuallySaveItToggle : bool = false
		if lcpDict.has("name"):
			actuallySaveItToggle = true
			#search current lcp vs any other loaded lcps for duplicates
			for d in alldata:
				if d.name == lcpDict.name:
					#if duplicate throw away the older version (old if same)
					if lcpDict.version > d.version: #if the previously loaded version is older
						alldata.erase(d) #erase old data
		#now that its not a duplicate
		if actuallySaveItToggle:
			if !config.data.has(lcpDict.name): #if the config file doesnt have the lcp yet
				config.changeSettings([],[lcpDict.name],[], true) #enable it
			alldata.append(lcpDict)
	#finished loading saved data
	#allData is formatted as an array of lcpDict's
	#lcpDict's{name, version, classes, features, templates}
	#lcpDict{ name : String, version : int
	#classes, features, templates : all = Array[ of {dictionaries}, ... ]     }
	dir.list_dir_end()
	if gloSave:
		allLCPdata = alldata
	get_tree().call_group("lcpCatcher","lcpsLoaded", returnLCPs(false))
	return alldata


func typename(_var) -> String:
	return _TYPENAME[typeof(_var)]


const TYPENAME_NIL := "Null"
const TYPENAME_BOOL := "bool"
const TYPENAME_INT := "int"
const TYPENAME_REAL := "float"
const TYPENAME_STRING := "String"
const TYPENAME_VECTOR2 := "Vector2"
const TYPENAME_VECTOR2I := "Vector2i"
const TYPENAME_RECT2 := "Rect2"
const TYPENAME_RECT2I := "Rect2i"
const TYPENAME_VECTOR3 := "Vector3"
const TYPENAME_VECTOR3I := "Vector3i"
const TYPENAME_TRANSFORM2D := "Transform2D"
const TYPENAME_VECTOR4 := "Vector4"
const TYPENAME_VECTOR4I := "Vector4i"
const TYPENAME_PLANE := "Plane"
const TYPENAME_QUAT := "Quat"
const TYPENAME_AABB := "AABB"
const TYPENAME_BASIS := "Basis"
const TYPENAME_TRANSFORM3D := "Transform3D"
const TYPENAME_PROJECTION := "Projection"
const TYPENAME_COLOR := "Color"
const TYPENAME_STRING_NAME := "StringName"
const TYPENAME_NODE_PATH := "NodePath"
const TYPENAME_RID := "RID"
const TYPENAME_OBJECT := "Object"
const TYPENAME_CALLABLE := "Callable"
const TYPENAME_SIGNAL := "Signal"
const TYPENAME_DICTIONARY := "Dictionary"
const TYPENAME_ARRAY := "Array"
const TYPENAME_PACKED_BYTE_ARRAY := "PackedByteArray"
const TYPENAME_PACKED_INT32_ARRAY := "PackedInt32Array"
const TYPENAME_PACKED_INT64_ARRAY := "PackedInt64Array"
const TYPENAME_PACKED_FLOAT32_ARRAY := "PackedFloat32Array"
const TYPENAME_PACKED_FLOAT64_ARRAY := "PackedFloat64Array"
const TYPENAME_PACKED_STRING_ARRAY := "PackedStringArray"
const TYPENAME_PACKED_VECTOR2_ARRAY := "PackedVector2Array"
const TYPENAME_PACKED_VECTOR3_ARRAY := "PackedVector3Array"
const TYPENAME_PACKED_COLOR_ARRAY := "PackedColorArray"
const TYPENAME_MAX := "Max"


const _TYPENAME = {
	TYPE_NIL: TYPENAME_NIL,
	TYPE_BOOL: TYPENAME_BOOL,
	TYPE_INT: TYPENAME_INT,
	TYPE_FLOAT: TYPENAME_REAL,
	TYPE_STRING: TYPENAME_STRING,
	TYPE_VECTOR2: TYPENAME_VECTOR2,
	TYPE_VECTOR2I: TYPENAME_VECTOR2I,
	TYPE_RECT2: TYPENAME_RECT2,
	TYPE_RECT2I: TYPENAME_RECT2I,
	TYPE_VECTOR3: TYPENAME_VECTOR3,
	TYPE_VECTOR3I: TYPENAME_VECTOR3I,
	TYPE_TRANSFORM2D: TYPENAME_TRANSFORM2D,
	TYPE_VECTOR4: TYPENAME_VECTOR4,
	TYPE_VECTOR4I: TYPENAME_VECTOR4I,
	TYPE_PLANE: TYPENAME_PLANE,
	TYPE_QUATERNION: TYPENAME_QUAT,
	TYPE_AABB: TYPENAME_AABB,
	TYPE_BASIS: TYPENAME_BASIS,
	TYPE_TRANSFORM3D: TYPENAME_TRANSFORM3D,
	TYPE_PROJECTION: TYPENAME_PROJECTION,
	TYPE_COLOR: TYPENAME_COLOR,
	TYPE_STRING_NAME: TYPENAME_STRING_NAME,
	TYPE_NODE_PATH: TYPENAME_NODE_PATH,
	TYPE_RID: TYPENAME_RID,
	TYPE_OBJECT: TYPENAME_OBJECT,
	TYPE_CALLABLE: TYPENAME_CALLABLE,
	TYPE_SIGNAL: TYPENAME_SIGNAL,
	TYPE_DICTIONARY: TYPENAME_DICTIONARY,
	TYPE_ARRAY: TYPENAME_ARRAY,
	TYPE_PACKED_BYTE_ARRAY: TYPENAME_PACKED_BYTE_ARRAY,
	TYPE_PACKED_INT32_ARRAY: TYPENAME_PACKED_INT32_ARRAY,
	TYPE_PACKED_INT64_ARRAY: TYPENAME_PACKED_INT64_ARRAY,
	TYPE_PACKED_FLOAT32_ARRAY: TYPENAME_PACKED_FLOAT32_ARRAY,
	TYPE_PACKED_FLOAT64_ARRAY: TYPENAME_PACKED_FLOAT64_ARRAY,
	TYPE_PACKED_STRING_ARRAY: TYPENAME_PACKED_STRING_ARRAY,
	TYPE_PACKED_VECTOR2_ARRAY: TYPENAME_PACKED_VECTOR2_ARRAY,
	TYPE_PACKED_VECTOR3_ARRAY: TYPENAME_PACKED_VECTOR3_ARRAY,
	TYPE_PACKED_COLOR_ARRAY: TYPENAME_PACKED_COLOR_ARRAY,
	TYPE_MAX: TYPENAME_MAX,
}
